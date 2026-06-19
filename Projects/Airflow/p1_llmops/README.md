# LLMOps — Django + React

Empty starter project with Django REST API backend and React (Vite) frontend.

## Structure

```
p1_llmops/
├── backend/     # Django API
└── frontend/    # React app
```

## Backend setup

```bash
cd backend
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
cp .env.example .env
python manage.py migrate
python manage.py runserver
```

API: http://127.0.0.1:8000  
Health check: http://127.0.0.1:8000/api/health/

## Frontend setup

```bash
cd frontend
npm install
npm run dev
```

App: http://localhost:5173

The Vite dev server proxies `/api` requests to Django on port 8000.

## Run both (two terminals)

**Terminal 1 — backend:**
```bash
cd backend && source venv/bin/activate && python manage.py runserver
```

**Terminal 2 — frontend:**
```bash
cd frontend && npm run dev
```

Open http://localhost:5173 — you should see the API health response from Django.
