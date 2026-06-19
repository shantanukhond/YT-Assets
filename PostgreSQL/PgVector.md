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

### Creating Docker Compose file

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
    networks:
      - pgvector_net
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U postgres -d vectordb"]
      interval: 5s
      timeout: 5s
      retries: 5

volumes:
  pgvector_data:

networks:
  pgvector_net:
    name: pgvector_net
```

### Creating extension in the database

```sql
CREATE EXTENSION IF NOT EXISTS vector;
```

### Example Table for Storing Embeddings

```sql
CREATE TABLE IF NOT EXISTS documents (
    id SERIAL PRIMARY KEY,
    title TEXT,
    source_url TEXT UNIQUE NOT NULL,
    content TEXT NOT NULL,
    embedding vector(768) NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS documents_embedding_idx
ON documents
USING hnsw (embedding vector_cosine_ops);
```

### Services those I used with Postgres

```yaml
services:
  ollama:
    image: ollama/ollama:latest
    container_name: ollama-embeddings
    ports:
      - "11434:11434"
    volumes:
      - ollama_data:/root/.ollama
    networks:
      - pgvector_net

  ollama-init:
    image: ollama/ollama:latest
    container_name: ollama-init
    depends_on:
      - ollama
    environment:
      OLLAMA_HOST: http://ollama:11434
    entrypoint: ["/bin/sh", "-c"]
    command:
      - |
        echo "Waiting for Ollama..."
        until ollama list >/dev/null 2>&1; do sleep 2; done
        echo "Pulling ${OLLAMA_EMBED_MODEL:-nomic-embed-text}..."
        ollama pull ${OLLAMA_EMBED_MODEL:-nomic-embed-text}
    networks:
      - pgvector_net
    restart: "no"

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
    networks:
      - pgvector_net
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U postgres -d vectordb"]
      interval: 5s
      timeout: 5s
      retries: 5

volumes:
  pgvector_data:
  ollama_data:

networks:
  pgvector_net:
    name: pgvector_net
```


### Loading the data into table using script
```

```