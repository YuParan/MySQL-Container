### 외부(Lightsail, EC2 or Remote-PC)에서 DB 접근이 가능하도록 권한 부여

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
