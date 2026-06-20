# Using PostgreSQL as Vector Database

## Why to use PostgreSQL as Vector Database?

Many of you might be already using PostgreSQL as your application database. Now with LLMs RAGs it is becoming trend to have a database with vector embeddings of your non structured data placed to be queried by LLMs. So instead of hosting a new database why not to use pgvector extension and use exsiting database as vector database?

## How to use PostgreSQL as Vector Database with `pgvector` extension

### Creating Dockerfile

Create a Dockerfile using `postgresql 16`:

```dockerfile
FROM postgres:16

# Install pgvector extension into PostgreSQL
RUN apt-get update \
    && apt-get install -y --no-install-recommends postgresql-16-pgvector \
    && rm -rf /var/lib/apt/lists/*
```

### Creating Docker Compose file (PostgreSQL only)

```yaml
services:
  postgres:
    build: .
    container_name: pgvector-demo
    ports:
      - "5432:5432"
    environment:
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: postgres
      POSTGRES_DB: vectordb
    volumes:
      - pgvector_data:/var/lib/postgresql/data
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U postgres -d vectordb"]
      interval: 5s
      timeout: 5s
      retries: 5

volumes:
  pgvector_data:
```

### Creating extension in the database (run manually)

```sql
CREATE EXTENSION IF NOT EXISTS vector;
```

The `documents` table is created by `scrape_airflow_docs.py` when you run the scrape script.

### Ollama (separate compose file)

See `PostgreSQL/pgvector/ollama/docker-compose.yml`:

```yaml
services:
  ollama:
    image: ollama/ollama:latest
    container_name: ollama-embeddings
    ports:
      - "11434:11434"
    volumes:
      - ollama_data:/root/.ollama

  ollama-init:
    image: ollama/ollama:latest
    container_name: ollama-init
    depends_on:
      - ollama
    environment:
      OLLAMA_HOST: http://ollama:11434
      OLLAMA_EMBED_MODEL: ${OLLAMA_EMBED_MODEL:-nomic-embed-text}
    entrypoint: ["/bin/sh", "-c"]
    command:
      - |
        echo "Waiting for Ollama..."
        until ollama list >/dev/null 2>&1; do sleep 2; done
        echo "Pulling ${OLLAMA_EMBED_MODEL:-nomic-embed-text}..."
        ollama pull ${OLLAMA_EMBED_MODEL:-nomic-embed-text}
    restart: "no"

volumes:
  ollama_data:
```


### Loading the data into table using script

1. Start PostgreSQL and enable the extension manually.
2. Start Ollama: `cd PostgreSQL/pgvector/ollama && docker compose up -d`
3. Run the scrape script:

```bash
cd PostgreSQL/pgvector
python -m venv venv
source venv/bin/activate
cp .env.example .env
pip install -r requirements.txt
python scrape_airflow_docs.py
```





