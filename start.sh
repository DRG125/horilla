#!/bin/bash

echo "Running migrations…"
python manage.py migrate

echo "Collecting static files…"
python manage.py collectstatic --noinput

echo "Starting server without schedulers…"
gunicorn horilla.wsgi:application
