#!/bin/bash
set -e

echo "Running migrations…"
python manage.py migrate

echo "Collecting static files…"
python manage.py collectstatic --noinput

echo "Checking superuser and linked Employee…"

username=${ADMIN_USERNAME:-}
password=${ADMIN_PASSWORD:-}
email=${ADMIN_EMAIL:-}

python manage.py shell -c "
from django.contrib.auth import get_user_model
from employee.models import Employee
import os

User = get_user_model()
u = os.getenv('ADMIN_USERNAME')
p = os.getenv('ADMIN_PASSWORD')
e = os.getenv('ADMIN_EMAIL', '')

if not u or not p:
    print('ADMIN_USERNAME or ADMIN_PASSWORD environment variable not set.')
else:
    user, created = User.objects.get_or_create(username=u, defaults={'email': e})
    if created:
        user.set_password(p)
        user.is_superuser = True
        user.is_staff = True
        user.save()
        print(f'Superuser \"{u}\" created with email \"{e}\".')
    else:
        print(f'Superuser \"{u}\" already exists.')

    # Create linked Employee if it doesn't exist
    if not Employee.objects.filter(employee_user_id=user).exists():
        Employee.objects.create(
            employee_user_id=user,
            employee_first_name=user.first_name or 'Admin',
            employee_last_name=user.last_name or 'User',
            is_active=True,
            # Add any required fields with default values here
        )
        print(f'Employee linked to superuser \"{u}\" created.')
    else:
        print(f'Employee linked to superuser \"{u}\" already exists.')
"

echo "Admin Username: $username"
echo "Admin Password: $password"
echo "Admin Email: $email"

echo "Starting server on port ${PORT:-8000}…"
gunicorn horilla.wsgi:application --bind 0.0.0.0:${PORT:-8000}
