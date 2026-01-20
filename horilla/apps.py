from django.apps import AppConfig
from django.contrib.auth import get_user_model
import os

class HorillaConfig(AppConfig):
    default_auto_field = "django.db.models.BigAutoField"
    name = "horilla"

    def ready(self):
        User = get_user_model()
        admin_email = os.getenv("ADMIN_EMAIL")
        admin_password = os.getenv("ADMIN_PASSWORD")

        if not admin_email or not admin_password:
            return

        if not User.objects.filter(is_superuser=True).exists():
            User.objects.create_superuser(
                email=admin_email,
                password=admin_password,
            )
            print("✅ Superuser created automatically")
