Group 2 Graduation Project
This ReadMe file provides an explanation of the Group 2 Graduation Project and instructions on how to set it up.

Section 1: Flutter Application
The Flutter application is a mobile app developed using the Flutter framework. To set up the project, follow these steps:

Download the pubspec.yaml file from the project repository.
Open the project in your preferred Flutter development environment.
In the project directory, run the following command to download the required dependencies: flutter pub get.
Once the dependencies are downloaded, the app should work without errors.
Test the application in your preferred Flutter testing environment to ensure its functionality.
Section 2: Python Server
The Python server contains the whole algorithm and dataset content. Please note that this server is not necessary for the project as we have utilized a Django server that is accessible online. However, if you wish to run the server locally, follow these steps:

Make sure you have Python installed on your machine.
Open a terminal and navigate to the project's server directory.
Run the following commands to set up the server:
pipenv install to install the required dependencies.
py manage.py makemigrations to create the necessary database migrations.
pipenv run python manage.py migrate to apply the migrations to the database.
Once the setup is complete, run the server using the command pipenv run python manage.py runserver.
The server should now be running locally on your machine.
Please note that if you encounter any errors or conflicts during the setup process, you can download the provided APK file for the Android application and physically test it on your device.

Personal Dataset
We have provided our personal dataset for your reference. You can access and check the dataset in the project repository. Please ensure that you comply with any applicable data usage and privacy regulations when accessing and using the dataset.
