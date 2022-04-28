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
