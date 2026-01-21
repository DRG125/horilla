#!/bin/bash
set -e

echo "Running migrations…"
python manage.py migrate

echo "Collecting static files…"
python manage.py collectstatic --noinput

echo "Checking superuser, linked Employee, and loading demo data if needed…"

username=${ADMIN_USERNAME:-}
password=${ADMIN_PASSWORD:-}
email=${ADMIN_EMAIL:-}

python manage.py shell -c "
from django.contrib.auth import get_user_model
from employee.models import Employee
from django.core.management import call_command
from django.conf import settings
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

    if not Employee.objects.filter(employee_user_id=user).exists():
        Employee.objects.create(
            employee_user_id=user,
            employee_first_name=user.first_name or 'Admin',
            employee_last_name=user.last_name or 'User',
            is_active=True,
            # Add required default fields if any
        )
        print(f'Employee linked to superuser \"{u}\" created.')
    else:
        print(f'Employee linked to superuser \"{u}\" already exists.')

    # Check if demo data already loaded (example check: any employees in DB)
    if Employee.objects.count() <= 1:
        print('Loading demo data...')
        data_files = [
            'user_data.json',
            'employee_info_data.json',
            'base_data.json',
            'work_info_data.json',
        ]
        for file in data_files:
            file_path = os.path.join(settings.BASE_DIR, 'load_data', file)
            call_command('loaddata', file_path)
        print('Demo data loaded successfully.')
    else:
        print('Demo data already present; skipping load.')
"

echo "Admin Username: $username"
echo "Admin Password: $password"
echo "Admin Email: $email"

echo "Starting server on port ${PORT:-8000}…"
gunicorn horilla.wsgi:application --bind 0.0.0.0:${PORT:-8000}
