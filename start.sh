#!/bin/bash

echo "Running migrations…"
python manage.py migrate

echo "Collecting static files…"
python manage.py collectstatic --noinput

echo "Starting server on port $PORT…"
gunicorn horilla.wsgi:application --bind 0.0.0.0:$PORT
