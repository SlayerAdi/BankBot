import yaml
import os

# ============================================================
# PATH RESOLUTION — NO HARDCODING NEEDED
# ============================================================
# All paths below are resolved dynamically relative to THIS file
# (backend/rasa_manager.py), so they work on any machine without
# any changes.
#
# Resolved layout (auto-detected at runtime):
#
#   <project_root>/               <- PROJECT_ROOT
#   ├── backend/
#   │   └── rasa_manager.py       <- this file (__file__)
#   └── rasa/                     <- RASA_DIR
#       ├── domain.yml            <- DOMAIN_FILE
#       └── data/                 <- RASA_DATA_DIR
#           ├── nlu.yml           <- NLU_FILE
#           ├── stories.yml       <- STORIES_FILE
#           └── rules.yml         <- RULES_FILE
#
# If you move the `rasa/` folder to a different location, update
# RASA_DIR below to point to its new absolute path:
#
#   Windows : RASA_DIR = r"C:\Users\YourName\projects\infybot3\rasa"
#   macOS   : RASA_DIR = "/Users/yourname/projects/infybot3/rasa"
#   Linux   : RASA_DIR = "/home/yourname/projects/infybot3/rasa"
#
# Otherwise leave everything as-is — it auto-resolves correctly.
# ============================================================

# backend/ -> project root (one level up from this file)
BASE_DIR     = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
PROJECT_ROOT = BASE_DIR

RASA_DIR      = os.path.join(PROJECT_ROOT, "rasa")
RASA_DATA_DIR = os.path.join(RASA_DIR, "data")

NLU_FILE     = os.path.join(RASA_DATA_DIR, "nlu.yml")
STORIES_FILE = os.path.join(RASA_DATA_DIR, "stories.yml")
RULES_FILE   = os.path.join(RASA_DATA_DIR, "rules.yml")
DOMAIN_FILE  = os.path.join(RASA_DIR, "domain.yml")


def read_yaml(path):
    if not os.path.exists(path):
        return {}
    with open(path, "r", encoding="utf-8") as f:
        return yaml.safe_load(f) or {}


# ============================================================
# YAML BLOCK STRING SUPPORT FOR RASA EXAMPLES
# ============================================================

class LiteralStr(str):
    pass


def literal_str_representer(dumper, data):
    return dumper.represent_scalar("tag:yaml.org,2002:str", data, style="|")


yaml.add_representer(LiteralStr, literal_str_representer)


def convert_examples_to_literal(data):
    """
    Recursively convert any `examples` field into YAML literal block style.
    This ensures Rasa gets:

    examples: |
      - hello
      - hi

    instead of ugly broken quoted strings.
    """
    if isinstance(data, dict):
        new_data = {}
        for k, v in data.items():
            if k == "examples" and isinstance(v, str):
                new_data[k] = LiteralStr(v)
            else:
                new_data[k] = convert_examples_to_literal(v)
        return new_data
    elif isinstance(data, list):
        return [convert_examples_to_literal(item) for item in data]
    return data


def write_yaml(path, data):
    os.makedirs(os.path.dirname(path), exist_ok=True)

    # Convert examples into proper block strings
    data = convert_examples_to_literal(data)

    with open(path, "w", encoding="utf-8") as f:
        yaml.dump(
            data,
            f,
            allow_unicode=True,
            sort_keys=False,
            width=1000,
            default_flow_style=False,
        )


def ensure_version(data, version="3.1"):
    if "version" not in data:
        data["version"] = version
    return data
