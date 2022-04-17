#!/bin/bash

# Get AbPath
PROJECT_PATH=$(dirname $(dirname $(realpath $0)))
echo $PROJECT_PATH

# load .env
source $PROJECT_PATH/bin/loadenv.sh


# MySQL DB Backup Settings
MONTH=$(date +%Y%m)
DAY=$(date +%d)
TIME=$(date +%Y%m%d)_$(date +%H%M%S)

backupPath="$PROJECT_PATH/db/dumps"
# backupPath="MyLocal:$PROJECT_PATH/db/dumps"
# backupPath="DockerContainer:/var/lib/mysql/dumps"
FILENAME="mysql_date_dumps_$TIME.sql"  # mysql_date_dumps_{년월일}_{시분초}.sql

# 백업 경로가 없는 경우, 생성
if [ ! -d $backupPath/$MONTH/$DAY ]
then
mkdir -p $backupPath/$MONTH/$DAY
fi


# 지정 지정 DB Table 을 지정 경로로 백업
docker exec $PROJECT_DATABASE_NAME /usr/bin/mysqldump \
    -u $MYSQL_ROOT_USER --password=$MYSQL_ROOT_PASSWORD $MYSQL_DATABASE \
    > $backupPath/$MONTH/$DAY/$FILENAME
