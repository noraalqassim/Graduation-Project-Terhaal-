# Generated by Django 4.2.6 on 2023-10-13 15:57

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('recommendation', '0003_remove_recommendation_category_and_more'),
    ]

    operations = [
        migrations.RemoveField(
            model_name='recommendationimage',
            name='is_active',
        ),
        migrations.AddField(
            model_name='recommendationimage',
            name='active',
            field=models.BooleanField(default=True, verbose_name='Active'),
        ),
    ]
