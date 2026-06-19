#!/bin/sh
set -e

echo "Waiting for PostgreSQL..."
until python -c "
import os
import psycopg2

psycopg2.connect(
    host=os.environ['POSTGRES_HOST'],
    port=os.environ.get('POSTGRES_PORT', '5432'),
    user=os.environ['POSTGRES_USER'],
    password=os.environ['POSTGRES_PASSWORD'],
    dbname=os.environ['POSTGRES_DB'],
)
" 2>/dev/null; do
  sleep 2
done

echo "Waiting for Ollama..."
until python -c "
import os
import urllib.request

urllib.request.urlopen(f\"{os.environ['OLLAMA_HOST'].rstrip('/')}/api/tags\")
" 2>/dev/null; do
  sleep 2
done

python manage.py migrate --noinput
exec python manage.py runserver 0.0.0.0:8000
