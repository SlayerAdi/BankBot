import os
import re
import subprocess
from typing import List, Optional

from fastapi import APIRouter, Depends, HTTPException
from pydantic import BaseModel
import requests

from dependencies import require_dashboard
from rasa_manager import (
    read_yaml,
    write_yaml,
    ensure_version,
    NLU_FILE,
    STORIES_FILE,
    RULES_FILE,
    DOMAIN_FILE,
    RASA_DIR,
)

router = APIRouter(prefix="/api/rasa", tags=["Rasa Admin"])


# ============================================================
# MODELS
# ============================================================

class IntentPayload(BaseModel):
    intent: str
    examples: List[str]
    response: Optional[str] = None


# ============================================================
# HELPERS
# ============================================================

SYSTEM_INTENTS = {
    "greet", "goodbye", "affirm", "deny", "thank_you", "help",
    "bot_challenge", "out_of_scope", "check_balance",
    "view_account_details", "view_all_accounts", "view_transactions",
    "download_statement", "dispute_transaction", "transfer_money",
    "view_scheduled_transfers", "cancel_transfer", "pay_bill",
    "view_bills", "setup_autopay", "view_cards", "view_card_details",
    "freeze_card", "unfreeze_card", "report_lost_card",
    "report_stolen_card", "activate_card", "request_new_card",
    "change_card_pin", "set_card_limit", "cards_menu",
    "check_loan_balance", "view_loan_details", "view_loan_repayment",
    "apply_for_loan", "make_loan_payment", "view_loan_interest_rate",
    "check_loan_eligibility", "request_loan_deferment", "loans_menu",
    "view_portfolio", "view_investment_performance", "view_market_rates",
    "view_dividends", "setup_investment_plan", "buy_stocks",
    "sell_stocks", "investment_menu", "view_fixed_deposits",
    "view_fd_interest_rate", "open_fixed_deposit", "close_fixed_deposit",
    "renew_fixed_deposit", "find_branch", "provide_branch_location",
    "find_atm", "view_exchange_rates", "contact_support",
    "report_fraud", "set_alert", "manage_notifications",
    "confirm_transfer", "deny_transfer", "confirm_freeze_card",
    "deny_freeze_card", "confirm_unfreeze_card", "deny_unfreeze_card",
    "confirm_bill_payment", "deny_bill_payment", "confirm_loan_payment",
    "deny_loan_payment"
}


def sanitize_intent_name(intent: str) -> str:
    intent = intent.strip().lower()
    intent = re.sub(r"[^a-z0-9_ ]", "", intent)
    intent = intent.replace(" ", "_")
    return intent


def normalize_examples(examples: List[str]) -> str:
    cleaned = []
    seen = set()

    for ex in examples:
        ex = ex.strip()
        if ex and ex.lower() not in seen:
            seen.add(ex.lower())
            cleaned.append(f"- {ex}")

    return "\n".join(cleaned)


def prettify_response(intent_name: str) -> str:
    label = intent_name.replace("_", " ").title()
    return f"I understood your request for **{label}**. Let me help you with that."


def ensure_intent_in_domain(domain_data, intent_name):
    intents = domain_data.get("intents", [])
    if intent_name not in intents:
        intents.append(intent_name)
    domain_data["intents"] = intents


def ensure_response_in_domain(domain_data, intent_name, response_text):
    responses = domain_data.get("responses", {})
    utter_name = f"utter_{intent_name}"
    responses[utter_name] = [{"text": response_text}]
    domain_data["responses"] = responses


def ensure_rule(rules_data, intent_name):
    rules = rules_data.get("rules", [])
    rule_name = f"Respond to {intent_name}"

    exists = any(r.get("rule") == rule_name for r in rules)
    if not exists:
        rules.append({
            "rule": rule_name,
            "steps": [
                {"intent": intent_name},
                {"action": f"utter_{intent_name}"}
            ]
        })

    rules_data["rules"] = rules


def remove_auto_rule(rules_data, intent_name):
    rules = rules_data.get("rules", [])
    rule_name = f"Respond to {intent_name}"

    rules_data["rules"] = [
        r for r in rules if r.get("rule") != rule_name
    ]
    return rules_data


def remove_auto_story(stories_data, intent_name):
    stories = stories_data.get("stories", [])
    story_name = f"{intent_name} path"

    rules_data = [
        s for s in stories if s.get("story") != story_name
    ]
    stories_data["stories"] = rules_data
    return stories_data


def remove_intent_from_nlu(nlu_data, intent_name):
    nlu_items = nlu_data.get("nlu", [])
    nlu_data["nlu"] = [item for item in nlu_items if item.get("intent") != intent_name]
    return nlu_data


def remove_intent_from_domain(domain_data, intent_name):
    intents = domain_data.get("intents", [])
    domain_data["intents"] = [i for i in intents if i != intent_name]

    responses = domain_data.get("responses", {})
    utter_name = f"utter_{intent_name}"
    if utter_name in responses:
        del responses[utter_name]

    domain_data["responses"] = responses
    return domain_data


# ============================================================
# LIST INTENTS
# ============================================================

@router.get("/intents")
def get_intents(user=Depends(require_dashboard("view"))):
    nlu_data = read_yaml(NLU_FILE)
    nlu_items = nlu_data.get("nlu", [])

    result = []
    for item in nlu_items:
        if "intent" in item:
            result.append({
                "intent": item["intent"],
                "examples": item.get("examples", "")
            })

    return {"intents": result}


# ============================================================
# ADD / UPDATE INTENT
# ============================================================

@router.post("/intents")
def add_or_update_intent(payload: IntentPayload, user=Depends(require_dashboard("edit"))):
    intent_name = sanitize_intent_name(payload.intent)

    if not intent_name:
        raise HTTPException(status_code=400, detail="Intent name is required")

    if intent_name in SYSTEM_INTENTS:
        raise HTTPException(
            status_code=400,
            detail=f"'{intent_name}' is a protected system intent and cannot be overwritten from admin panel"
        )

    examples_text = normalize_examples(payload.examples)
    if not examples_text.strip():
        raise HTTPException(status_code=400, detail="At least one example is required")

    response_text = payload.response.strip() if payload.response and payload.response.strip() else prettify_response(intent_name)

    # ---------------------------
    # NLU
    # ---------------------------
    nlu_data = ensure_version(read_yaml(NLU_FILE))
    nlu_items = nlu_data.get("nlu", [])

    found = False
    for item in nlu_items:
        if item.get("intent") == intent_name:
            item["examples"] = examples_text
            found = True
            break

    if not found:
        nlu_items.append({
            "intent": intent_name,
            "examples": examples_text
        })

    nlu_data["nlu"] = nlu_items
    write_yaml(NLU_FILE, nlu_data)

    # ---------------------------
    # DOMAIN
    # ---------------------------
    domain_data = ensure_version(read_yaml(DOMAIN_FILE))
    ensure_intent_in_domain(domain_data, intent_name)
    ensure_response_in_domain(domain_data, intent_name, response_text)
    write_yaml(DOMAIN_FILE, domain_data)

    # ---------------------------
    # RULES (ONLY auto FAQ rule)
    # ---------------------------
    rules_data = ensure_version(read_yaml(RULES_FILE))
    ensure_rule(rules_data, intent_name)
    write_yaml(RULES_FILE, rules_data)

    return {
        "success": True,
        "message": f"Intent '{intent_name}' saved successfully",
        "auto_response_used": not bool(payload.response and payload.response.strip()),
        "response": response_text
    }


# ============================================================
# DELETE INTENT
# ============================================================

@router.delete("/intents/{intent_name}")
def delete_intent(intent_name: str, user=Depends(require_dashboard("edit"))):
    intent_name = sanitize_intent_name(intent_name)

    if intent_name in SYSTEM_INTENTS:
        raise HTTPException(
            status_code=400,
            detail=f"'{intent_name}' is a protected system intent and cannot be deleted"
        )

    # NLU
    nlu_data = ensure_version(read_yaml(NLU_FILE))
    nlu_data = remove_intent_from_nlu(nlu_data, intent_name)
    write_yaml(NLU_FILE, nlu_data)

    # DOMAIN
    domain_data = ensure_version(read_yaml(DOMAIN_FILE))
    domain_data = remove_intent_from_domain(domain_data, intent_name)
    write_yaml(DOMAIN_FILE, domain_data)

    # RULES
    rules_data = ensure_version(read_yaml(RULES_FILE))
    rules_data = remove_auto_rule(rules_data, intent_name)
    write_yaml(RULES_FILE, rules_data)

    # STORIES (only admin auto story if exists)
    stories_data = ensure_version(read_yaml(STORIES_FILE))
    stories_data = remove_auto_story(stories_data, intent_name)
    write_yaml(STORIES_FILE, stories_data)

    return {
        "success": True,
        "message": f"Intent '{intent_name}' deleted successfully"
    }


# ============================================================
# TRAIN MODEL
# ============================================================

@router.post("/train")
def train_rasa(user=Depends(require_dashboard("edit"))):
    import requests

    try:
        # ── RASA EXECUTABLE PATH ──────────────────────────────────────────────
        # The path to the `rasa` executable is resolved automatically using
        # `shutil.which()`, which checks your system PATH — no hardcoding needed.
        #
        # For this to work, make sure Rasa is installed and its Scripts/bin
        # directory is on your PATH. Common locations:
        #
        #   Windows  : C:\Users\<you>\AppData\Local\Programs\Python\Python310\Scripts\rasa.exe
        #              (add this folder to System Environment Variables → PATH)
        #
        #   macOS    : /usr/local/bin/rasa   OR   ~/Library/Python/3.10/bin/rasa
        #              (install via: pip install rasa==3.6.0)
        #
        #   Linux    : /usr/local/bin/rasa   OR   ~/.local/bin/rasa
        #              (install via: pip install rasa==3.6.0)
        #
        # If auto-detection fails, you can override by setting RASA_EXE in
        # your backend/.env file:
        #   RASA_EXE=/absolute/path/to/your/rasa
        # ─────────────────────────────────────────────────────────────────────
        import shutil
        from config import settings

        rasa_exe = getattr(settings, "RASA_EXE", None) or shutil.which("rasa")
        RASA_SERVER_URL = settings.RASA_URL  # from .env, default: http://localhost:5005

        if not rasa_exe or not os.path.exists(rasa_exe):
            raise HTTPException(
                status_code=500,
                detail=(
                    "Rasa executable not found. "
                    "Make sure Rasa is installed ('pip install rasa==3.6.0') "
                    "and its bin/Scripts directory is on your PATH, "
                    "or set RASA_EXE=/path/to/rasa in backend/.env"
                )
            )

        print("🚀 Training started...")
        print("📂 RASA_DIR:", RASA_DIR)

        result = subprocess.run(
            [rasa_exe, "train"],
            cwd=RASA_DIR,
            capture_output=True,
            text=True,
            shell=False,
        )

        print("📤 TRAIN STDOUT:\n", result.stdout)
        print("📥 TRAIN STDERR:\n", result.stderr)
        print("🔢 RETURN CODE:", result.returncode)

        if result.returncode != 0:
            raise HTTPException(
                status_code=500,
                detail=(
                    f"Training failed.\n\n"
                    f"STDOUT:\n{result.stdout}\n\n"
                    f"STDERR:\n{result.stderr}"
                )
            )

        models_dir = os.path.join(RASA_DIR, "models")
        latest_model = None

        if os.path.exists(models_dir):
            model_files = [
                os.path.join(models_dir, f)
                for f in os.listdir(models_dir)
                if f.endswith(".tar.gz")
            ]
            if model_files:
                latest_model = max(model_files, key=os.path.getmtime)

        if not latest_model:
            raise HTTPException(
                status_code=500,
                detail="Training completed but no model file was found in /models"
            )

        latest_model_name = os.path.basename(latest_model)
        latest_model_relative = f"models/{latest_model_name}"

        print("🧠 Latest model found:", latest_model_name)
        print("📦 Relative model path:", latest_model_relative)

        reload_ok = False
        reload_status = None
        reload_response_text = ""
        reload_warning = None

        try:
            payload = {"model_file": latest_model_relative}

            print("🔄 Reload payload:", payload)
            print("🔄 Reload URL:", f"{RASA_SERVER_URL}/model")

            reload_response = requests.put(
                f"{RASA_SERVER_URL}/model",
                json=payload,
                timeout=15
            )

            reload_status = reload_response.status_code
            reload_response_text = reload_response.text

            print("🔄 Rasa reload status:", reload_status)
            print("🔄 Rasa reload response:", repr(reload_response_text))

            if reload_status in [200, 204]:
                reload_ok = True
            else:
                reload_warning = (
                    f"Model trained successfully, but live reload failed "
                    f"(HTTP {reload_status}). Restart Rasa to load latest model."
                )

        except requests.exceptions.RequestException as e:
            reload_warning = (
                f"Model trained successfully, but could not connect to running "
                f"Rasa server for live reload: {str(e)}. Restart Rasa to load latest model."
            )
            print("⚠️ Live reload failed:", str(e))

        return {
            "success": True,
            "message": "Rasa trained successfully",
            "latest_model": latest_model_name,
            "model_path": latest_model_relative,
            "live_reload_success": reload_ok,
            "live_reload_status": reload_status,
            "live_reload_response": reload_response_text,
            "warning": reload_warning,
            "stdout": result.stdout[-3000:] if result.stdout else "",
            "stderr": result.stderr[-2000:] if result.stderr else "",
        }

    except HTTPException:
        raise

    except Exception as e:
        import traceback
        traceback.print_exc()
        raise HTTPException(status_code=500, detail=f"Unexpected error: {str(e)}")