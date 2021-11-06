#!/bin/sh
#Make sure to have curl jq installed for this to work.
#Set API-Auth-Token values:
echo "Assigning variables:"
XAUTHTOKEN="0sa5c98-3032-a243-a35j-65aa134006ad"
echo XAUTHTOKEN is $XAUTHTOKEN
BACKUPFOLDER="/home/unms-backups"
echo BACKUPFOLDER is $BACKUPFOLDER
OUTPUTFILENAME=uisp-backup-$(date +"%Y_%m_%d_%I_%M_%p").uisp
OUTPUTFILE=$BACKUPFOLDER/$OUTPUTFILENAME
echo OUTPUTFILE is "$OUTPUTFILE"
UISPHOST="myUISP"
B2BUCKET="My-UISP"
echo UISPHOST is $UISPHOST
SLEEP=30

echo "Now lets request a new backup to be generated by the UISP API:"
#Request a new backup to be generated by UISP using the API and API-Auth-Token and store the BackupId to a variable:
BACKUPID=$(curl -k -s -X POST "https://$UISPHOST/nms/api/v2.1/nms/backups/create" -H "accept: application/json" -H "x-auth-token: $XAUTHTOKEN" | python -c "import sys, json; print json.load(sys.stdin)['id']")

echo "Done, the BACKUPID is $BACKUPID. Now lets wait until the backup gets generated, maybe $SLEEP will be enough?, lets try..."
sleep $SLEEP

BACKUPSTATE=$(curl -k -s -X GET "https://$UISPHOST/nms/api/v2.1/nms/backups" -H "accept: application/json" -H "x-auth-token: $XAUTHTOKEN" | grep -oP "success|in-progress")
echo $BACKUPSTATE
#Let's wait until the backup gets generated:
until [ "$BACKUPSTATE" = "success" ]
do
  echo "Backup is not completed yet, lets wait $SLEEP and try again..."
  sleep $SLEEP
  BACKUPSTATE=$(curl -k -s -X GET "https://$UISPHOST/nms/api/v2.1/nms/backups" -H "accept: application/json" -H "x-auth-token: $XAUTHTOKEN" | grep -oP "success|in-progress")
  echo $BACKUPSTATE
done
echo "Backup is completed, lets download the backup file to $OUTPUTFILE"

#Get the Backup file from UISP using the API and API-Auth-Token from UNMS:
#curl -X GET "https://$UISPHOST/nms/api/v2.1/nms/backups/$BACKUPID" -H "accept: application/json" -H "x-auth-token: $XAUTHTOKEN" --output "$OUTPUTFILE"
#Getting the backup file by scp from the UNMS host:

echo "Let's get the backup by scp into the $UISPHOST"
scp root@$UISPHOST:/home/unms/data/unms-backups/backups/*manual* $OUTPUTFILE
OUTPUTFILESHA1SUM=`sha1sum $OUTPUTFILE | awk '{print $1}'`
echo $OUTPUTFILESHA1SUM

BACKUPREADY=false

if [ -n "$(find "$OUTPUTFILE" -prune -size +1000000c)" ]; then
	echo "If the download was succesful, here's the detail of the file downloaded:"
	ls -lh "$OUTPUTFILE"
	BACKUPREADY=true
else
	echo "Sorry, there was an error on the execution..."
fi

if [ "$BACKUPREADY" = "true" ]
then
    echo "Now we are going to upload the file to Backblaze B2 Bucket $B2BUCKET ..."
    b2 upload-file --sha1 "$OUTPUTFILESHA1SUM" $B2BUCKET $OUTPUTFILE $OUTPUTFILENAME
    echo "The backup has been uploaded to Backblaze B2!..."
    echo "Let's find out the local files older than 7 days..."
    find $BACKUPFOLDER -maxdepth 1 -type f -mtime +7 -name "*.uisp"
    echo "The files older than 7 days are going to be deleted..."
    find $BACKUPFOLDER -maxdepth 1 -type f -mtime +7 -name "*.uisp" -delete
    echo "Done!"
fi

#End of the script

#Delete the backup on the $UISPHOST server:
curl -k -s -X DELETE "https://$UISPHOST/nms/api/v2.1/nms/backups/$BACKUPID" -H "accept: application/json" -H "x-auth-token: $XAUTHTOKEN"
echo "Done!"