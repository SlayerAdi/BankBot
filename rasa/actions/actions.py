import logging
import os
import random
import string
from datetime import datetime, timedelta, date
from typing import Any, Dict, List, Optional, Text

import mysql.connector
from mysql.connector import Error

from rasa_sdk import Action, FormValidationAction, Tracker
from rasa_sdk.events import SlotSet
from rasa_sdk.executor import CollectingDispatcher
from rasa_sdk.types import DomainDict

logger = logging.getLogger(__name__)

# ================================================================
# DATABASE CONFIGURATION
# ================================================================

# ================================================================
# DATABASE CONFIGURATION
# ================================================================
# The Rasa action server connects directly to MySQL.
# Set these values using environment variables before starting the action server.
#
# How to set environment variables:
#
#   Linux / macOS — add to your shell profile (~/.bashrc or ~/.zshrc), or
#   export inline before running:
#     export RASA_DB_HOST=localhost
#     export RASA_DB_PORT=3306
#     export RASA_DB_USER=root
#     export RASA_DB_PASSWORD=your_mysql_password
#     export RASA_DB_NAME=infybot_db
#
#   Windows (PowerShell):
#     $env:RASA_DB_HOST="localhost"
#     $env:RASA_DB_PASSWORD="your_mysql_password"
#
#   Or create a  rasa/.env  file and load it before starting:
#     source rasa/.env   (Linux/macOS)
#
# The defaults below match a typical local MySQL install.
# Only RASA_DB_PASSWORD has no safe default — you must set it.
# ================================================================

DB_CONFIG = {
    "host":     os.environ.get("RASA_DB_HOST", "localhost"),
    "port":     int(os.environ.get("RASA_DB_PORT", "3306")),
    "user":     os.environ.get("RASA_DB_USER", "root"),
    "password": os.environ.get("RASA_DB_PASSWORD", ""),   # ← REQUIRED: set RASA_DB_PASSWORD
    "database": os.environ.get("RASA_DB_NAME", "infybot_db"),
    "autocommit": True,
    "connection_timeout": 10,
}

# ================================================================
# DATABASE UTILITIES
# ================================================================

def get_db_connection():
    try:
        conn = mysql.connector.connect(**DB_CONFIG)
        if conn.is_connected():
            return conn
    except Error as exc:
        logger.error("DB connection failed: %s", exc)
    return None


def execute_query(query: str, params: tuple = None, fetch: bool = True):
    conn = get_db_connection()
    if conn is None:
        return None

    cursor = None
    try:
        cursor = conn.cursor(dictionary=True)
        cursor.execute(query, params or ())
        if fetch:
            return cursor.fetchall()
        conn.commit()
        return cursor.rowcount
    except Error as exc:
        logger.error("Query error: %s\nSQL: %s", exc, query)
        return None
    finally:
        if conn and conn.is_connected():
            if cursor:
                cursor.close()
            conn.close()


# ================================================================
# AUTH HELPERS
# ================================================================

def get_user_id(tracker: Tracker) -> Optional[str]:
    """
    users.id is VARCHAR(36) in schema.sql
    So NEVER cast to int.
    """
    metadata = tracker.latest_message.get("metadata", {}) or {}
    user_id = metadata.get("user_id") or metadata.get("id")
    if user_id:
        return str(user_id).strip()
    return None


def get_account_number(tracker: Tracker) -> Optional[str]:
    metadata = tracker.latest_message.get("metadata", {}) or {}
    account_number = metadata.get("account_number")
    if account_number:
        return str(account_number).strip()
    return None


def get_authenticated_user(tracker: Tracker) -> Optional[Dict[str, Any]]:
    user_id = get_user_id(tracker)
    account_number = get_account_number(tracker)

    if user_id:
        rows = execute_query(
            "SELECT * FROM users WHERE id = %s AND is_active = 1 LIMIT 1",
            (user_id,)
        )
        if rows:
            return rows[0]

    if account_number:
        rows = execute_query(
            "SELECT * FROM users WHERE account_number = %s AND is_active = 1 LIMIT 1",
            (account_number,)
        )
        if rows:
            return rows[0]

    return None


# ================================================================
# GENERIC HELPERS
# ================================================================

def gen_ref(prefix: str = "TXN") -> str:
    rand = "".join(random.choices(string.ascii_uppercase + string.digits, k=8))
    return f"{prefix}{datetime.now().strftime('%Y%m%d')}{rand}"


def fmt_currency(amount: float, currency: str = "INR") -> str:
    symbols = {"USD": "$", "EUR": "€", "GBP": "£", "INR": "₹", "JPY": "¥"}
    sym = symbols.get(currency, currency + " ")
    try:
        return f"{sym}{float(amount):,.2f}"
    except Exception:
        return f"{sym}0.00"


def mask_account(acct: str) -> str:
    acct = str(acct)
    return "****" + acct[-4:] if len(acct) > 4 else acct


def mask_card(card: str) -> str:
    card = str(card)
    return "**** **** **** " + card[-4:] if len(card) >= 4 else card


def safe_float(value, default=0.0):
    try:
        return float(value)
    except Exception:
        return default


def get_primary_account(user_id: str, account_type: Optional[str] = None):
    if account_type:
        rows = execute_query(
            "SELECT * FROM accounts WHERE user_id=%s AND account_type=%s AND status='active' LIMIT 1",
            (user_id, account_type.lower())
        )
    else:
        rows = execute_query(
            "SELECT * FROM accounts WHERE user_id=%s AND status='active' ORDER BY account_type LIMIT 1",
            (user_id,)
        )
    return rows[0] if rows else None


# ================================================================
# DYNAMIC ACTION HELPERS
# ================================================================

def normalize_text(value: Optional[str]) -> str:
    return str(value or "").strip().lower().replace(" ", "_")


def get_intent_name(tracker: Tracker) -> str:
    return normalize_text(tracker.latest_message.get("intent", {}).get("name", ""))


def simple_success_message(title: str, details: List[str] = None) -> str:
    lines = [f"✅ **{title}**"]
    if details:
        lines.extend(details)
    return "\n".join(lines)


# ================================================================
# ACTION: action_default_fallback
# ================================================================

class ActionDefaultFallback(Action):
    def name(self) -> Text:
        return "action_default_fallback"

    def run(self, dispatcher: CollectingDispatcher, tracker: Tracker,
            domain: DomainDict) -> List[Dict[Text, Any]]:
        dispatcher.utter_message(
            text="I didn’t quite understand that. Could you rephrase or type 'help' to see what I can do?"
        )
        return []


# ================================================================
# ACTION: action_dynamic_admin_fallback
# ================================================================

class ActionDynamicAdminFallback(Action):
    def name(self) -> Text:
        return "action_dynamic_admin_fallback"

    def run(
        self,
        dispatcher: CollectingDispatcher,
        tracker: Tracker,
        domain: DomainDict
    ) -> List[Dict[Text, Any]]:

        intent_name = get_intent_name(tracker)

        dispatcher.utter_message(
            text=(
                f"🛠️ I recognized the intent **{intent_name.replace('_', ' ')}**, "
                f"but this feature is not fully connected to a backend action yet.\n\n"
                f"Please complete the business logic in `actions.py` or configure an "
                f"`utter_{intent_name}` response in `domain.yml`."
            )
        )
        return []


# ================================================================
# ACTION: action_generic_service_request
# ================================================================

class ActionGenericServiceRequest(Action):
    def name(self) -> Text:
        return "action_generic_service_request"

    def run(
        self,
        dispatcher: CollectingDispatcher,
        tracker: Tracker,
        domain: DomainDict
    ) -> List[Dict[Text, Any]]:

        auth_user = get_authenticated_user(tracker)
        if not auth_user:
            dispatcher.utter_message(text="⚠️ Authentication required.")
            return []

        intent_name = get_intent_name(tracker)
        ref_id = gen_ref("SRV")

        friendly_name = intent_name.replace("_", " ").title()

        dispatcher.utter_message(
            text=(
                f"✅ **{friendly_name} Request Submitted**\n"
                f"Reference: {ref_id}\n"
                f"Customer: {auth_user.get('full_name', 'N/A')}\n\n"
                f"Our team will process your request shortly."
            )
        )

        return []


# ================================================================
# ACTION: action_check_balance
# ================================================================

class ActionCheckBalance(Action):
    def name(self) -> Text:
        return "action_check_balance"

    def run(self, dispatcher: CollectingDispatcher, tracker: Tracker,
            domain: DomainDict) -> List[Dict[Text, Any]]:

        auth_user = get_authenticated_user(tracker)
        if not auth_user:
            dispatcher.utter_message(text="⚠️ Session error — please log in again.")
            return []

        user_id = auth_user["id"]
        account_type = tracker.get_slot("account_type")

        if account_type:
            rows = execute_query(
                "SELECT account_type, account_number, balance, currency, status "
                "FROM accounts WHERE user_id=%s AND account_type=%s AND status='active'",
                (user_id, account_type.lower())
            )
        else:
            rows = execute_query(
                "SELECT account_type, account_number, balance, currency, status "
                "FROM accounts WHERE user_id=%s AND status='active' ORDER BY account_type",
                (user_id,)
            )

        if not rows:
            dispatcher.utter_message(text="No active accounts found on your profile.")
            return [SlotSet("account_type", None)]

        if len(rows) == 1:
            r = rows[0]
            msg = (
                f"💰 **{r['account_type'].title()} Account**\n"
                f"Account: {mask_account(r['account_number'])}\n"
                f"Balance: {fmt_currency(r['balance'], r['currency'])}\n"
                f"Status: {r['status'].title()}"
            )
        else:
            lines = ["💼 **Your Account Balances:**\n"]
            total = 0.0
            currency = "INR"
            for r in rows:
                lines.append(
                    f"• **{r['account_type'].title()}** "
                    f"({mask_account(r['account_number'])}): "
                    f"{fmt_currency(r['balance'], r['currency'])}"
                )
                total += safe_float(r["balance"])
                currency = r["currency"]
            lines.append(f"\n**Total Balance:** {fmt_currency(total, currency)}")
            msg = "\n".join(lines)

        dispatcher.utter_message(text=msg)
        return [SlotSet("account_type", None)]


# ================================================================
# ACTION: action_view_transactions
# ================================================================

class ActionViewTransactions(Action):
    def name(self) -> Text:
        return "action_view_transactions"

    def run(self, dispatcher: CollectingDispatcher, tracker: Tracker,
            domain: DomainDict) -> List[Dict[Text, Any]]:

        auth_user = get_authenticated_user(tracker)
        if not auth_user:
            dispatcher.utter_message(text="⚠️ Authentication required.")
            return []

        user_id = auth_user["id"]

        merchant = tracker.get_slot("merchant_name")
        txn_id = tracker.get_slot("transaction_id")
        date_filter = tracker.get_slot("date")
        amount = tracker.get_slot("amount")
        time_period = tracker.get_slot("time_period")

        sql = (
            "SELECT t.transaction_id, t.amount, t.transaction_type, "
            "t.merchant_name, t.description, t.status, t.created_at, a.currency "
            "FROM transactions t "
            "JOIN accounts a ON t.account_id = a.account_id "
            "WHERE a.user_id = %s"
        )
        params: List[Any] = [user_id]

        if txn_id:
            sql += " AND t.transaction_id = %s"
            params.append(txn_id)
        elif merchant:
            sql += " AND t.merchant_name LIKE %s"
            params.append(f"%{merchant}%")
        elif date_filter:
            sql += " AND DATE(t.created_at) = %s"
            params.append(date_filter)
        elif amount:
            sql += " AND t.amount >= %s"
            params.append(safe_float(amount))
        elif time_period:
            tp = str(time_period).lower()
            if "week" in tp:
                sql += " AND t.created_at >= DATE_SUB(NOW(), INTERVAL 7 DAY)"
            elif "month" in tp:
                sql += " AND t.created_at >= DATE_SUB(NOW(), INTERVAL 30 DAY)"

        intent = tracker.latest_message.get("intent", {}).get("name", "")
        if intent == "view_pending_transactions":
            sql += " AND t.status = 'pending'"

        sql += " ORDER BY t.created_at DESC LIMIT 15"

        rows = execute_query(sql, tuple(params))

        if not rows:
            dispatcher.utter_message(text="No transactions found matching your criteria.")
            return [
                SlotSet("merchant_name", None),
                SlotSet("transaction_id", None),
                SlotSet("amount", None),
                SlotSet("time_period", None),
            ]

        lines = [f"📋 **Transactions** ({len(rows)} found):\n"]
        for r in rows:
            sign = "+" if r["transaction_type"] == "credit" else "-"
            emoji = "💚" if r["transaction_type"] == "credit" else "🔴"
            dt = r["created_at"].strftime("%b %d, %Y")
            status_tag = f" [{r['status'].upper()}]" if r["status"] != "completed" else ""
            title = r["merchant_name"] or r["description"] or "Transaction"

            lines.append(
                f"{emoji} {dt} | {title} | "
                f"{sign}{fmt_currency(r['amount'], r['currency'])}{status_tag} | "
                f"ID: {r['transaction_id']}"
            )

        dispatcher.utter_message(text="\n".join(lines))
        return [
            SlotSet("merchant_name", None),
            SlotSet("transaction_id", None),
            SlotSet("amount", None),
            SlotSet("time_period", None),
        ]


# ================================================================
# ACTION: action_transfer_money
# ================================================================

class ActionTransferMoney(Action):
    def name(self) -> Text:
        return "action_transfer_money"

    def run(self, dispatcher: CollectingDispatcher, tracker: Tracker,
            domain: DomainDict) -> List[Dict[Text, Any]]:

        auth_user = get_authenticated_user(tracker)
        if not auth_user:
            dispatcher.utter_message(text="⚠️ Authentication required.")
            return []

        user_id = auth_user["id"]

        amount = tracker.get_slot("amount")
        recipient_name = tracker.get_slot("recipient_name")
        recipient_account = tracker.get_slot("recipient_account")
        account_type = tracker.get_slot("account_type") or "checking"

        amount = safe_float(amount)
        if amount <= 0:
            dispatcher.utter_message(text="Please provide a valid transfer amount.")
            return []

        sender = get_primary_account(user_id, account_type)
        if not sender:
            dispatcher.utter_message(text=f"No active {account_type} account found.")
            return []

        if safe_float(sender["balance"]) < amount:
            dispatcher.utter_message(
                text=(
                    f"❌ Insufficient funds.\n"
                    f"Available Balance: {fmt_currency(sender['balance'], sender['currency'])}\n"
                    f"Requested Transfer: {fmt_currency(amount, sender['currency'])}"
                )
            )
            return []

        ref_id = gen_ref("TRF")

        execute_query(
            "UPDATE accounts SET balance = balance - %s WHERE account_id = %s",
            (amount, sender["account_id"]),
            fetch=False
        )

        execute_query(
            "INSERT INTO transactions "
            "(transaction_id, account_id, amount, transaction_type, merchant_name, description, reference_id, status) "
            "VALUES (%s,%s,%s,'debit',%s,%s,%s,'completed')",
            (
                ref_id,
                sender["account_id"],
                amount,
                recipient_name or "External Transfer",
                f"Transfer to {recipient_name or recipient_account or 'recipient'}",
                ref_id,
            ),
            fetch=False
        )

        if recipient_account:
            rec_rows = execute_query(
                "SELECT account_id, currency FROM accounts WHERE account_number=%s AND status='active' LIMIT 1",
                (recipient_account,)
            )
            if rec_rows:
                recipient = rec_rows[0]
                execute_query(
                    "UPDATE accounts SET balance = balance + %s WHERE account_id = %s",
                    (amount, recipient["account_id"]),
                    fetch=False
                )
                execute_query(
                    "INSERT INTO transactions "
                    "(transaction_id, account_id, amount, transaction_type, merchant_name, description, reference_id, status) "
                    "VALUES (%s,%s,%s,'credit',%s,%s,%s,'completed')",
                    (
                        gen_ref("CRD"),
                        recipient["account_id"],
                        amount,
                        auth_user["full_name"],
                        f"Transfer received from {auth_user['full_name']}",
                        ref_id,
                    ),
                    fetch=False
                )

        new_bal = safe_float(sender["balance"]) - amount

        dispatcher.utter_message(
            text=(
                f"✅ **Transfer Successful!**\n"
                f"Amount: {fmt_currency(amount, sender['currency'])}\n"
                f"To: {recipient_name or recipient_account or 'Recipient'}\n"
                f"From: {account_type.title()} Account\n"
                f"Reference: **{ref_id}**\n"
                f"Date: {datetime.now().strftime('%b %d, %Y %I:%M %p')}\n"
                f"New Balance: {fmt_currency(new_bal, sender['currency'])}"
            )
        )

        return [
            SlotSet("amount", None),
            SlotSet("recipient_name", None),
            SlotSet("recipient_account", None),
            SlotSet("account_type", None),
        ]


# ================================================================
# ACTION: action_pay_bill
# ================================================================

class ActionPayBill(Action):
    def name(self) -> Text:
        return "action_pay_bill"

    def run(self, dispatcher: CollectingDispatcher, tracker: Tracker,
            domain: DomainDict) -> List[Dict[Text, Any]]:

        auth_user = get_authenticated_user(tracker)
        if not auth_user:
            dispatcher.utter_message(text="⚠️ Authentication required.")
            return []

        user_id = auth_user["id"]
        bill_type = tracker.get_slot("bill_type")
        amount = tracker.get_slot("amount")

        rows = execute_query(
            "SELECT bill_id, biller_name, due_date, amount "
            "FROM bills WHERE user_id=%s AND status='pending' AND biller_name LIKE %s "
            "ORDER BY due_date ASC LIMIT 1",
            (user_id, f"%{bill_type or ''}%")
        )

        ref_id = gen_ref("BILL")

        if rows:
            bill = rows[0]
            pay_amount = safe_float(amount) if amount else safe_float(bill["amount"])

            execute_query(
                "UPDATE bills SET status='paid', paid_at=NOW() WHERE bill_id=%s",
                (bill["bill_id"],),
                fetch=False
            )

            msg = (
                f"✅ **Bill Payment Successful!**\n"
                f"Biller: {bill['biller_name']}\n"
                f"Amount: {fmt_currency(pay_amount)}\n"
                f"Due Date: {bill['due_date']}\n"
                f"Reference: {ref_id}\n"
                f"Status: **Paid** ✓"
            )
        else:
            pay_amount = safe_float(amount)
            msg = (
                f"✅ **Bill Payment Processed**\n"
                f"Type: {bill_type or 'General'}\n"
                f"Amount: {fmt_currency(pay_amount)}\n"
                f"Reference: {ref_id}"
            )

        dispatcher.utter_message(text=msg)
        return [SlotSet("bill_type", None), SlotSet("amount", None)]


# ================================================================
# ACTION: action_view_cards
# ================================================================

class ActionViewCards(Action):
    def name(self) -> Text:
        return "action_view_cards"

    def run(self, dispatcher: CollectingDispatcher, tracker: Tracker,
            domain: DomainDict) -> List[Dict[Text, Any]]:

        auth_user = get_authenticated_user(tracker)
        if not auth_user:
            dispatcher.utter_message(text="⚠️ Authentication required.")
            return []

        user_id = auth_user["id"]

        rows = execute_query(
            "SELECT card_id, card_type, card_number, card_network, expiry_date, status, credit_limit, available_credit "
            "FROM cards WHERE user_id=%s ORDER BY card_type",
            (user_id,)
        )

        if not rows:
            dispatcher.utter_message(text="No cards found on your account.")
            return []

        lines = [f"💳 **Your Cards ({len(rows)} total):**\n"]
        for c in rows:
            emoji = "✅" if c["status"] == "active" else "🔒" if c["status"] == "frozen" else "🚫"
            lines.append(
                f"{emoji} **{c['card_network']} {c['card_type'].title()}**\n"
                f"   Number: {mask_card(c['card_number'])}\n"
                f"   Expires: {c['expiry_date']}\n"
                f"   Status: {c['status'].title()}"
            )
            if c["card_type"] == "credit":
                lines.append(
                    f"   Credit Limit: {fmt_currency(c['credit_limit'])}\n"
                    f"   Available: {fmt_currency(c['available_credit'])}"
                )
            lines.append("")

        dispatcher.utter_message(text="\n".join(lines))
        return []


# ================================================================
# ACTION: action_freeze_card
# ================================================================

class ActionFreezeCard(Action):
    def name(self) -> Text:
        return "action_freeze_card"

    def run(self, dispatcher: CollectingDispatcher, tracker: Tracker,
            domain: DomainDict) -> List[Dict[Text, Any]]:

        auth_user = get_authenticated_user(tracker)
        if not auth_user:
            dispatcher.utter_message(text="⚠️ Authentication required.")
            return []

        user_id = auth_user["id"]
        card_type = tracker.get_slot("card_type")

        sql = "SELECT card_id, card_number, card_network FROM cards WHERE user_id=%s AND status='active'"
        params = [user_id]

        if card_type:
            sql += " AND card_type=%s"
            params.append(card_type)

        sql += " LIMIT 1"

        rows = execute_query(sql, tuple(params))
        if not rows:
            dispatcher.utter_message(text="No active card found. Your card may already be frozen.")
            return []

        card = rows[0]

        execute_query(
            "UPDATE cards SET status='frozen' WHERE card_id=%s",
            (card["card_id"],),
            fetch=False
        )

        dispatcher.utter_message(
            text=(
                f"🔒 **Card Frozen**\n"
                f"Card: {card['card_network']} {mask_card(card['card_number'])}\n"
                f"Status: Frozen\n\n"
                f"No transactions will be processed. You can unfreeze it anytime."
            )
        )

        return [SlotSet("card_type", None)]


# ================================================================
# ACTION: action_unfreeze_card
# ================================================================

class ActionUnfreezeCard(Action):
    def name(self) -> Text:
        return "action_unfreeze_card"

    def run(self, dispatcher: CollectingDispatcher, tracker: Tracker,
            domain: DomainDict) -> List[Dict[Text, Any]]:

        auth_user = get_authenticated_user(tracker)
        if not auth_user:
            dispatcher.utter_message(text="⚠️ Authentication required.")
            return []

        user_id = auth_user["id"]

        rows = execute_query(
            "SELECT card_id, card_number, card_network FROM cards WHERE user_id=%s AND status='frozen' LIMIT 1",
            (user_id,)
        )

        if not rows:
            dispatcher.utter_message(text="No frozen card found on your account.")
            return []

        card = rows[0]

        execute_query(
            "UPDATE cards SET status='active' WHERE card_id=%s",
            (card["card_id"],),
            fetch=False
        )

        dispatcher.utter_message(
            text=(
                f"✅ **Card Unfrozen**\n"
                f"Card: {card['card_network']} {mask_card(card['card_number'])}\n"
                f"Status: Active — ready for transactions."
            )
        )
        return []


# ================================================================
# ACTION: action_report_card
# ================================================================

class ActionReportCard(Action):
    def name(self) -> Text:
        return "action_report_card"

    def run(self, dispatcher: CollectingDispatcher, tracker: Tracker,
            domain: DomainDict) -> List[Dict[Text, Any]]:

        auth_user = get_authenticated_user(tracker)
        if not auth_user:
            dispatcher.utter_message(text="⚠️ Authentication required.")
            return []

        user_id = auth_user["id"]
        intent = tracker.latest_message.get("intent", {}).get("name", "")
        reason = "stolen" if "stolen" in intent else "lost"

        rows = execute_query(
            "SELECT card_id, card_number, card_network FROM cards WHERE user_id=%s AND status IN ('active','frozen') LIMIT 1",
            (user_id,)
        )

        if not rows:
            dispatcher.utter_message(text="No active card found to report.")
            return []

        card = rows[0]

        execute_query(
            "UPDATE cards SET status='blocked' WHERE card_id=%s",
            (card["card_id"],),
            fetch=False
        )

        ref_id = gen_ref("RPT")

        dispatcher.utter_message(
            text=(
                f"🚨 **Card Reported as {reason.title()}**\n"
                f"Card: {card['card_network']} {mask_card(card['card_number'])}\n"
                f"Status: **Blocked**\n"
                f"Report Reference: {ref_id}\n\n"
                f"✅ A replacement card will be issued within 3–5 business days.\n"
                f"📞 Urgent help: 1-800-BANKBOT"
            )
        )
        return []


# ================================================================
# ACTION: action_check_loan_balance
# ================================================================

class ActionCheckLoanBalance(Action):
    def name(self) -> Text:
        return "action_check_loan_balance"

    def run(self, dispatcher: CollectingDispatcher, tracker: Tracker,
            domain: DomainDict) -> List[Dict[Text, Any]]:

        auth_user = get_authenticated_user(tracker)
        if not auth_user:
            dispatcher.utter_message(text="⚠️ Authentication required.")
            return []

        user_id = auth_user["id"]
        loan_type = tracker.get_slot("loan_type")

        sql = (
            "SELECT loan_id, loan_type, original_amount, outstanding_balance, interest_rate, monthly_payment, next_due_date "
            "FROM loans WHERE user_id=%s AND status='active'"
        )
        params = [user_id]

        if loan_type:
            sql += " AND loan_type=%s"
            params.append(loan_type)

        rows = execute_query(sql, tuple(params))

        if not rows:
            dispatcher.utter_message(text="No active loans found on your account.")
            return [SlotSet("loan_type", None)]

        lines = [f"🏦 **Your Loans ({len(rows)} active):**\n"]
        for r in rows:
            paid = safe_float(r["original_amount"]) - safe_float(r["outstanding_balance"])
            pct = (paid / safe_float(r["original_amount"]) * 100) if safe_float(r["original_amount"]) else 0

            lines.append(
                f"📋 **{r['loan_type'].title()} Loan** (ID: {r['loan_id']})\n"
                f"   Original: {fmt_currency(r['original_amount'])}\n"
                f"   Outstanding: {fmt_currency(r['outstanding_balance'])}\n"
                f"   Paid: {pct:.1f}%\n"
                f"   Rate: {r['interest_rate']}% p.a.\n"
                f"   Monthly EMI: {fmt_currency(r['monthly_payment'])}\n"
                f"   Next Due: {r['next_due_date']}\n"
            )

        dispatcher.utter_message(text="\n".join(lines))
        return [SlotSet("loan_type", None)]


# ================================================================
# ACTION: action_apply_for_loan
# ================================================================

class ActionApplyForLoan(Action):
    def name(self) -> Text:
        return "action_apply_for_loan"

    def run(self, dispatcher: CollectingDispatcher, tracker: Tracker,
            domain: DomainDict) -> List[Dict[Text, Any]]:

        auth_user = get_authenticated_user(tracker)
        if not auth_user:
            dispatcher.utter_message(text="⚠️ Authentication required.")
            return []

        loan_type = tracker.get_slot("loan_type") or "personal"
        amount = safe_float(tracker.get_slot("amount"))

        credit_score = int(auth_user.get("credit_score", 700))

        if amount <= 0:
            dispatcher.utter_message(text="Please provide a valid loan amount.")
            return []

        if credit_score < 600:
            dispatcher.utter_message(
                text=(
                    "❌ We’re unable to approve your loan at this time.\n"
                    "Please contact our loan specialists for further assistance."
                )
            )
            return [SlotSet("loan_type", None), SlotSet("amount", None)]

        rate = 6.5 if credit_score >= 750 else (8.5 if credit_score >= 700 else 11.5)
        monthly_rate = rate / 1200
        emi = (amount * monthly_rate / (1 - (1 + monthly_rate) ** -60)) if amount else 0

        ref_id = gen_ref("LOAN")

        dispatcher.utter_message(
            text=(
                f"✅ **Loan Application Approved!**\n"
                f"Application ID: {ref_id}\n"
                f"Type: {loan_type.title()}\n"
                f"Amount: {fmt_currency(amount)}\n"
                f"Rate: {rate}% p.a.\n"
                f"Term: 60 months\n"
                f"Monthly EMI: {fmt_currency(emi)}\n\n"
                f"Funds will be disbursed within 2–3 business days."
            )
        )

        return [SlotSet("loan_type", None), SlotSet("amount", None)]


# ================================================================
# ACTION: action_make_loan_payment
# ================================================================

class ActionMakeLoanPayment(Action):
    def name(self) -> Text:
        return "action_make_loan_payment"

    def run(self, dispatcher: CollectingDispatcher, tracker: Tracker,
            domain: DomainDict) -> List[Dict[Text, Any]]:

        auth_user = get_authenticated_user(tracker)
        if not auth_user:
            dispatcher.utter_message(text="⚠️ Authentication required.")
            return []

        user_id = auth_user["id"]
        amount = tracker.get_slot("amount")
        loan_type = tracker.get_slot("loan_type")

        sql = (
            "SELECT loan_id, loan_type, outstanding_balance, monthly_payment, next_due_date "
            "FROM loans WHERE user_id=%s AND status='active'"
        )
        params = [user_id]

        if loan_type:
            sql += " AND loan_type=%s"
            params.append(loan_type)

        sql += " LIMIT 1"

        rows = execute_query(sql, tuple(params))
        if not rows:
            dispatcher.utter_message(text="No active loan found.")
            return []

        loan = rows[0]
        pay = safe_float(amount) if amount else safe_float(loan["monthly_payment"])

        if pay <= 0:
            dispatcher.utter_message(text="Please provide a valid loan payment amount.")
            return []

        old_balance = safe_float(loan["outstanding_balance"])
        new_bal = max(0.0, old_balance - pay)
        ref_id = gen_ref("LPAY")

        execute_query(
            "UPDATE loans SET outstanding_balance=%s, next_due_date=DATE_ADD(COALESCE(next_due_date, CURDATE()), INTERVAL 1 MONTH), "
            "status=%s WHERE loan_id=%s",
            (new_bal, "closed" if new_bal == 0 else "active", loan["loan_id"]),
            fetch=False
        )

        execute_query(
            "INSERT INTO loan_payments (loan_id, amount, reference_id) VALUES (%s,%s,%s)",
            (loan["loan_id"], pay, ref_id),
            fetch=False
        )

        paid_off = new_bal == 0.0

        dispatcher.utter_message(
            text=(
                f"✅ **Loan Payment Successful!**\n"
                f"Loan: {loan['loan_type'].title()}\n"
                f"Payment: {fmt_currency(pay)}\n"
                f"New Balance: {fmt_currency(new_bal)}\n"
                f"Reference: {ref_id}\n"
                f"{'🎉 Congratulations — your loan is fully paid off!' if paid_off else ''}"
            )
        )

        return [SlotSet("amount", None), SlotSet("loan_type", None)]


# ================================================================
# ACTION: action_view_loan_repayment
# ================================================================

class ActionViewLoanRepayment(Action):
    def name(self) -> Text:
        return "action_view_loan_repayment"

    def run(self, dispatcher: CollectingDispatcher, tracker: Tracker,
            domain: DomainDict) -> List[Dict[Text, Any]]:

        auth_user = get_authenticated_user(tracker)
        if not auth_user:
            dispatcher.utter_message(text="⚠️ Authentication required.")
            return []

        user_id = auth_user["id"]

        rows = execute_query(
            "SELECT loan_type, monthly_payment, next_due_date FROM loans "
            "WHERE user_id=%s AND status='active' ORDER BY next_due_date ASC",
            (user_id,)
        )

        if not rows:
            dispatcher.utter_message(text="No active loan repayment schedule found.")
            return []

        lines = ["📅 **Loan Repayment Schedule:**\n"]
        for r in rows:
            lines.append(
                f"• **{r['loan_type'].title()} Loan** — "
                f"EMI: {fmt_currency(r['monthly_payment'])} | "
                f"Next Due: {r['next_due_date']}"
            )

        dispatcher.utter_message(text="\n".join(lines))
        return []


# ================================================================
# ACTION: action_view_portfolio
# ================================================================

class ActionViewPortfolio(Action):
    def name(self) -> Text:
        return "action_view_portfolio"

    def run(self, dispatcher: CollectingDispatcher, tracker: Tracker,
            domain: DomainDict) -> List[Dict[Text, Any]]:

        auth_user = get_authenticated_user(tracker)
        if not auth_user:
            dispatcher.utter_message(text="⚠️ Authentication required.")
            return []

        user_id = auth_user["id"]

        rows = execute_query(
            "SELECT i.symbol, i.company_name, ih.quantity, ih.avg_buy_price, i.current_price, i.change_percent "
            "FROM investment_holdings ih "
            "JOIN investments i ON ih.investment_id=i.investment_id "
            "WHERE ih.user_id=%s ORDER BY (ih.quantity * i.current_price) DESC",
            (user_id,)
        )

        if not rows:
            dispatcher.utter_message(text="Your investment portfolio is empty.")
            return []

        total_val = sum(safe_float(r["quantity"]) * safe_float(r["current_price"]) for r in rows)
        total_cost = sum(safe_float(r["quantity"]) * safe_float(r["avg_buy_price"]) for r in rows)
        total_gain = total_val - total_cost
        gain_pct = (total_gain / total_cost * 100) if total_cost else 0

        lines = [
            "📈 **Investment Portfolio**\n",
            f"Total Value: {fmt_currency(total_val)}",
            f"Total Gain/Loss: {'+' if total_gain >= 0 else ''}{fmt_currency(total_gain)} ({gain_pct:+.2f}%)\n",
            "**Holdings:**",
        ]

        for r in rows:
            val = safe_float(r["quantity"]) * safe_float(r["current_price"])
            emoji = "📈" if safe_float(r["change_percent"]) >= 0 else "📉"
            lines.append(
                f"{emoji} **{r['symbol']}** ({r['company_name']}) | "
                f"Qty: {r['quantity']} | "
                f"Price: {fmt_currency(r['current_price'])} "
                f"({safe_float(r['change_percent']):+.2f}%) | "
                f"Value: {fmt_currency(val)}"
            )

        dispatcher.utter_message(text="\n".join(lines))
        return []


# ================================================================
# ACTION: action_view_investment_performance
# ================================================================

class ActionViewInvestmentPerformance(Action):
    def name(self) -> Text:
        return "action_view_investment_performance"

    def run(self, dispatcher: CollectingDispatcher, tracker: Tracker,
            domain: DomainDict) -> List[Dict[Text, Any]]:

        auth_user = get_authenticated_user(tracker)
        if not auth_user:
            dispatcher.utter_message(text="⚠️ Authentication required.")
            return []

        user_id = auth_user["id"]

        rows = execute_query(
            "SELECT SUM(ih.quantity*i.current_price) AS current_value, "
            "SUM(ih.quantity*ih.avg_buy_price) AS cost_basis, "
            "SUM(i.change_percent*ih.quantity*i.current_price) / NULLIF(SUM(ih.quantity*i.current_price),0) AS weighted_change "
            "FROM investment_holdings ih "
            "JOIN investments i ON ih.investment_id=i.investment_id "
            "WHERE ih.user_id=%s",
            (user_id,)
        )

        if not rows or not rows[0]["current_value"]:
            dispatcher.utter_message(text="No investment performance data available.")
            return []

        r = rows[0]
        cur = safe_float(r["current_value"])
        cost = safe_float(r["cost_basis"])
        gain = cur - cost
        gain_pct = (gain / cost * 100) if cost else 0
        today_chg = safe_float(r["weighted_change"])

        dispatcher.utter_message(
            text=(
                f"📊 **Performance Summary**\n\n"
                f"Portfolio Value:  {fmt_currency(cur)}\n"
                f"Cost Basis:       {fmt_currency(cost)}\n"
                f"Total Return:     {fmt_currency(gain)} ({gain_pct:+.2f}%)\n"
                f"Today's Change:   {today_chg:+.2f}%\n\n"
                f"{'🟢 Up today!' if today_chg >= 0 else '🔴 Down today.'}"
            )
        )
        return []


# ================================================================
# ACTION: action_view_fixed_deposits
# ================================================================

class ActionViewFixedDeposits(Action):
    def name(self) -> Text:
        return "action_view_fixed_deposits"

    def run(self, dispatcher: CollectingDispatcher, tracker: Tracker,
            domain: DomainDict) -> List[Dict[Text, Any]]:

        auth_user = get_authenticated_user(tracker)
        if not auth_user:
            dispatcher.utter_message(text="⚠️ Authentication required.")
            return []

        user_id = auth_user["id"]

        rows = execute_query(
            "SELECT fd_id, principal_amount, interest_rate, tenure_months, start_date, maturity_date, maturity_amount, status "
            "FROM fixed_deposits WHERE user_id=%s ORDER BY maturity_date ASC",
            (user_id,)
        )

        if not rows:
            dispatcher.utter_message(text="No fixed deposits found on your profile.")
            return []

        lines = [f"🏦 **Your Fixed Deposits ({len(rows)} total):**\n"]
        for fd in rows:
            mat_date = fd["maturity_date"]
            days_left = (mat_date - date.today()).days if mat_date else 0
            lines.append(
                f"📋 **FD #{fd['fd_id']}** — {fd['status'].title()}\n"
                f"   Principal: {fmt_currency(fd['principal_amount'])}\n"
                f"   Rate: {fd['interest_rate']}% p.a. | Tenure: {fd['tenure_months']} months\n"
                f"   Matures: {mat_date} ({max(0, days_left)} days left)\n"
                f"   Maturity Value: {fmt_currency(fd['maturity_amount'])}\n"
            )

        dispatcher.utter_message(text="\n".join(lines))
        return []


# ================================================================
# ACTION: action_change_password
# ================================================================

class ActionChangePassword(Action):
    def name(self) -> Text:
        return "action_change_password"

    def run(self, dispatcher: CollectingDispatcher, tracker: Tracker,
            domain: DomainDict) -> List[Dict[Text, Any]]:
        dispatcher.utter_message(
            text=(
                "🔐 **Password / PIN Change**\n\n"
                "For your security, this must be done through our secure portal.\n\n"
                "📧 A verification link has been sent to your registered email.\n"
                "⏱️ The link expires in **15 minutes**.\n\n"
                "If you didn't request this, call us immediately: 1-800-BANKBOT"
            )
        )
        return []


# ================================================================
# ACTION: action_find_branch
# ================================================================

class ActionFindBranch(Action):
    def name(self) -> Text:
        return "action_find_branch"

    def run(self, dispatcher: CollectingDispatcher, tracker: Tracker,
            domain: DomainDict) -> List[Dict[Text, Any]]:

        location = tracker.get_slot("branch_location") or "your area"

        rows = execute_query(
            "SELECT branch_name, address, city, state, phone, opening_time, closing_time, has_atm, has_locker "
            "FROM branches WHERE (city LIKE %s OR branch_name LIKE %s OR state LIKE %s) AND status='open' "
            "ORDER BY branch_name LIMIT 5",
            (f"%{location}%", f"%{location}%", f"%{location}%")
        )

        if not rows:
            dispatcher.utter_message(
                text=f"🏦 No branches found in '{location}'. Please try another city or area."
            )
            return [SlotSet("branch_location", None)]

        lines = [f"🏦 **Branches near {location}:**\n"]
        for b in rows:
            lines.append(
                f"📍 **{b['branch_name']}**\n"
                f"   {b['address']}, {b['city']}, {b['state'] or ''}\n"
                f"   Hours: {b['opening_time']} – {b['closing_time']}\n"
                f"   Phone: {b['phone'] or 'N/A'}\n"
                f"   ATM: {'✅' if b['has_atm'] else '❌'} | Locker: {'✅' if b['has_locker'] else '❌'}\n"
            )

        dispatcher.utter_message(text="\n".join(lines))
        return [SlotSet("branch_location", None)]


# ================================================================
# ACTION: action_find_atm
# ================================================================

class ActionFindATM(Action):
    def name(self) -> Text:
        return "action_find_atm"

    def run(self, dispatcher: CollectingDispatcher, tracker: Tracker,
            domain: DomainDict) -> List[Dict[Text, Any]]:

        location = tracker.get_slot("branch_location") or "your area"

        rows = execute_query(
            "SELECT location_name, address, city, state, is_24hr, features "
            "FROM atms WHERE (city LIKE %s OR location_name LIKE %s OR state LIKE %s) AND status='operational' "
            "ORDER BY location_name LIMIT 5",
            (f"%{location}%", f"%{location}%", f"%{location}%")
        )

        if not rows:
            dispatcher.utter_message(text=f"🏧 No operational ATMs found in '{location}'.")
            return [SlotSet("branch_location", None)]

        lines = [f"🏧 **ATMs near {location}:**\n"]
        for a in rows:
            lines.append(
                f"📍 **{a['location_name']}**\n"
                f"   {a['address']}, {a['city']}, {a['state'] or ''}\n"
                f"   24/7: {'✅' if a['is_24hr'] else '❌'}\n"
                f"   Features: {a['features'] or 'Standard'}\n"
            )

        dispatcher.utter_message(text="\n".join(lines))
        return [SlotSet("branch_location", None)]


# ================================================================
# ACTION: action_view_exchange_rates
# ================================================================

class ActionViewExchangeRates(Action):
    def name(self) -> Text:
        return "action_view_exchange_rates"

    def run(self, dispatcher: CollectingDispatcher, tracker: Tracker,
            domain: DomainDict) -> List[Dict[Text, Any]]:

        rows = execute_query(
            "SELECT from_currency, to_currency, rate, updated_at "
            "FROM exchange_rates WHERE from_currency='USD' ORDER BY to_currency LIMIT 12"
        )

        if not rows:
            dispatcher.utter_message(text="Exchange rate data is temporarily unavailable.")
            return []

        lines = ["💱 **Live Exchange Rates (Base: USD)**\n"]
        for r in rows:
            lines.append(f"1 USD = {safe_float(r['rate']):.4f} {r['to_currency']}")
        lines.append(f"\n_Updated: {rows[0]['updated_at']}_")

        dispatcher.utter_message(text="\n".join(lines))
        return []


# ================================================================
# ACTION: action_download_statement
# ================================================================

class ActionDownloadStatement(Action):
    def name(self) -> Text:
        return "action_download_statement"

    def run(self, dispatcher: CollectingDispatcher, tracker: Tracker,
            domain: DomainDict) -> List[Dict[Text, Any]]:

        auth_user = get_authenticated_user(tracker)
        if not auth_user:
            dispatcher.utter_message(text="⚠️ Authentication required.")
            return []

        date_filter = tracker.get_slot("date")
        time_period = tracker.get_slot("time_period")
        period_label = date_filter or time_period or "Last 30 days"
        ref_id = gen_ref("STMT")

        dispatcher.utter_message(
            text=(
                f"📄 **Statement Request Submitted**\n"
                f"Period: {period_label}\n"
                f"Reference: {ref_id}\n\n"
                f"Your account statement will be available shortly in the secure portal."
            )
        )

        return [SlotSet("date", None), SlotSet("time_period", None)]


# ================================================================
# ACTION: action_dispute_transaction
# ================================================================

class ActionDisputeTransaction(Action):
    def name(self) -> Text:
        return "action_dispute_transaction"

    def run(self, dispatcher: CollectingDispatcher, tracker: Tracker,
            domain: DomainDict) -> List[Dict[Text, Any]]:

        auth_user = get_authenticated_user(tracker)
        if not auth_user:
            dispatcher.utter_message(text="⚠️ Authentication required.")
            return []

        user_id = auth_user["id"]
        txn_id = tracker.get_slot("transaction_id")
        reason = tracker.get_slot("dispute_reason") or "Transaction dispute"

        ref_id = gen_ref("DSP")

        execute_query(
            "INSERT INTO disputes (user_id, transaction_id, reference_id, reason, status) VALUES (%s,%s,%s,%s,'pending')",
            (user_id, txn_id, ref_id, reason),
            fetch=False
        )

        dispatcher.utter_message(
            text=(
                f"⚠️ **Dispute Raised Successfully**\n"
                f"Transaction ID: {txn_id or 'Not provided'}\n"
                f"Reason: {reason}\n"
                f"Reference: **{ref_id}**\n\n"
                f"Our team will review it and update you soon."
            )
        )

        return [SlotSet("transaction_id", None), SlotSet("dispute_reason", None)]


# ================================================================
# ACTION: action_view_scheduled_transfers
# ================================================================

class ActionViewScheduledTransfers(Action):
    def name(self) -> Text:
        return "action_view_scheduled_transfers"

    def run(self, dispatcher: CollectingDispatcher, tracker: Tracker,
            domain: DomainDict) -> List[Dict[Text, Any]]:

        auth_user = get_authenticated_user(tracker)
        if not auth_user:
            dispatcher.utter_message(text="⚠️ Authentication required.")
            return []

        user_id = auth_user["id"]

        rows = execute_query(
            "SELECT transfer_id, recipient_name, recipient_account, amount, frequency, next_execution_date, status "
            "FROM scheduled_transfers WHERE user_id=%s ORDER BY next_execution_date ASC",
            (user_id,)
        )

        if not rows:
            dispatcher.utter_message(text="You do not have any scheduled transfers.")
            return []

        lines = [f"🔁 **Scheduled Transfers ({len(rows)} total):**\n"]
        for r in rows:
            lines.append(
                f"• ID: **{r['transfer_id']}** | To: {r['recipient_name']} ({mask_account(r['recipient_account'] or '')})\n"
                f"  Amount: {fmt_currency(r['amount'])} | Frequency: {r['frequency'].title()} | "
                f"Next: {r['next_execution_date']} | Status: {r['status'].title()}\n"
            )

        dispatcher.utter_message(text="\n".join(lines))
        return []


# ================================================================
# ACTION: action_cancel_transfer
# ================================================================

class ActionCancelTransfer(Action):
    def name(self) -> Text:
        return "action_cancel_transfer"

    def run(self, dispatcher: CollectingDispatcher, tracker: Tracker,
            domain: DomainDict) -> List[Dict[Text, Any]]:

        auth_user = get_authenticated_user(tracker)
        if not auth_user:
            dispatcher.utter_message(text="⚠️ Authentication required.")
            return []

        user_id = auth_user["id"]
        transfer_id = tracker.get_slot("transfer_id")

        if not transfer_id:
            dispatcher.utter_message(text="Please provide the scheduled transfer ID you want to cancel.")
            return []

        rows = execute_query(
            "SELECT transfer_id, recipient_name, amount, status FROM scheduled_transfers WHERE user_id=%s AND transfer_id=%s LIMIT 1",
            (user_id, transfer_id)
        )

        if not rows:
            dispatcher.utter_message(text="No matching scheduled transfer found.")
            return [SlotSet("transfer_id", None)]

        transfer = rows[0]

        execute_query(
            "UPDATE scheduled_transfers SET status='cancelled' WHERE transfer_id=%s",
            (transfer_id,),
            fetch=False
        )

        dispatcher.utter_message(
            text=(
                f"❌ **Scheduled Transfer Cancelled**\n"
                f"Transfer ID: {transfer_id}\n"
                f"Recipient: {transfer['recipient_name']}\n"
                f"Amount: {fmt_currency(transfer['amount'])}"
            )
        )

        return [SlotSet("transfer_id", None)]


# ================================================================
# ACTION: action_setup_autopay
# ================================================================

class ActionSetupAutopay(Action):
    def name(self) -> Text:
        return "action_setup_autopay"

    def run(self, dispatcher: CollectingDispatcher, tracker: Tracker,
            domain: DomainDict) -> List[Dict[Text, Any]]:

        auth_user = get_authenticated_user(tracker)
        if not auth_user:
            dispatcher.utter_message(text="⚠️ Authentication required.")
            return []

        user_id = auth_user["id"]
        recipient_name = tracker.get_slot("recipient_name") or "AutoPay Recipient"
        recipient_account = tracker.get_slot("recipient_account")
        amount = safe_float(tracker.get_slot("amount"))
        frequency = (tracker.get_slot("frequency") or "monthly").lower()

        if amount <= 0:
            dispatcher.utter_message(text="Please provide a valid AutoPay amount.")
            return []

        next_date = date.today() + timedelta(days=30 if frequency == "monthly" else 7)

        execute_query(
            "INSERT INTO scheduled_transfers (user_id, recipient_name, recipient_account, amount, frequency, next_execution_date, status) "
            "VALUES (%s,%s,%s,%s,%s,%s,'active')",
            (user_id, recipient_name, recipient_account, amount, frequency, next_date),
            fetch=False
        )

        dispatcher.utter_message(
            text=(
                f"✅ **AutoPay Set Successfully**\n"
                f"Recipient: {recipient_name}\n"
                f"Amount: {fmt_currency(amount)}\n"
                f"Frequency: {frequency.title()}\n"
                f"Next Execution: {next_date}"
            )
        )

        return [
            SlotSet("recipient_name", None),
            SlotSet("recipient_account", None),
            SlotSet("amount", None),
            SlotSet("frequency", None),
        ]


# ================================================================
# ACTION: action_set_alert
# ================================================================

class ActionSetAlert(Action):
    def name(self) -> Text:
        return "action_set_alert"

    def run(self, dispatcher: CollectingDispatcher, tracker: Tracker,
            domain: DomainDict) -> List[Dict[Text, Any]]:

        auth_user = get_authenticated_user(tracker)
        if not auth_user:
            dispatcher.utter_message(text="⚠️ Authentication required.")
            return []

        user_id = auth_user["id"]
        alert_type = tracker.get_slot("alert_type") or "balance"
        threshold = tracker.get_slot("amount")

        threshold_amount = safe_float(threshold) if threshold else None

        execute_query(
            "INSERT INTO alerts (user_id, alert_type, threshold_amount, is_enabled) VALUES (%s,%s,%s,1)",
            (user_id, alert_type, threshold_amount),
            fetch=False
        )

        dispatcher.utter_message(
            text=(
                f"🔔 **Alert Set Successfully**\n"
                f"Type: {alert_type.title()}\n"
                f"{f'Threshold: {fmt_currency(threshold_amount)}' if threshold_amount is not None else ''}\n"
                f"Status: Enabled"
            )
        )

        return [SlotSet("alert_type", None), SlotSet("amount", None)]


# ================================================================
# FORM VALIDATORS
# ================================================================

class ValidateTransferForm(FormValidationAction):
    def name(self) -> Text:
        return "validate_transfer_form"

    def validate_amount(
        self,
        slot_value: Any,
        dispatcher: CollectingDispatcher,
        tracker: Tracker,
        domain: DomainDict,
    ) -> Dict[Text, Any]:
        try:
            amt = float(slot_value)
            if amt <= 0:
                dispatcher.utter_message(text="Amount must be greater than zero.")
                return {"amount": None}
            return {"amount": amt}
        except Exception:
            dispatcher.utter_message(text="Please enter a valid amount.")
            return {"amount": None}

    def validate_recipient_account(
        self,
        slot_value: Any,
        dispatcher: CollectingDispatcher,
        tracker: Tracker,
        domain: DomainDict,
    ) -> Dict[Text, Any]:
        acct = str(slot_value).strip()
        if not acct.isdigit() or len(acct) < 8:
            dispatcher.utter_message(text="Please enter a valid recipient account number.")
            return {"recipient_account": None}
        return {"recipient_account": acct}


class ValidateBillPaymentForm(FormValidationAction):
    def name(self) -> Text:
        return "validate_bill_payment_form"

    def validate_amount(
        self,
        slot_value: Any,
        dispatcher: CollectingDispatcher,
        tracker: Tracker,
        domain: DomainDict,
    ) -> Dict[Text, Any]:
        try:
            amt = float(slot_value)
            if amt <= 0:
                dispatcher.utter_message(text="Bill amount must be greater than zero.")
                return {"amount": None}
            return {"amount": amt}
        except Exception:
            dispatcher.utter_message(text="Please enter a valid bill amount.")
            return {"amount": None}


class ValidateLoanApplicationForm(FormValidationAction):
    def name(self) -> Text:
        return "validate_loan_application_form"

    def validate_amount(
        self,
        slot_value: Any,
        dispatcher: CollectingDispatcher,
        tracker: Tracker,
        domain: DomainDict,
    ) -> Dict[Text, Any]:
        try:
            amt = float(slot_value)
            if amt < 1000:
                dispatcher.utter_message(text="Loan amount should be at least ₹1,000.")
                return {"amount": None}
            return {"amount": amt}
        except Exception:
            dispatcher.utter_message(text="Please enter a valid loan amount.")
            return {"amount": None}


# ================================================================
# ACTION: action_view_account_details
# ================================================================

class ActionViewAccountDetails(Action):
    def name(self) -> Text:
        return "action_view_account_details"

    def run(self, dispatcher: CollectingDispatcher, tracker: Tracker,
            domain: DomainDict) -> List[Dict[Text, Any]]:

        auth_user = get_authenticated_user(tracker)
        if not auth_user:
            dispatcher.utter_message(text="⚠️ Session error — please log in again.")
            return []

        user_id = auth_user["id"]

        rows = execute_query(
            "SELECT account_type, account_number, balance, currency, status, created_at "
            "FROM accounts WHERE user_id=%s AND status='active' ORDER BY account_type",
            (user_id,)
        )

        if not rows:
            dispatcher.utter_message(text="No active accounts found on your profile.")
            return []

        lines = [
            f"👤 **Account Holder:** {auth_user.get('full_name', 'N/A')}\n",
            f"📧 Email: {auth_user.get('email', 'N/A')}",
            f"📱 Phone: {auth_user.get('phone', 'N/A')}\n",
            "🏦 **Accounts:**",
        ]
        for r in rows:
            lines.append(
                f"• **{r['account_type'].title()}** — "
                f"Acct: {mask_account(r['account_number'])} | "
                f"Balance: {fmt_currency(r['balance'], r['currency'])} | "
                f"Status: {r['status'].title()}"
            )

        dispatcher.utter_message(text="\n".join(lines))
        return []


# ================================================================
# ACTION: action_view_all_accounts
# ================================================================

class ActionViewAllAccounts(Action):
    def name(self) -> Text:
        return "action_view_all_accounts"

    def run(self, dispatcher: CollectingDispatcher, tracker: Tracker,
            domain: DomainDict) -> List[Dict[Text, Any]]:

        auth_user = get_authenticated_user(tracker)
        if not auth_user:
            dispatcher.utter_message(text="⚠️ Authentication required.")
            return []

        user_id = auth_user["id"]

        rows = execute_query(
            "SELECT account_type, account_number, balance, currency, status "
            "FROM accounts WHERE user_id=%s ORDER BY account_type",
            (user_id,)
        )

        if not rows:
            dispatcher.utter_message(text="No accounts found on your profile.")
            return []

        lines = [f"💼 **All Your Accounts ({len(rows)} total):**\n"]
        total = 0.0
        currency = "INR"
        for r in rows:
            emoji = "✅" if r["status"] == "active" else "🔒"
            lines.append(
                f"{emoji} **{r['account_type'].title()}**\n"
                f"   Account: {mask_account(r['account_number'])}\n"
                f"   Balance: {fmt_currency(r['balance'], r['currency'])}\n"
                f"   Status: {r['status'].title()}"
            )
            if r["status"] == "active":
                total += safe_float(r["balance"])
            currency = r["currency"]

        lines.append(f"\n💰 **Combined Active Balance: {fmt_currency(total, currency)}**")
        dispatcher.utter_message(text="\n".join(lines))
        return []


# ================================================================
# ACTION: action_open_account
# ================================================================

class ActionOpenAccount(Action):
    def name(self) -> Text:
        return "action_open_account"

    def run(self, dispatcher: CollectingDispatcher, tracker: Tracker,
            domain: DomainDict) -> List[Dict[Text, Any]]:

        auth_user = get_authenticated_user(tracker)
        if not auth_user:
            dispatcher.utter_message(text="⚠️ Authentication required.")
            return []

        account_type = tracker.get_slot("account_type") or "savings"
        ref_id = gen_ref("ACC")

        dispatcher.utter_message(
            text=(
                f"✅ **Account Opening Request Submitted**\n"
                f"Type: {account_type.title()} Account\n"
                f"Reference: {ref_id}\n\n"
                f"Our team will review your application and contact you within 1–2 business days.\n"
                f"📧 A confirmation has been sent to your registered email."
            )
        )
        return [SlotSet("account_type", None)]


# ================================================================
# ACTION: action_view_bills
# ================================================================

class ActionViewBills(Action):
    def name(self) -> Text:
        return "action_view_bills"

    def run(self, dispatcher: CollectingDispatcher, tracker: Tracker,
            domain: DomainDict) -> List[Dict[Text, Any]]:

        auth_user = get_authenticated_user(tracker)
        if not auth_user:
            dispatcher.utter_message(text="⚠️ Authentication required.")
            return []

        user_id = auth_user["id"]

        rows = execute_query(
            "SELECT biller_name, bill_type, amount, due_date, status "
            "FROM bills WHERE user_id=%s ORDER BY due_date ASC LIMIT 10",
            (user_id,)
        )

        if not rows:
            dispatcher.utter_message(text="No upcoming bills found.")
            return []

        lines = [f"📄 **Your Upcoming Bills ({len(rows)} total):**\n"]
        for b in rows:
            emoji = "⚠️" if b["status"] == "overdue" else "🔔" if b["status"] == "pending" else "✅"
            lines.append(
                f"{emoji} **{b['biller_name']}** ({b['bill_type'] or 'General'})\n"
                f"   Amount: {fmt_currency(b['amount'])} | Due: {b['due_date']} | Status: {b['status'].title()}"
            )

        dispatcher.utter_message(text="\n".join(lines))
        return []


# ================================================================
# ACTION: action_activate_card
# ================================================================

class ActionActivateCard(Action):
    def name(self) -> Text:
        return "action_activate_card"

    def run(self, dispatcher: CollectingDispatcher, tracker: Tracker,
            domain: DomainDict) -> List[Dict[Text, Any]]:

        auth_user = get_authenticated_user(tracker)
        if not auth_user:
            dispatcher.utter_message(text="⚠️ Authentication required.")
            return []

        user_id = auth_user["id"]
        card_type = tracker.get_slot("card_type")

        sql = "SELECT card_id, card_number, card_network FROM cards WHERE user_id=%s AND status='inactive'"
        params = [user_id]
        if card_type:
            sql += " AND card_type=%s"
            params.append(card_type)
        sql += " LIMIT 1"

        rows = execute_query(sql, tuple(params))

        if not rows:
            dispatcher.utter_message(
                text="No inactive card found to activate. Your cards may already be active."
            )
            return []

        card = rows[0]
        execute_query(
            "UPDATE cards SET status='active' WHERE card_id=%s",
            (card["card_id"],),
            fetch=False
        )

        dispatcher.utter_message(
            text=(
                f"✅ **Card Activated Successfully!**\n"
                f"Card: {card['card_network']} {mask_card(card['card_number'])}\n"
                f"Status: Active — ready for use."
            )
        )
        return [SlotSet("card_type", None)]


# ================================================================
# ACTION: action_request_new_card
# ================================================================

class ActionRequestNewCard(Action):
    def name(self) -> Text:
        return "action_request_new_card"

    def run(self, dispatcher: CollectingDispatcher, tracker: Tracker,
            domain: DomainDict) -> List[Dict[Text, Any]]:

        auth_user = get_authenticated_user(tracker)
        if not auth_user:
            dispatcher.utter_message(text="⚠️ Authentication required.")
            return []

        card_type = tracker.get_slot("card_type") or "debit"
        ref_id = gen_ref("CARD")

        dispatcher.utter_message(
            text=(
                f"📬 **Card Replacement Requested**\n"
                f"Card Type: {card_type.title()}\n"
                f"Reference: {ref_id}\n\n"
                f"✅ Your new card will be delivered to your registered address within 3–5 business days.\n"
                f"You'll receive an SMS once it's dispatched."
            )
        )
        return [SlotSet("card_type", None)]


# ================================================================
# ACTION: action_open_fixed_deposit
# ================================================================

class ActionOpenFixedDeposit(Action):
    def name(self) -> Text:
        return "action_open_fixed_deposit"

    def run(self, dispatcher: CollectingDispatcher, tracker: Tracker,
            domain: DomainDict) -> List[Dict[Text, Any]]:

        auth_user = get_authenticated_user(tracker)
        if not auth_user:
            dispatcher.utter_message(text="⚠️ Authentication required.")
            return []

        user_id = auth_user["id"]
        amount = safe_float(tracker.get_slot("amount"))

        if amount < 1000:
            dispatcher.utter_message(
                text="Minimum FD amount is ₹1,000. Please provide a valid amount."
            )
            return []

        tenure_months = 12
        interest_rate = 7.0
        maturity_amount = amount * (1 + (interest_rate / 100) * (tenure_months / 12))
        start_date = date.today()
        maturity_year = start_date.year + (start_date.month - 1 + tenure_months) // 12
        maturity_month = (start_date.month - 1 + tenure_months) % 12 + 1
        maturity_day = min(start_date.day, 28)
        maturity_date = date(maturity_year, maturity_month, maturity_day)
        ref_id = gen_ref("FD")

        execute_query(
            "INSERT INTO fixed_deposits (user_id, principal_amount, interest_rate, tenure_months, "
            "start_date, maturity_date, maturity_amount, status, reference_id) "
            "VALUES (%s,%s,%s,%s,%s,%s,%s,'active',%s)",
            (user_id, amount, interest_rate, tenure_months,
             start_date, maturity_date, round(maturity_amount, 2), ref_id),
            fetch=False
        )

        dispatcher.utter_message(
            text=(
                f"✅ **Fixed Deposit Created!**\n"
                f"Reference: {ref_id}\n"
                f"Principal: {fmt_currency(amount)}\n"
                f"Interest Rate: {interest_rate}% p.a.\n"
                f"Tenure: {tenure_months} months\n"
                f"Start Date: {start_date}\n"
                f"Maturity Date: {maturity_date}\n"
                f"Maturity Amount: {fmt_currency(round(maturity_amount, 2))}"
            )
        )
        return [SlotSet("amount", None)]


# ================================================================
# ACTION: action_close_fixed_deposit
# ================================================================

class ActionCloseFixedDeposit(Action):
    def name(self) -> Text:
        return "action_close_fixed_deposit"

    def run(self, dispatcher: CollectingDispatcher, tracker: Tracker,
            domain: DomainDict) -> List[Dict[Text, Any]]:

        auth_user = get_authenticated_user(tracker)
        if not auth_user:
            dispatcher.utter_message(text="⚠️ Authentication required.")
            return []

        user_id = auth_user["id"]

        rows = execute_query(
            "SELECT fd_id, principal_amount, maturity_date FROM fixed_deposits "
            "WHERE user_id=%s AND status='active' ORDER BY maturity_date ASC LIMIT 1",
            (user_id,)
        )

        if not rows:
            dispatcher.utter_message(text="No active fixed deposit found to close.")
            return []

        fd = rows[0]
        ref_id = gen_ref("FDCL")
        days_left = (fd["maturity_date"] - date.today()).days if fd["maturity_date"] else 0
        penalty_note = "⚠️ Premature closure penalty of 1% may apply." if days_left > 0 else ""

        execute_query(
            "UPDATE fixed_deposits SET status='closed' WHERE fd_id=%s",
            (fd["fd_id"],),
            fetch=False
        )

        dispatcher.utter_message(
            text=(
                f"🔓 **Fixed Deposit Closed**\n"
                f"FD ID: {fd['fd_id']}\n"
                f"Principal: {fmt_currency(fd['principal_amount'])}\n"
                f"Reference: {ref_id}\n"
                f"{penalty_note}\n"
                f"Funds will be credited to your primary account within 1 business day."
            )
        )
        return []


# ================================================================
# ACTION: action_renew_fixed_deposit
# ================================================================

class ActionRenewFixedDeposit(Action):
    def name(self) -> Text:
        return "action_renew_fixed_deposit"

    def run(self, dispatcher: CollectingDispatcher, tracker: Tracker,
            domain: DomainDict) -> List[Dict[Text, Any]]:

        auth_user = get_authenticated_user(tracker)
        if not auth_user:
            dispatcher.utter_message(text="⚠️ Authentication required.")
            return []

        user_id = auth_user["id"]

        rows = execute_query(
            "SELECT fd_id, principal_amount, interest_rate, tenure_months, maturity_amount "
            "FROM fixed_deposits WHERE user_id=%s AND status='active' "
            "ORDER BY maturity_date ASC LIMIT 1",
            (user_id,)
        )

        if not rows:
            dispatcher.utter_message(text="No active fixed deposit found to renew.")
            return []

        fd = rows[0]
        new_principal = safe_float(fd["maturity_amount"])
        tenure = fd["tenure_months"]
        rate = safe_float(fd["interest_rate"])
        new_maturity = new_principal * (1 + (rate / 100) * (tenure / 12))
        new_start = date.today()
        maturity_year = new_start.year + (new_start.month - 1 + tenure) // 12
        maturity_month = (new_start.month - 1 + tenure) % 12 + 1
        maturity_day = min(new_start.day, 28)
        new_maturity_date = date(maturity_year, maturity_month, maturity_day)
        ref_id = gen_ref("FDRN")

        execute_query(
            "UPDATE fixed_deposits SET principal_amount=%s, maturity_amount=%s, "
            "start_date=%s, maturity_date=%s, status='active' WHERE fd_id=%s",
            (round(new_principal, 2), round(new_maturity, 2),
             new_start, new_maturity_date, fd["fd_id"]),
            fetch=False
        )

        dispatcher.utter_message(
            text=(
                f"🔄 **Fixed Deposit Renewed!**\n"
                f"Reference: {ref_id}\n"
                f"New Principal: {fmt_currency(round(new_principal, 2))}\n"
                f"Rate: {rate}% p.a. | Tenure: {tenure} months\n"
                f"New Maturity Date: {new_maturity_date}\n"
                f"Expected Maturity Value: {fmt_currency(round(new_maturity, 2))}"
            )
        )
        return []