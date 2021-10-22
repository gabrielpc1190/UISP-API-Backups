#!/bin/sh
#Set API-Auth-Token values:
echo "Assigning variables:"
XAUTHTOKEN='a9casda9-4fg6-1bn8-bzx3-757f05h84d62'
echo XAUTHTOKEN is $XAUTHTOKEN
BACKUPFOLDER=/home/user/unms-backups
echo BACKUPFOLDER is $BACKUPFOLDER
OUTPUTFILE=$BACKUPFOLDER/uisp-backup-$(date +"%Y_%m_%d_%I_%M_%p").uisp
echo OUTPUTFILE is "$OUTPUTFILE"
UISPHOST='myuispserver.local'
echo UISPHOST is $UISPHOST
SLEEP=10m

echo "Now lets request a new backup to be generated by the UISP API:"
#Request a new backup to be generated by UISP using the API and API-Auth-Token and store the BackupId to a variable:
BACKUPID=$(curl -s -X POST "https://$UISPHOST/nms/api/v2.1/nms/backups/create" -H "accept: application/json" -H "x-auth-token: $XAUTHTOKEN" | python -c "import sys, json; print json.load(sys.stdin)['id']" )

echo "Done, the BACKUPID is $BACKUPID. Now lets wait until the backup gets generated, maybe $SLEEP will be enough?, lets try..."

#Wait for $SLEEP minutes until the backup it's done and available to be downloaded:
sleep $SLEEP

echo "Ok, wake up! and lets check if the backup is ready to be downloaded..."

#Get the Backup file from UISP using the API and API-Auth-Token from UNMS:
#curl -X GET "https://$UISPHOST/nms/api/v2.1/nms/backups/$BACKUPID" -H "accept: application/json" -H "x-auth-token: $XAUTHTOKEN" --output "$OUTPUTFILE"
scp root@10.10.1.8:/home/unms/data/unms-backups/backups/*manual* $OUTPUTFILE

if [ -n "$(find "$OUTPUTFILE" -prune -size +1000000c)" ]; then
	echo "If the download was succesful, here's the detail of the file downloaded:"
	ls -lh "$OUTPUTFILE"
else
	echo "Sorry, there was an error on the execution... you may have to increase the sleep time..."
fi

#Delete the backup on the server...
curl -s -X DELETE "https://$UISPHOST/nms/api/v2.1/nms/backups/$BACKUPID" -H "accept: application/json" -H "x-auth-token: $XAUTHTOKEN"
