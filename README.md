# UISP-API-Backups
Little script to backup your UISP server from a bash script using the UISP API v2.1

1) Generate an API Token on your UNMS Settings, name it something like "BackupScript-Token".
2) Store this script on your machine, replacing the XAUTHTOKEN with your "BackupScript-Token".
3) Make sure you have python installed, if not, then install it :).
4) Adjust these variables to your environment: BACKUPFOLDER, UISPHOST and XAUTHTOKEN.
5) Run it as you wish, manually or using cron.
6) If you want the script to delete the backup after it's downloaded, then comment the last section.
