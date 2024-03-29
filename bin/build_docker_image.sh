#!/bin/bash

# Get AbPath
PROJECT_PATH=$(dirname $(cd $(dirname $0) && pwd -P))
echo $PROJECT_PATH

# load .env
source $PROJECT_PATH/bin/loadenv.sh

# Cross-platform CPU(M1 Mac) 대응을 위해 `--platform linux/amd64` 가 필요 합니다
docker build --platform linux/amd64 \
    --build-arg MYSQL_VERSION=$MYSQL_VERSION \
    -t $PROJECT_DATABASE_NAME:mysql-$MYSQL_VERSION .
