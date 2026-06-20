import os

import ollama
import psycopg2
import requests
from bs4 import BeautifulSoup
from dotenv import load_dotenv

load_dotenv()

OLLAMA_HOST = os.getenv("OLLAMA_HOST", "http://localhost:11434")
OLLAMA_EMBED_MODEL = os.getenv("OLLAMA_EMBED_MODEL", "nomic-embed-text")
EMBEDDING_DIMENSIONS = int(os.getenv("EMBEDDING_DIMENSIONS", "768"))


def ensure_documents_table(conn):
    with conn.cursor() as cur:
        cur.execute(
            f"""
            CREATE TABLE IF NOT EXISTS documents (
                id SERIAL PRIMARY KEY,
                title TEXT,
                source_url TEXT UNIQUE NOT NULL,
                content TEXT NOT NULL,
                embedding vector({EMBEDDING_DIMENSIONS}) NOT NULL,
                created_at TIMESTAMPTZ DEFAULT NOW()
            )
            """
        )
        cur.execute(
            """
            CREATE INDEX IF NOT EXISTS documents_embedding_idx
            ON documents
            USING hnsw (embedding vector_cosine_ops)
            """
        )
    conn.commit()

AIRFLOW_PAGES = [
    "https://airflow.apache.org/docs/apache-airflow/stable/index.html",
    "https://airflow.apache.org/docs/apache-airflow/stable/installation/index.html",
    "https://airflow.apache.org/docs/apache-airflow/stable/tutorial/index.html",
    "https://airflow.apache.org/docs/apache-airflow/stable/core-concepts/index.html",
    "https://airflow.apache.org/docs/apache-airflow/stable/core-concepts/dags.html",
    "https://airflow.apache.org/docs/apache-airflow/stable/core-concepts/tasks.html",
    "https://airflow.apache.org/docs/apache-airflow/stable/core-concepts/operators.html",
    "https://airflow.apache.org/docs/apache-airflow/stable/core-concepts/sensors.html",
    "https://airflow.apache.org/docs/apache-airflow/stable/core-concepts/executor/index.html",
    "https://airflow.apache.org/docs/apache-airflow/stable/administration-and-deployment/index.html",
]

ollama_client = ollama.Client(host=OLLAMA_HOST)

conn = psycopg2.connect(
    host=os.getenv("POSTGRES_HOST", "localhost"),
    port=os.getenv("POSTGRES_PORT", "5432"),
    user=os.getenv("POSTGRES_USER", "postgres"),
    password=os.getenv("POSTGRES_PASSWORD", "postgres"),
    dbname=os.getenv("POSTGRES_DB", "vectordb"),
)

ensure_documents_table(conn)

saved = 0

for url in AIRFLOW_PAGES:
    print(f"Fetching {url}")

    response = requests.get(url, timeout=30)
    response.raise_for_status()

    soup = BeautifulSoup(response.text, "html.parser")

    title_tag = soup.find("title")
    title = title_tag.get_text(strip=True) if title_tag else url

    main = soup.find("article") or soup.find("main") or soup.find("body")
    content = main.get_text("\n", strip=True) if main else soup.get_text("\n", strip=True)

    print(f"Creating embedding for: {title}")
    embed_response = ollama_client.embed(model=OLLAMA_EMBED_MODEL, input=content)
    embedding = embed_response["embeddings"][0]

    with conn.cursor() as cur:
        cur.execute(
            """
            INSERT INTO documents (title, source_url, content, embedding)
            VALUES (%s, %s, %s, %s::vector)
            ON CONFLICT (source_url) DO UPDATE
            SET title = EXCLUDED.title,
                content = EXCLUDED.content,
                embedding = EXCLUDED.embedding
            """,
            (title, url, content, str(embedding)),
        )

    saved += 1
    print(f"Saved: {title}")

conn.commit()
conn.close()

print(f"Done. Saved {saved} pages.")
