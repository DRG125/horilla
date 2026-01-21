#!/bin/bash
set -e

echo "Running migrations…"
python manage.py migrate

echo "Collecting static files…"
python manage.py collectstatic --noinput

echo "Checking superuser…"

username=${ADMIN_USERNAME:-}
password=${ADMIN_PASSWORD:-}
email=${ADMIN_EMAIL:-}

python manage.py shell -c "
from django.contrib.auth import get_user_model
import os
User = get_user_model()
u = os.getenv('ADMIN_USERNAME')
p = os.getenv('ADMIN_PASSWORD')
e = os.getenv('ADMIN_EMAIL', '')
if not u or not p:
    print('ADMIN_USERNAME or ADMIN_PASSWORD environment variable not set.')
else:
    user_exists = User.objects.filter(username=u).exists()
    if user_exists:
        print(f'Superuser \"{u}\" already exists.')
    else:
        User.objects.create_superuser(u, e, p)
        print(f'Superuser \"{u}\" created with email \"{e}\".')
"

echo "Admin Username: $username"
echo "Admin Password: $password"
echo "Admin Email: $email"

echo "Starting server on port ${PORT:-8000}…"
gunicorn horilla.wsgi:application --bind 0.0.0.0:${PORT:-8000}
