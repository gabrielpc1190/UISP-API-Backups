# UISP-Backup-Using-API
Little script to backup your UISP server from a bash script using the UISP API v2.1

There are three versions of the script:
1) UISP-Backup.sh downloads the backup by using the API method, code is pretty basic and needs corrections.
2) UISP-Backup-v2.sh downloads the backup by using scp but fails so it needs corrections too.
3) UISP-Auto-Backup-3.sh, with better code to know when the file is ready to be fetch by curl using the API from the UISP host, and also deletes locally stored backups older than 7 days. Also backup files are uploaded to Backblaze B2 using the b2 command line binary and then deleted from the UISP server using the API.

1) Generate an API Token on your UNMS Settings, name it something like "BackupScript-Token".
2) Store this script on your machine, replacing the XAUTHTOKEN with your "BackupScript-Token".
3) Make sure you have python installed, if not, then install it :).
4) Adjust these variables to your environment: BACKUPFOLDER, UISPHOST and XAUTHTOKEN.
5) Run it as you wish, manually or using cron.
6) If you want the script to delete the backup after it's downloaded, then uncomment the last section (not valid for v1&2)
