# 🤖 InfyBot v3

<div align="center">

**Production-grade Enterprise AI Chatbot Platform**

[![Python](https://img.shields.io/badge/Python-3.10-blue?logo=python)](https://python.org)
[![FastAPI](https://img.shields.io/badge/FastAPI-0.111-green?logo=fastapi)](https://fastapi.tiangolo.com)
[![React](https://img.shields.io/badge/React-18-blue?logo=react)](https://reactjs.org)
[![Rasa](https://img.shields.io/badge/Rasa-3.6-purple)](https://rasa.com)
[![MySQL](https://img.shields.io/badge/MySQL-8.0-orange?logo=mysql)](https://mysql.com)
[![License](https://img.shields.io/badge/License-MIT-yellow)](LICENSE)

*A full-stack AI chatbot system with role-based access control, real-time NLP via Rasa, and an admin analytics dashboard.*

</div>

---

## 📋 Table of Contents

- [Overview](#-overview)
- [Features](#-features)
- [Tech Stack](#-tech-stack)
- [Architecture](#-architecture)
- [Project Structure](#-project-structure)
- [Prerequisites](#-prerequisites)
- [Installation & Setup](#-installation--setup)
- [Path Configuration Guide](#-path-configuration-guide)
- [Access Control Model](#-access-control-model)
- [Default Credentials](#-default-credentials)
- [API Reference](#-api-reference)
- [Database Schema](#-database-schema)
- [Security](#-security)
- [Contributing](#-contributing)

---

## 🌟 Overview

InfyBot v3 is an enterprise-grade AI chatbot platform built with a **FastAPI** backend, **React** frontend, and **Rasa NLP** engine. Users log in with a unique account number (not email), and admins can granularly control who sees the analytics dashboard and who can only chat.

---

## ✨ Features

- 🔐 **Account-number-based login** — auto-assigned IDs (ADM-XXXX / USR-XXXX), harder to enumerate than email
- 🧠 **Rasa NLP integration** — BERT (LaBSE) + DIETClassifier + TEDPolicy dialogue pipeline
- 📊 **Admin analytics dashboard** — KPIs, intent charts, paginated message logs, CSV export
- 👥 **Granular RBAC** — Admin / Agent / Viewer roles + separate dashboard access levels
- 💬 **Multi-session chat** — Create, switch between, and delete chat sessions
- 👍👎 **Per-message feedback** — Thumbs up/down rating on bot responses
- 🚦 **Rate limiting** — 200 req/min per IP via slowapi
- 📁 **CSV export** — Export filtered message logs and user lists
- ⚡ **Async MySQL** — Non-blocking aiomysql connection pool

---

## 🛠️ Tech Stack

| Layer        | Technology                                                   |
|--------------|--------------------------------------------------------------|
| **Backend**  | Python 3.10, FastAPI 0.111, Uvicorn, aiomysql               |
| **Auth**     | python-jose (JWT / HS256), passlib + bcrypt                  |
| **Frontend** | React 18, React Router 6, Recharts, Axios, date-fns          |
| **NLP**      | Rasa 3.6, DIETClassifier, TEDPolicy, LaBSE (BERT)            |
| **Database** | MySQL 8.0 (async connection pool)                            |
| **Utilities**| pandas (CSV export), slowapi (rate limiting), PyYAML         |

---

## 🏗️ Architecture

```
┌─────────────────────┐     HTTP      ┌──────────────────────┐
│   React Frontend    │◄─────────────►│   FastAPI Backend    │
│   localhost:3000    │               │   localhost:8000     │
└─────────────────────┘               └──────────┬───────────┘
                                                 │
                          ┌──────────────────────┼────────────────────┐
                          │                      │                    │
                 ┌────────▼──────┐    ┌──────────▼──────┐  ┌─────────▼──────┐
                 │   MySQL 8.0   │    │   Rasa NLP      │  │  JWT / bcrypt  │
                 │ localhost:3306│    │ localhost:5005  │  │   Auth Layer   │
                 └───────────────┘    └─────────────────┘  └────────────────┘
```

---

## 📁 Project Structure

```
infybot3/
├── backend/
│   ├── routes/
│   │   ├── auth.py           # Login, register, /me, change-password
│   │   ├── chat.py           # Sessions, messages, Rasa bridge, feedback
│   │   ├── admin.py          # Dashboard KPIs, user mgmt, logs, CSV export
│   │   └── rasa_admin.py     # Manage Rasa intents/stories via API
│   ├── auth.py               # JWT helpers + bcrypt + route guards
│   ├── config.py             # Pydantic settings loaded from .env
│   ├── database.py           # Async aiomysql connection pool
│   ├── dependencies.py       # FastAPI dependency injectors
│   ├── main.py               # App entry point, CORS, rate limiter
│   ├── rasa_manager.py       # Read/write Rasa YAML files (paths auto-resolved)
│   ├── requirements.txt      # Python dependencies (pinned)
│   └── .env.example          # Environment variable template → copy to .env
│
├── frontend/
│   ├── public/index.html
│   └── src/
│       ├── context/AuthContext.js      # Auth state, axios base URL config
│       ├── pages/
│       │   ├── LoginPage.js
│       │   ├── RegisterPage.js
│       │   ├── ChatPage.js
│       │   └── DashboardPage.js
│       ├── App.js
│       ├── App.css
│       └── index.js
│
├── rasa/
│   ├── actions/actions.py    # Custom action server (DB via env vars)
│   ├── data/
│   │   ├── nlu.yml
│   │   ├── stories.yml
│   │   └── rules.yml
│   ├── domain.yml
│   ├── config.yml
│   ├── endpoints.yml         # Action server URL config
│   ├── requirements.txt      # Rasa-specific Python dependencies
│   └── .env.example          # Rasa DB env vars template → copy to .env
│
├── database/
│   ├── schema.sql            # Full schema + views + seed admin user
│   └── seed.sql              # Additional demo data
│
└── README.md
```

---

## 📦 Prerequisites

| Tool     | Min Version | Notes                                                        |
|----------|-------------|--------------------------------------------------------------|
| Python   | **3.10**    | Backend + Rasa — **3.11+ is NOT supported by Rasa 3.6**     |
| Node.js  | 18          | Frontend                                                     |
| npm      | 9           | Frontend package manager                                     |
| MySQL    | 8.0         | Database server                                              |

> ⚠️ **Python version is critical for Rasa.** Run `python3.10 --version` to confirm before creating Rasa virtual environments.

---

## 🚀 Installation & Setup

### 1. Clone the Repository

```bash
git clone https://github.com/your-username/infybot3.git
cd infybot3
```

---

### 2. Set Up the MySQL Database

```bash
mysql -u root -p < database/schema.sql
```

Or manually in the MySQL shell:

```sql
CREATE DATABASE infybot_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE infybot_db;
SOURCE /full/path/to/infybot3/database/schema.sql;
```

---

### 3. Configure & Start the Backend

```bash
cd backend
cp .env.example .env
```

Open `backend/.env` and set **at minimum**:

```env
DB_PASSWORD=your_mysql_password
SECRET_KEY=a_very_long_random_string_at_least_32_chars
```

> 💡 Generate a secure key: `python -c "import secrets; print(secrets.token_hex(32))"`

**Create a virtual environment and install dependencies:**

```bash
# Linux / macOS
python3.10 -m venv venv
source venv/bin/activate

# Windows (PowerShell)
python -m venv venv
venv\Scripts\activate

pip install -r requirements.txt
```

**Start the backend server:**

```bash
uvicorn main:app --reload --host 0.0.0.0 --port 8000
```

- API → **http://localhost:8000**
- Swagger docs → **http://localhost:8000/docs**

---

### 4. Configure & Start the Frontend

```bash
cd frontend
npm install
```

**Configure the API URL** (only needed if your backend is NOT on `localhost:8000`):

Create `frontend/.env.local`:

```env
REACT_APP_API_URL=http://localhost:8000
```

> If `REACT_APP_API_URL` is not set, the React dev server automatically proxies API calls to `http://localhost:8000` via the `proxy` field in `package.json`. No change needed for local development.

**Start the frontend:**

```bash
npm start
```

Frontend → **http://localhost:3000**

---

### 5. (Optional) Set Up Rasa NLP

Without Rasa the bot returns a friendly fallback message. To enable full NLP:

**Install Rasa in a separate virtual environment (do not mix with backend):**

```bash
cd rasa

# Linux / macOS
python3.10 -m venv rasa-venv
source rasa-venv/bin/activate

# Windows (PowerShell)
python -m venv rasa-venv
rasa-venv\Scripts\activate

pip install -r requirements.txt
```

**Configure the Rasa DB connection:**

```bash
cp .env.example .env
# Open rasa/.env and set RASA_DB_PASSWORD=your_mysql_password
```

Load the env file and start Rasa:

```bash
# Linux / macOS — load env vars, then start
export $(grep -v '^#' .env | xargs)
rasa train
rasa run actions --port 5055          # Terminal 1: action server
rasa run --enable-api --cors "*" --port 5005  # Terminal 2: Rasa API

# Windows (PowerShell) — load env vars
Get-Content .env | Where-Object { $_ -notmatch '^#' } | ForEach-Object {
  $k,$v = $_ -split '=',2
  [System.Environment]::SetEnvironmentVariable($k, $v)
}
rasa train
# then run action server and Rasa API in separate terminals
```

Ensure `RASA_URL=http://localhost:5005` is set in `backend/.env`.

---

## 🗺️ Path Configuration Guide

**No hardcoded paths exist in the source code.** All configuration is loaded from `.env` files or resolved dynamically at runtime. Here is what you may need to set:

### `backend/.env` — Rasa executable path

| Variable   | When to set it                                                    |
|------------|-------------------------------------------------------------------|
| `RASA_URL` | Always — URL of the running Rasa API server                      |
| `RASA_EXE` | Only if `rasa` is **not** on your system `PATH`                  |

**How to find your `RASA_EXE` path:**

```bash
# Linux / macOS
which rasa
# → /home/yourname/projects/infybot3/rasa/rasa-venv/bin/rasa

# Windows (PowerShell)
where.exe rasa
# → C:\Users\YourName\projects\infybot3\rasa\rasa-venv\Scripts\rasa.exe
```

Then set in `backend/.env`:

```env
# Linux / macOS example:
RASA_EXE=/home/yourname/projects/infybot3/rasa/rasa-venv/bin/rasa

# Windows example:
RASA_EXE=C:\Users\YourName\projects\infybot3\rasa\rasa-venv\Scripts\rasa.exe

# Leave blank to auto-detect from PATH:
RASA_EXE=
```

### `rasa/endpoints.yml` — Action server URL

Change only if you run the action server on a different host or port:

```yaml
action_endpoint:
  url: "http://localhost:5055/webhook"   # ← update if needed
```

### `backend/rasa_manager.py` — Rasa YAML file paths

Paths are resolved **automatically** from the file's own location. No changes needed if you keep the standard folder layout.

If you move the `rasa/` folder, update `RASA_DIR` near the top of `backend/rasa_manager.py`:

```python
# Uncomment and edit ONE of these lines:
# RASA_DIR = r"C:\Users\YourName\projects\my-rasa"   # Windows
# RASA_DIR = "/home/yourname/projects/my-rasa"        # Linux
# RASA_DIR = "/Users/yourname/projects/my-rasa"       # macOS
```

---

## 🔐 Access Control Model

```
┌────────────────────────────────────────────────────────────────┐
│                    Login & Routing Logic                       │
├──────────────────────┬─────────────────────────────────────────┤
│ New User             │ Register → gets USR-XXXX → /chat        │
│ Admin                │ Login with ADM-0001 → /dashboard (full) │
│ User + View access   │ Login → /dashboard (read-only)          │
│ User + Edit access   │ Login → /dashboard (read + flag msgs)   │
│ User (no access)     │ Login → /chat only                      │
└──────────────────────┴─────────────────────────────────────────┘
```

### Roles

| Role     | Description                                              |
|----------|----------------------------------------------------------|
| `viewer` | Chat only — default for new registrations                |
| `agent`  | Chat + can be granted dashboard access by an admin       |
| `admin`  | Full access: dashboard, user management, audit log       |

### Dashboard Access Levels

| Level  | Permissions                                                  |
|--------|--------------------------------------------------------------|
| `none` | Cannot access `/dashboard`                                   |
| `view` | Analytics, message logs, intent charts (read-only)           |
| `edit` | Everything in `view` + flag/unflag messages                  |

### Granting Access (as Admin)

1. Login → **Dashboard** → **User Management** tab
2. Find a user → change **Role** or **Dashboard Access** dropdown
3. Changes take effect immediately — all changes are audit-logged

---

## 🔑 Default Credentials

| Field          | Value          |
|----------------|----------------|
| Account Number | `ADM-0001`     |
| Password       | `Admin@123456` |

> ⚠️ **Change the default admin password immediately after first login.**

---

## 📡 API Reference

Full interactive docs: **http://localhost:8000/docs**

### Authentication

| Method | Endpoint                    | Description                                     |
|--------|-----------------------------|-------------------------------------------------|
| POST   | `/api/auth/login`           | Login with account_number + password            |
| POST   | `/api/auth/register`        | Register → returns auto-assigned account number |
| GET    | `/api/auth/me`              | Get current user profile                        |
| PUT    | `/api/auth/change-password` | Change own password                             |

### Chat

| Method | Endpoint                               | Description                      |
|--------|----------------------------------------|----------------------------------|
| POST   | `/api/chat/sessions`                   | Create a new chat session        |
| GET    | `/api/chat/sessions`                   | List my sessions                 |
| GET    | `/api/chat/sessions/{id}/messages`     | Get messages in a session        |
| POST   | `/api/chat/sessions/{id}/messages`     | Send message → Rasa NLP          |
| POST   | `/api/chat/messages/{id}/feedback`     | Submit 👍 / 👎 feedback           |
| DELETE | `/api/chat/sessions/{id}`              | Delete a session                 |

### Dashboard (requires `view` or `edit` access)

| Method | Endpoint                         | Description                               |
|--------|----------------------------------|-------------------------------------------|
| GET    | `/api/admin/dashboard`           | KPIs + chart data                         |
| GET    | `/api/admin/logs`                | Paginated message logs                    |
| GET    | `/api/admin/analytics/intents`   | Intent frequency + confidence stats       |
| PATCH  | `/api/admin/messages/{id}/flag`  | Flag/unflag a message (edit access only)  |

### Admin Only

| Method | Endpoint                          | Description                            |
|--------|-----------------------------------|----------------------------------------|
| GET    | `/api/admin/users`                | All users with stats                   |
| PATCH  | `/api/admin/users/{id}/access`    | Set dashboard access (none/view/edit)  |
| PATCH  | `/api/admin/users/{id}/role`      | Set role (viewer/agent/admin)          |
| PATCH  | `/api/admin/users/{id}/toggle`    | Activate / deactivate a user           |
| GET    | `/api/admin/access-log`           | Audit log of all access changes        |
| GET    | `/api/admin/export/messages`      | CSV export of messages (filterable)    |
| GET    | `/api/admin/export/users`         | CSV export of all users                |

### Rasa Admin (Admin Only)

| Method | Endpoint                     | Description                          |
|--------|------------------------------|--------------------------------------|
| GET    | `/api/rasa/intents`          | List all NLU intents                 |
| POST   | `/api/rasa/intents`          | Add a new intent + training examples |
| PUT    | `/api/rasa/intents/{name}`   | Update an existing intent            |
| DELETE | `/api/rasa/intents/{name}`   | Delete an intent                     |
| POST   | `/api/rasa/train`            | Trigger Rasa model retraining        |

---

## 🗄️ Database Schema

```sql
users           id, account_number, full_name, email, password_hash,
                role ENUM(admin, agent, viewer),
                dashboard_access ENUM(none, view, edit),
                department, avatar_color, is_active, created_at

chat_sessions   id, user_id, title, is_active, created_at

messages        id, session_id, user_id, sender ENUM(user, bot),
                message_text, intent, confidence,
                response_time_ms, is_flagged, created_at

feedback        id, message_id, user_id, rating ENUM(up, down), created_at

access_grants   id, granted_by, granted_to, access_level, changed_at

-- Views
v_kpi           Single-row dashboard KPI summary
v_intent_stats  Intent frequency + confidence aggregates
```

---

## 🔒 Security

- **Account number login** — auto-assigned IDs prevent enumeration attacks
- **JWT (HS256)** — 24h expiry, stateless verification on every request
- **bcrypt** — password hashing with cost factor 12
- **Rate limiting** — 200 req/min per IP (slowapi)
- **CORS whitelist** — only configured origins allowed
- **Parameterized queries** — aiomysql prevents SQL injection
- **Server-side role enforcement** — all access checks happen in FastAPI dependencies
- **No hardcoded paths or secrets** — all configuration via `.env` files

---

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/your-feature`
3. Commit your changes: `git commit -m 'Add some feature'`
4. Push: `git push origin feature/your-feature`
5. Open a Pull Request

Please verify all endpoints work via the Swagger UI at `http://localhost:8000/docs` before submitting.

---

## 📄 License

This project is licensed under the MIT License. See [LICENSE](LICENSE) for details.
