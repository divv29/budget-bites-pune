# 🍽 Budget Bites Pune

A full-stack restaurant discovery web app for Pune — built with Flask, PostgreSQL, and a premium dark editorial UI.

---

## 🚀 Quick Start

### Prerequisites
- Python 3.8+
- PostgreSQL 13+
- pip

---

## 📦 Installation

### Step 1 — Clone / Extract the project
```bash
cd budget-bites-pune
```

### Step 2 — Create a Python virtual environment
```bash
python -m venv venv

# Activate it:
# Windows:
venv\Scripts\activate
# macOS/Linux:
source venv/bin/activate
```

### Step 3 — Install dependencies
```bash
pip install -r requirements.txt
```

### Step 4 — Set up PostgreSQL

Open psql or pgAdmin and run:
```sql
CREATE DATABASE budget_bites_pune;
```

Then load the schema and sample data:
```bash
psql -U postgres -d budget_bites_pune -f database/schema.sql
```

Or from inside psql:
```sql
\c budget_bites_pune
\i database/schema.sql
```

### Step 5 — Configure database credentials

Edit `app.py` at the top (lines ~13–17), or set environment variables:

```bash
# Option A — Edit app.py directly
DB_USER = 'postgres'
DB_PASS = 'your_postgres_password'
DB_HOST = 'localhost'
DB_PORT = '5432'
DB_NAME = 'budget_bites_pune'

# Option B — Environment variables
export DB_USER=postgres
export DB_PASS=yourpassword
export DB_NAME=budget_bites_pune
```

### Step 6 — Run the Flask server
```bash
python app.py
```

Visit: **http://localhost:5000**

---

## 🔐 Admin Access

Default admin credentials (from schema.sql sample data):
```
Email:    admin@budgetbites.com
Password: admin123
```

Admin features:
- Add / Edit / Delete restaurants
- Add menu items to any restaurant
- View all registered users count

---

## 📁 Project Structure

```
budget-bites-pune/
│
├── app.py                  ← Flask app, routes, models
├── requirements.txt        ← Python dependencies
│
├── database/
│   └── schema.sql          ← PostgreSQL schema + sample data
│
├── templates/
│   ├── base.html           ← Base layout (navbar, footer, loader)
│   ├── index.html          ← Home / landing page
│   ├── restaurants.html    ← Restaurant directory with filters
│   ├── restaurant.html     ← Individual restaurant detail + menu
│   ├── login.html          ← Login page
│   ├── signup.html         ← Signup page
│   ├── profile.html        ← User profile + reviews
│   ├── admin.html          ← Admin dashboard
│   └── admin_form.html     ← Add/Edit restaurant form
│
└── static/
    ├── css/
    │   └── style.css       ← Complete stylesheet (glassmorphism, animations)
    └── js/
        └── script.js       ← Interactions, search autocomplete, scroll effects
```

---

## ✨ Features

| Feature | Details |
|---|---|
| Authentication | Signup, Login, Logout, bcrypt password hashing |
| Restaurant Directory | 18 real Pune restaurants with descriptions |
| Search | Live autocomplete search via REST API |
| Filters | By area, cuisine, price range, rating, sort order |
| Menu System | Full menu with categories, veg/non-veg indicators |
| Bill Calculator | Avg price for 2 prominently displayed |
| Reviews | Star ratings + comments (login required) |
| Admin Panel | CRUD for restaurants and menu items |
| Responsive | Mobile, tablet, desktop optimised |
| Premium UI | Dark editorial aesthetic, glassmorphism, scroll animations |

---

## 🛠 Tech Stack

- **Backend**: Python, Flask, Flask-SQLAlchemy
- **Database**: PostgreSQL
- **Auth**: bcrypt password hashing, Flask sessions
- **Frontend**: HTML5, CSS3 (CSS variables, glassmorphism), vanilla JS
- **Fonts**: Cormorant Garamond (display) + DM Sans (body)
- **Images**: Unsplash (via URL, no API key needed)

---

## 🗜 Zip the Project

```bash
cd ..
zip -r budget-bites-pune.zip budget-bites-pune/ \
  --exclude "budget-bites-pune/venv/*" \
  --exclude "budget-bites-pune/__pycache__/*" \
  --exclude "budget-bites-pune/.DS_Store"
```

---

## 📝 PBL Notes

- All 18 restaurants are based on real Pune establishments
- Sample menus include accurate dishes and approximate prices
- The admin system allows teachers/evaluators to add/edit content live
- The REST `/api/search` endpoint demonstrates AJAX integration
- bcrypt hashing, session management, and input validation demonstrate security awareness
