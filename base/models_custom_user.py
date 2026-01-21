from django.contrib.auth.models import AbstractUser
from django.db import models
from django.utils.translation import gettext_lazy as _

class CustomUser(AbstractUser):
    is_new_employee = models.BooleanField(default=False, verbose_name=_("Is New Employee"))
