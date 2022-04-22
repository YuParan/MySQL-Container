---

# MySQL DB Template (with Docker-Container)

MySQL DB 를 도커 콘테이너 환경에서 관리 & 배포 할 수 있도록 Template 화 한 저장소 입니다.

기본적인 환경 세팅 및 동작, 데이터 저장 공간 관리 등 MySQL DB 를 활용하는데 필수적인 내용들이 구성되어 있습니다.

---

## 개요

### 기본적인 구성

- DB 구성을 위한 주요 환경 변수는 `.env` 와 `db/conf.d/my.cnf` 파일을 참조하도록 작성

- `.env` 파일 참조하여 Docker Image/Container 환경 구성 및 배포가 가능하도록 스크립트 작성

  - /bin/build_docker_image.sh
    
  - docker-compose.yml

- DB 백업을 위한 Dump 스크립트 작성

---

## 초기 실행

### Dependency

```text
Docker & Docker-Compose 가 동작 가능한 환경
```

### Skeleton

```
└── MySQL-Container
    ├── /bin
    │   ├── backup.sh
    │   ├── build_docker_image.sh
    │   └── loadenv.sh
    │
    ├── /db
    │   ├── /conf.d
    │   │   └── my.cnf
    │   │
    │   ├── /data      # MySQL DB 내부 데이터 Volume Bind Mount 경로
    │   ├── /dumps     # MySQL Data Backup 파일 덤핑 경로
    │   └── /initdb.d
    │
* ! ├── .env
    ├── .env-sample.txt
    ├── .gitignore
!   ├── docker-compose.yml
    ├── Dockerfile
    └── README.md
```

Repository 에는 다음과 같이 `*` 표시된 경로 & 파일들이 빠져있습니다.
( 미 세팅시 MySQL-Container 가 정상 동작하지 않습니다 )
- `.env-sample.txt` 파일을 참고하여 `.env` 세팅 (DB 구성 및 접속을 위한 및 환경변수 값을 설정)

프로젝트 DB 구성을 위해 `!` 표시된 파일들의 내용 수정이 필요합니다.
- 대부분 시스템 환경 세팅은 `.env` 수정으로 변경됩니다.

- Docker Container 실행 환경 설정은 `docker-compose.yml` 의 내용을 수정해서 적용할 수 있습니다.

---

### Run

1. git clone
   
2. `.env-sample.txt` 파일을 참고하여 프로젝트 최상위 경로에 `.env` 파일 세팅

3. `./bin/build_docker_image.sh` 명령어를 활용해 `.env` 의 설정이 적용된 Docker Image 를 빌드

4. 3에서 구성된 Docker Image 를 기반으로 Container 실행
   
   ```bash
   # 프로젝트 최상위 경로에서
   docker-compose up -d
   ```

5. 상황에 따라 아래 작성된 `Trouble Shooting` 의 첫번째 항목(root 계정의 외부 접근 막기)을 진행

   ( 동작 확인도 겸하여 `docker-container > mysql` 접속해서 user 권한 확인 해보는것을 권장 )

6. docker-compose 중단

   ```bash
   docker-compose down
   ```

---

## Trouble Shooting

### 모든 외부 접속이 허용된 root 계정의 접근 권한 막기

MySQL 8.x 이상의 버전에서 발생한 이슈입니다.

최초 Docker Container 활용해 MySQL 콘테이너를 실행하면, 
`.env` 의 설정을 활용해 기본 생성된 root 계정의 외부 접속권한이 
'%' 로 모두 열린것을 확인 할 수 있습니다.

1. MySQL DB 에 접속해 user 별 host 접속 권한 확인

   - docker-compose up -d 가 실행되어 Container 가 동작중인 상태에서 진행
   
   1. docker container 접속
      ```bash
      docker exec -it {$PROJECT_DATABASE_NAME} /bin/bash
      ```
   
   2. mysql 접속
      ```bash
      ...
      root@b7f6383f60af:/# mysql -u root -p
      Enter password:
      ...
   
      # 접속 성공시 `mysql>` 로 터미널 커서가 바뀜
      mysql>
      ```
      
   3. user 별 host 접속 권한 확인
      ```bash
      select user, host from mysql.user;
   
      # 출력 >>>
      | user             | host      |
      +------------------+-----------+
      | mysql-user       | %         |
      | root             | %         |
      | mysql.infoschema | localhost |
      | mysql.session    | localhost |
      | mysql.sys        | localhost |
      | root             | localhost |
      +------------------+-----------+
      6 rows in set (0.00 sec)
      ```
      
      위의 출력 예시와 같이 `root@'%'` 로 나타나는 user 와 (위에서 2번째 user 정보)
      
      `root@'localhost'` 로 나타나는 user (위에서 6번째 user 정보) 가 모두 있는 경우, 
   
      해당 MySQL DB 의 root user 는 모든 외부 host 로부터의 접속이 허용된 상태

      (만약 `root@'localhost'` 만 존재한다면 루트 권한을 가진 사용자의 접속은 해당 콘테이너 내부에서만 가능하므로 괜찮습니다.)

2. `root@'%'` 를 drop 하여 외부 host 의 접근 권한을 차단

   ```bash
   # mysql 에 root user 로 접속된 상태에서 진행
   drop user root@%;
   
   # 재확인
   select user, host from mysql.user;
   
   # 출력 >>>
   | user             | host      |
   +------------------+-----------+
   | mysql-user       | %         |
   | mysql.infoschema | localhost |
   | mysql.session    | localhost |
   | mysql.sys        | localhost |
   | root             | localhost |
   +------------------+-----------+
   5 rows in set (0.00 sec)
   
   # 변경사항 반영
   FLUSH PRIVILEGES;
   ```
   
위의 `root@'%'` 문제와 반대로, 기존에 생성된 사용자의 일반 계정의 host 가 '%' 로 설정되어 있지 않다면, 
해당 사용자는 외부 접속이 불가능하므로, 아래 trouble-shooting 을 진행

위의 `select user, host from mysql.user;` 예시에선 `mysql-user@'%'` 를 확인할 수 있습니다.


### 외부(Lightsail / EC2 or Remote-PC)에서 DB 접근이 가능하도록 권한 부여

[참고 페이지](https://velog.io/@jwoo/DB-및-계정-생성과-권한-부여-ver.8.0.26)

localhost 에서만 접근 가능한 MYSQL_USER 의 외부 접속을 허용하기 위해선 
해당 계정에 접근 가능한 IP 를 특정하여 접근 권한을 부여해줘야 합니다.

- mysql> 로 시작되는 아래 명령어들은 mysql 전용 명령어 이므로, MySQL DB 에 접속하여 명령어를 입력해야 (~쿼리를 요청해야) 동작합니다.

1. 계정의 외부 접근권한 부여
   ```bash
   # 1-1. 기존 계정의 외부 접근권한 부여
   mysql> ALTER USER '{MYSQL_USER}'@'%' IDENTIFIED WITH mysql_native_password BY '{기존 계정의 password 입력}';
   ## ex. > ALTER USER 'yuparan'@'%' IDENTIFIED WITH mysql_native_password BY 'paran1234';
   
   # 1-2. 신규 계정 생성 및 해당 계정의 외부 접근권한 부여
   mysql> CREATE USER '{NEW_MYSQL_USER}'@'%' IDENTIFIED BY '{생성될 계정의 password 입력}';
   
   # @'%' 에 작성된 '%' 는 모든 외부 IP 의 접속을 허용한다는 의미 
   # 특정 IP 만 허용하고 싶다면 '%' 대신 IP 를 적어주면 됩니다 (ex. @'192.168.0.1')
   ```

2. 접근권한이 부여된 계정에 따른 Database 의 접근권한 부여
   ```bash
   # 2-1. 기존 생성된 Database 의 계정별 외부 접근 권한 부여
   mysql> GRANT ALL PRIVILEGES ON {MYSQL_DATABASE}.* TO '{신규/기존 MYSQL_USER}'@'%';
   ## ex. > GRANT ALL PRIVILEGES ON mydata.* TO 'yuparan'@'%';
   
   # 2-2. 신규 Database 를 생성하고, 생성된 Database 의 계정별 외부 접근 권한 부여
   mysql> GRANT ALL PRIVILEGES ON {NEW_MYSQL_DATABASE}.* TO '{신규/기존 MYSQL_USER}'@'%';
   ```

3. 변경사항 적용
   ```bash
   mysql> FLUSH PRIVILEGES;
   ```


### root 계정 패스워드를 잊어버리거나 로그인이 되지 않을 경우

1. MySQL DB 에 root 권한으로 PW 없이 우회 접속

    root 계정은 기본적으로 docker container 내부에서만 접근 가능

    1. PW 없이 root 접근이 가능하도록 my.cnf 의 설정을 하나 추가
    
        ```yaml
        [mysqld]
        character-set-client-handshake = FALSE
        character-set-server           = utf8mb4
        collation-server               = utf8mb4_unicode_ci
        ...
        # 아래 새로 추가
        skip-grant-tables              = TRUE
        ```
    
    2. `docker-compose down && docker-compose up -d` 이후 컨텐이너에 접속해서 mysql 에 PW 없이 접근
    
        ```bash
        # 콘테이너에 접속
        $ docker exec -it $PROJECT_DATABASE_NAME /bin/bash
        
        # 콘테이너 내부에서 mysql 접속 - password 는 엔터만 입력
        ...
        root@b7f6383f60af:/# mysql -u root -p
        Enter password:
        ...
        
        # 접속 성공시 `mysql>` 로 터미널 커서가 바뀜
        mysql> 
        ```
   
2. MySQL Database 의 root 설정 변경
    
    1. System Database 인 mysql 에 접속
    
       ```bash
       # 전체 database 확인
       mysql> show databases;
       
       # 시스템 DB 인 mysql 을 사용하도록 선언
       mysql> use mysql;
       ```

    2. root 비밀번호 변경
    
       ```bash
       mysql> ALTER USER 'root'@'localhost' IDENTIFIED BY '{변경할 Password}';
       # {변경할 Password} 는 `.env` 파일에 작성된 MYSQL_ROOT_PASSWORD 값과 같아야 합니다
       ```
    
    3. 변경 된 root 계정의 내용을 DB 에 적용
    
       ```bash
       mysql> FLUSH PRIVILEGES;
       ```
    
3. root 로그인 세팅 복구 & mysql container 재시작
    
    1. 처음 1번에서 추가했던, my.cnf 의 내부 설정(`skip-grant-tables = TRUE`)을 제거
       
    2. `docker-compose down && docker-compose up -d`
   
4. 다시 PW 와 함께 root 계정으로 로그인하여 변경된 Password 동작 최종 테스트


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
