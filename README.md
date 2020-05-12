# robocopyBackup
Windows robocopy backup script with email alerting

### Requirements
blat.exe command line email tool, stunnel, robocopy.exe, and optional log files to write to.

### Installation
1)
2)
3)
4)
5)

### Edit stunnel config
1. 
2. 
3. 
4. 
5.

*Note*: If using gmail as your smtp email provider, you will receive authentication errrors. See `/var/log/sendEmail` for debugging. In this case, you must enable "Allow less secure apps: ON" located in google account settings https://myaccount.google.com/lesssecureapps.

### Running robocopyBackup.bat script
The user running this must have read acccess to the primary directory, and read/write to the secondary.

#### Run script

#### Automate script with a scheduled task
