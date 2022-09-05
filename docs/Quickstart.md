To quickly start the script you will need to execute the following steps:
P.S.: *The main logging script requires Elevated Privileges because it needs to make a new Event Log*
1. Start the file modifier applet.
2. Click the button labeled: **`Continuously modify data randomly (Live system)`** in the window titled **`Data Generator`**.
3. Start the mail server applet.
4. Click the **`Start Server`** button in the fakeSMTP server when it opens.
5. Start the robocopy script.
6. Start the main logging script (This script will restart and ask for elevation if it is not run as administrator).


The File Modifier will look like this when you have started it correctly:
![image](https://user-images.githubusercontent.com/79884124/188370596-67d37e28-cc36-4b1b-bb42-9a8a394ebe15.png)

The Fake SMTP Server will look like this when you have started it correctly:
![image](https://user-images.githubusercontent.com/79884124/188370647-06522fc7-27dc-4720-83c0-b7d602e29ad1.png)

The Robocopy script will look like this when it successfully started:
![image](https://user-images.githubusercontent.com/79884124/188370753-731d185e-5e9a-45ab-ae94-09f5f93c8b43.png)

If you start Start-LoggingFiles without administrator privileges it will attempt to restart itself in an elevated state:
![image](https://user-images.githubusercontent.com/79884124/188370807-93f4a7bd-41b8-45c5-8654-ada89c15e096.png)

This is what the Start-LoggingFiles script will look like when it is succesfully running:
![image](https://user-images.githubusercontent.com/79884124/188370843-5473c205-4d17-40f7-a718-7e3ee438c5bb.png)

You should now start seeing emails pop up in the smtp server:
![image](https://user-images.githubusercontent.com/79884124/188371001-0eb5a62b-f604-412b-8790-4377d7a78a6b.png)

If you open the Event Viewer and the email, the timestamp in the Subject of the email and the timestamp of the Event should match, and they should have the same data:
![image](https://user-images.githubusercontent.com/79884124/188371809-0e58ed5d-333c-43f6-9e97-2120f787a643.png)
