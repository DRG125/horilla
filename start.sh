#!/bin/bash
set -e

echo "Running migrations…"
python manage.py migrate

echo "Collecting static files…"
python manage.py collectstatic --noinput

echo "Fixing admin login + optional demo data…"

python manage.py shell -c "
from django.contrib.auth import get_user_model
from employee.models import Employee
from base.models_userprofile import UserProfile
from django.core.management import call_command
from django.conf import settings
import os

User = get_user_model()

u = os.getenv('ADMIN_USERNAME')
p = os.getenv('ADMIN_PASSWORD')
e = os.getenv('ADMIN_EMAIL', '')

if not u or not p:
    print('ADMIN env vars missing')
    exit()

# ---- USER ----
user, created = User.objects.get_or_create(
    username=u,
    defaults={'email': e}
)

if created:
    user.set_password(p)

user.is_superuser = True
user.is_staff = True
user.is_active = True
user.save()

print('Admin user ready')

# ---- USER PROFILE ----
profile, _ = UserProfile.objects.get_or_create(user=user)
profile.is_new_employee = False
profile.save()

print('UserProfile fixed (no password redirect)')

# ---- EMPLOYEE ----
Employee.objects.get_or_create(
    employee_user_id=user,
    defaults={
        'employee_first_name': 'Admin',
        'employee_last_name': 'User',
        'is_active': True
    }
)

print('Employee linked')

# ---- DEMO DATA (ONCE) ----
marker = '/tmp/demo_loaded'

if not os.path.exists(marker):
    print('Loading demo data...')

    files = [
        'user_data.json',
        'employee_info_data.json',
        'base_data.json',
        'work_info_data.json',
    ]

    for f in files:
        call_command('loaddata', os.path.join(settings.BASE_DIR, 'load_data', f))

    open(marker, 'w').write('done')
    print('Demo data loaded')
else:
    print('Demo data already loaded')
"
echo "Starting server on port ${PORT:-8000}…"
gunicorn horilla.wsgi:application --bind 0.0.0.0:${PORT:-8000}
