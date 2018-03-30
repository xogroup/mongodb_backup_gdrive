#!/usr/bin/env sh

echo "Backup started."

FILE_TAG=backup_$(date +"%Y%m%d")
OBSOLETE_FILE_TAG=backup_$(date --date="7 days ago" +"%Y%m%d")

ARCHIVE_NAME=$DATABASE.$FILE_TAG.gz
OBSOLETE_ARCHIVE_NAME=$DATABASE.$OBSOLETE_FILE_TAG.gz

mongodump \
  --host $HOST \
  --verbose \
  --username $USERNAME \
  --password $PASSWORD \
  --authenticationDatabase $AUTHDB  \
  --db $DATABASE \
  --readPreference secondaryPreferred \
  --excludeCollectionsWithPrefix=system \
  --dumpDbUsersAndRoles \
  --gzip \
  --archive=/root/$ARCHIVE_NAME

echo "Backup finished."

echo "Copying backup to GDrive."

rclone copy /root/$ARCHIVE_NAME remote:$REPLICASET/ -vv
rclone delete remote:$REPLICASET/$OBSOLETE_ARCHIVE_NAME -vv

echo "Backup copied to GDrive."
