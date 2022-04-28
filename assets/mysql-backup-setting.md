### mysql 백업 세팅

[참고 사이트](https://elfinlas.github.io/2018/06/09/docker-mariadb-backup/)

1. /bin/backup.sh 작성
    
    ```bash
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
    ```
    
2. crontab 작성 - [참고](https://jdm.kr/blog/2)
    
    - 만약 서버 장비의 시간이 UTC 기준으로 동작중이라면 해당 시차를 고려하여 crontab 의 스케줄러를 작성할 필요가 있습니다.
    
      혹은 CRON_TZ=Asia/Seoul 을 작성하여 crontab 동작 TimeZone 을 설정 할 수도 있습니다.
    
      (CRON_TZ 변경 후, 필요시 `sudo service cron restart` 명령어를 활용해 crontab 재시작)
    
    - {PROJECT_PATH} 에는 실제 프로젝트 경로를 지정해줘야 합니다
    
    ```bash
    # crontab timezone
    CRON_TZ=Asia/Seoul
    
    # 매일 새벽(오전) 1시에 백업
    # mysql backup scheduler - @author:yuparan @edited:2022.04.18
    0 1 * * * {PROJECT_PATH}/bin/backup.sh
    ```
    
3. 작업결과 확인
    
    ```text
    지정한 경로에 sql 파일이 생겼는지 확인
    ```
