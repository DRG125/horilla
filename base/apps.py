"""
This module contains the configuration for the 'base' app.
"""

from django.apps import AppConfig
import os


class BaseConfig(AppConfig):
    """
    Configuration class for the 'base' app.
    """

    default_auto_field = "django.db.models.BigAutoField"
    name = "base"

    def ready(self) -> None:
        from base import signals

        super().ready()
        try:
            from base.models import EmployeeShiftDay

            if not EmployeeShiftDay.objects.exists():
                days = [
                    ("monday", "Monday"),
                    ("tuesday", "Tuesday"),
                    ("wednesday", "Wednesday"),
                    ("thursday", "Thursday"),
                    ("friday", "Friday"),
                    ("saturday", "Saturday"),
                    ("sunday", "Sunday"),
                ]

                EmployeeShiftDay.objects.bulk_create(
                    [EmployeeShiftDay(day=day[0]) for day in days]
                )
        except Exception as e:
            pass


        # -------------------------------
        # NEW: Auto-create admin (Render)
        # -------------------------------
        try:
           from django.contrib.auth import get_user_model
           from django.db import connection

           if "auth_user" in connection.introspection.table_names():
               User = get_user_model()

               username = os.getenv("ADMIN_USERNAME")
               email = os.getenv("ADMIN_EMAIL")
               password = os.getenv("ADMIN_PASSWORD")

               if username and password:
                   if not User.objects.filter(username=username).exists():
                        User.objects.create_superuser(
                            username=username,
                            email=email or "",
                            password=password,
                )
        except Exception:
            pass