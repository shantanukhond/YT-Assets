# PostgreSQL as Vector Database using pgvector Extension

Use standard **PostgreSQL** as your database, then enable the **pgvector** extension to store embeddings and run similarity search with SQL.

## How it works

1. **PostgreSQL** — official `postgres:16` image with pgvector installed via Dockerfile
2. **Enable extension** — run `CREATE EXTENSION vector;` manually in `psql`
3. **Ollama** — separate compose file pulls the embedding model
4. **Scrape script** — creates the `documents` table and loads Airflow docs with embeddings

## Prerequisites

- Docker and Docker Compose
- Python 3.10+

## 1. Start PostgreSQL

From this folder:

```bash
cd PostgreSQL/pgvector
docker compose up -d --build
```

Connect and enable pgvector:

```bash
psql postgresql://postgres:postgres@localhost:5432/vectordb
```

```sql
CREATE EXTENSION IF NOT EXISTS vector;
```

Or from the shell:

```bash
psql postgresql://postgres:postgres@localhost:5432/vectordb -f sql/01_enable_extension.sql
```

Verify:

```sql
SELECT version();
\dx vector
```

To stop:

```bash
docker compose down
```

To reset the database:

```bash
docker compose down -v
docker compose up -d --build
```

## 2. Start Ollama

From the `ollama` folder:

```bash
cd ollama
docker compose up -d
```

The embedding model is pulled automatically on startup (`nomic-embed-text` by default). Set `OLLAMA_EMBED_MODEL` in `.env` to use a different model.

To pull manually:

```bash
docker compose exec ollama ollama pull nomic-embed-text
```

## 3. Scrape and store embeddings

From the `pgvector` folder:

```bash
python3 -m venv venv
source venv/bin/activate
cp .env.example .env
pip install -r requirements.txt
python scrape_airflow_docs.py
```

The script creates the `documents` table (if missing) and upserts scraped pages with embeddings.

## Files in this folder

| Path | Purpose |
|------|---------|
| `Dockerfile` | PostgreSQL 16 + pgvector extension install |
| `docker-compose.yml` | PostgreSQL database only |
| `ollama/docker-compose.yml` | Ollama + model pull on startup |
| `sql/01_enable_extension.sql` | Enable pgvector extension (run manually) |
| `scrape_airflow_docs.py` | Create table, scrape docs, store embeddings |
| `.env.example` | Connection settings for the scrape script |

[!["Buy Me A Coffee"](https://www.buymeacoffee.com/assets/img/custom_images/orange_img.png)](https://www.buymeacoffee.com/shantanukhond)
