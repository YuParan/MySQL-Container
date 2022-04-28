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
