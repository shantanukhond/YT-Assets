# DocSearch — Django + pgvector

Semantic document search UI built on PostgreSQL pgvector and Ollama embeddings. Companion to `p1_llmops` and the `PostgreSQL/pgvector` setup.

## Name

**`p2_docsearch`** — follows the `p1_llmops` naming pattern and describes what it does: search documents stored as vectors.

## Structure

```
p2_docsearch/
├── backend/           # Django app with search UI
└── docker-compose.yml # Run Django in Docker
```

## Prerequisites

- PostgreSQL + pgvector running (`PostgreSQL/pgvector`)
- Ollama running with the embedding model pulled
- Documents loaded (e.g. via `scrape_airflow_docs.py`)

## Run with Docker (recommended)

Start pgvector stack first:

```bash
cd PostgreSQL/pgvector
docker compose up -d
```

Then start DocSearch:

```bash
cd Projects/Airflow/p2_docsearch
cp backend/.env.example backend/.env
docker compose up -d --build
```

Open http://localhost:8000

The Django container joins the shared **`pgvector_net`** network and talks to:
- PostgreSQL at `postgres:5432`
- Ollama at `http://ollama:11434`

## Run locally (without Docker)

Copy the same `.env` from pgvector and add Django settings:

```bash
cd backend
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt

# Copy pgvector .env and append Django vars from .env.example
cp ../../../../PostgreSQL/pgvector/.env .env
cat .env.example >> .env
```

Or start fresh:

```bash
cp .env.example .env
```

Run migrations (Django auth tables only — `documents` table is managed by pgvector SQL):

```bash
python manage.py migrate
python manage.py runserver
```

Open http://127.0.0.1:8000

## How it works

1. Search bar at the top sends a query to Django
2. Django embeds the query via Ollama (`OLLAMA_HOST`, `OLLAMA_EMBED_MODEL`)
3. pgvector cosine similarity finds the closest documents
4. Click a result to load full content in the panel at the bottom

## Environment variables

Same as `PostgreSQL/pgvector/.env`:

| Variable | Purpose |
|---|---|
| `POSTGRES_HOST` | PostgreSQL host |
| `POSTGRES_PORT` | PostgreSQL port |
| `POSTGRES_USER` | Database user |
| `POSTGRES_PASSWORD` | Database password |
| `POSTGRES_DB` | Database name |
| `OLLAMA_HOST` | Ollama API URL |
| `OLLAMA_EMBED_MODEL` | Embedding model name |
| `EMBEDDING_DIMENSIONS` | Vector size (768 for `nomic-embed-text`) |

Plus Django vars: `DEBUG`, `SECRET_KEY`, `ALLOWED_HOSTS`
