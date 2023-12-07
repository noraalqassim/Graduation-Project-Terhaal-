# Generated by Django 4.2.6 on 2023-10-13 16:07

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('recommendation', '0004_remove_recommendationimage_is_active_and_more'),
    ]

    operations = [
        migrations.RenameField(
            model_name='recommendationimage',
            old_name='active',
            new_name='is_active',
        ),
        migrations.RemoveField(
            model_name='recommendationimage',
            name='primary',
        ),
        migrations.AddField(
            model_name='recommendationimage',
            name='is_primary',
            field=models.BooleanField(default=False, verbose_name='Is Primary'),
        ),
    ]
