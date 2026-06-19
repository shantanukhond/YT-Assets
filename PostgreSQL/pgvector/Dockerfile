FROM postgres:16

# Install pgvector extension into PostgreSQL
RUN apt-get update \
    && apt-get install -y --no-install-recommends postgresql-16-pgvector \
    && rm -rf /var/lib/apt/lists/*

# Run init SQL on first container start (extension + tables)
COPY sql/ /docker-entrypoint-initdb.d/
