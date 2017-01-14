#!/bin/bash


# Environment variables.
 echo " Parameters: email: $MYBB_ADMINEMAIL domainname: $MYBB_DOMAINNAME dbname: $MYBB_DBNAME  dbuser: $MYBB_DBUSERNAME dbpwd: $MYBB_DBPASSWORD dbhostname: $MYBB_DBHOSTNAME  dbport: $MYBB_DBPORT" >> /tmp/mybb_install.log

TARGET="/var/www/html"

# Clean-up.
rm -rf "$TARGET"/*

wget https://resources.mybb.com/downloads/mybb_1810.zip -O /tmp/mybb_1810.zip
unzip /tmp/mybb_1810.zip "Upload/*" -d /tmp
mv /tmp/Upload/* /var/www/html/
rm -rf /tmp/mybb_1810.zip /tmp/Upload





# Prepare and copy dynamic configuration files.
sed -e "s/MYBB_ADMINEMAIL/${MYBB_ADMINEMAIL}/g" -e "s/MYBB_DOMAINNAME/${MYBB_DOMAINNAME}/g" "settings.php" > "${TARGET}/inc/settings.php"

sed -e "s/MYBB_DBNAME/${MYBB_DBNAME}/g" -e "s/MYBB_DBUSERNAME/${MYBB_DBUSERNAME}/g" -e "s/MYBB_DBPASSWORD/${MYBB_DBPASSWORD}/g" \
    -e "s/MYBB_DBHOSTNAME/${MYBB_DBHOSTNAME}/g" -e "s/MYBB_DBPORT/${MYBB_DBPORT}/g" "config.php" > "${TARGET}/inc/config.php"

# Initialize database.
sed -e "s/MYBB_ADMINEMAIL/${MYBB_ADMINEMAIL}/g" -e "s/MYBB_DOMAINNAME/${MYBB_DOMAINNAME}/g" "mybb.sql" | mysql \
    --user="$MYBB_DBUSERNAME" \
    --password="$MYBB_DBPASSWORD" \
    --host="$MYBB_DBHOSTNAME" \
    --port="$MYBB_DBPORT" \
    --database="$MYBB_DBNAME" || echo "Mybb Database created success."
	
	
# Set proper ownership and permissions.
cd "$TARGET"
# chown www-data:www-data *
chmod 666 inc/config.php inc/settings.php
chmod 666 inc/languages/english/*.php inc/languages/english/admin/*.php

# TODO: The "uploads/" path should be mounted on an S3 bucket.
chmod 777 cache/ cache/themes/ uploads/ uploads/avatars/
chmod 777 cache/ cache/themes/ uploads/ uploads/avatars/ admin/backups/