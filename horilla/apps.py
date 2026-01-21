from django.apps import AppConfig
from django.contrib.auth import get_user_model
import os
from django.db.utils import OperationalError, ProgrammingError

class HorillaConfig(AppConfig):
    default_auto_field = "django.db.models.BigAutoField"
    name = "horilla"

    def ready(self):
        User = get_user_model()
        admin_email = os.getenv("ADMIN_EMAIL")
        admin_password = os.getenv("ADMIN_PASSWORD")
        admin_username = os.getenv("ADMIN_USERNAME")  # Add this env var

        if not admin_email or not admin_password or not admin_username:
            return

        try:
            if not User.objects.filter(is_superuser=True).exists():
                User.objects.create_superuser(
                    username=admin_username,
                    email=admin_email,
                    password=admin_password,
                )
                print("✅ Superuser created automatically")
        except (OperationalError, ProgrammingError):
            # Database not ready yet, skip creating superuser for now
            pass
