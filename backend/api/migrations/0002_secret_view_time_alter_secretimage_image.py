# Generated by Django 4.2.8 on 2024-02-20 17:35

import django.core.files.storage
import django.core.validators
from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('api', '0001_initial'),
    ]

    operations = [
        migrations.AddField(
            model_name='secret',
            name='view_time',
            field=models.IntegerField(blank=True, default=None, help_text='in seconds', null=True, validators=[django.core.validators.MinValueValidator(0), django.core.validators.MaxValueValidator(300)]),
        ),
        migrations.AlterField(
            model_name='secretimage',
            name='image',
            field=models.ImageField(storage=django.core.files.storage.FileSystemStorage(location='C:\\Users\\info\\IdeaProjects\\pws-secrets\\backend\\media\\images'), upload_to=''),
        ),
    ]
