# PostgreSQL as Vector Database using pgvector Extension

Use standard **PostgreSQL** as your database, then enable the **pgvector** extension to store embeddings and run similarity search with SQL.

## How it works

1. **PostgreSQL** — official `postgres:16` image runs the database
2. **pgvector extension** — installed in the Dockerfile (`postgresql-16-pgvector` package)
3. **Enable in database** — `CREATE EXTENSION vector;` runs from `sql/01_enable_extension.sql`
4. **Vector tables** — `sql/02_create_tables.sql` creates the `documents` table and HNSW index
5. **App** — Ollama + Python app run in a separate compose file under `app/`

## Prerequisites

- Docker and Docker Compose

## 1. Start PostgreSQL and pgvector

From this folder:

```bash
cd "PostgreSQL/pgvector as Vector Database"
docker compose up -d --build
```

Connect to PostgreSQL:

```bash
psql postgresql://postgres:postgres@localhost:5432/vectordb
```

Verify PostgreSQL and pgvector:

```sql
SELECT version();
\dx vector
\d documents
```

To stop and remove containers:

```bash
docker compose down
```

To reset the database and re-run init scripts:

```bash
docker compose down -v
docker compose up -d --build
```

## 2. Start the app (Ollama + Python)

From the `app` folder:

```bash
cd app
docker compose up -d --build
```

The embedding model is pulled automatically on startup by the `ollama-init` service (`nomic-embed-text` by default). To use a different model, set `OLLAMA_EMBED_MODEL` in `.env`.

To pull manually:

```bash
docker compose exec ollama ollama pull nomic-embed-text
```

This runs:
- **Ollama** — local embedding model (`nomic-embed-text`, 768 dimensions)
- **App** — Python container connected to PostgreSQL and Ollama over the shared `pgvector_net` network

Both compose files share the **`pgvector_net`** network, so the app reaches PostgreSQL at `postgres:5432`.

## 3. Store embeddings

```bash
docker compose exec app python embed_documents.py
```

## 4. Similarity search

```bash
docker compose exec app python similarity_search.py "What is pgvector?"
```

### Manual setup (existing PostgreSQL server)

If PostgreSQL is already installed, install pgvector for your version, then run:

```bash
psql postgresql://postgres:postgres@localhost:5432/vectordb -f sql/01_enable_extension.sql
psql postgresql://postgres:postgres@localhost:5432/vectordb -f sql/02_create_tables.sql
```

Inside `psql`, enabling pgvector looks like:

```sql
CREATE EXTENSION IF NOT EXISTS vector;
```

### Local Python (without Docker app container)

```bash
cd app
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
```

Create a `.env` file in the `app` folder:

```
DATABASE_URL=postgresql://postgres:postgres@localhost:5432/vectordb
OLLAMA_HOST=http://localhost:11434
OLLAMA_EMBED_MODEL=nomic-embed-text
EMBEDDING_DIMENSIONS=768
```

For the smallest embedding model:

```
OLLAMA_EMBED_MODEL=all-minilm
EMBEDDING_DIMENSIONS=384
```

> If you change the model, update `vector(768)` in `sql/02_create_tables.sql` to match and recreate the database volume.

## SQL example

```sql
SELECT content, embedding <=> '[0.1, 0.2, ...]'::vector AS distance
FROM documents
ORDER BY distance
LIMIT 5;
```

## Files in this folder

| Path | Purpose |
|------|---------|
| `Dockerfile` | PostgreSQL 16 + pgvector extension install |
| `docker-compose.yml` | PostgreSQL database only |
| `app/docker-compose.yml` | Ollama + Python app |
| `app/Dockerfile` | App container image |
| `sql/01_enable_extension.sql` | Enable pgvector extension |
| `sql/02_create_tables.sql` | Create documents table and index |
| `app/models/embeddings.py` | Ollama embedding helper |
| `app/embed_documents.py` | Generate and store embeddings |
| `app/similarity_search.py` | Query similar documents |

[The app code is available here](./app/)

[!["Buy Me A Coffee"](https://www.buymeacoffee.com/assets/img/custom_images/orange_img.png)](https://www.buymeacoffee.com/shantanukhond)
