# UISP-Backup-Using-API
Little script to backup your UISP server from a bash script using the UISP API v2.1

There are two versions of the script:
1) UISP-Backup.sh downloads the backup by using the API method, that it's a bit slow for me and I'm not that good on coding to use it properly.
2) UISP-Backup-v2.sh downloads the backup by using scp.

1) Generate an API Token on your UNMS Settings, name it something like "BackupScript-Token".
2) Store this script on your machine, replacing the XAUTHTOKEN with your "BackupScript-Token".
3) Make sure you have python installed, if not, then install it :).
4) Adjust these variables to your environment: BACKUPFOLDER, UISPHOST and XAUTHTOKEN.
5) Run it as you wish, manually or using cron.
6) If you want the script to delete the backup after it's downloaded, then uncomment the last section.
