#!/bin/bash
set -e

echo "Running migrations…"
python manage.py migrate

echo "Collecting static files…"
python manage.py collectstatic --noinput

echo "Creating superuser if not exists…"
python manage.py shell -c "
from django.contrib.auth import get_user_model;
import os;
User = get_user_model();
u=os.getenv('ADMIN_USERNAME');
p=os.getenv('ADMIN_PASSWORD');
e=os.getenv('ADMIN_EMAIL','');
(
 User.objects.create_superuser(u,e,p)
 if u and p and not User.objects.filter(username=u).exists()
 else None
)
"

echo "Starting server on port ${PORT:-8000}…"
gunicorn horilla.wsgi:application --bind 0.0.0.0:${PORT:-8000}
