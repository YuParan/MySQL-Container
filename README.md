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

## 이슈

## Trouble Shooting

- [모든 외부 접속이 허용된 root 계정의 접근 권한 막기](/assets/fully-opened-root-access-permission-control.md)

- [외부(Lightsail, EC2 or Remote-PC)에서 DB 접근이 가능하도록 권한 부여](/assets/permission-for-remote-access.md)

- [root 계정 패스워드를 잊어버리거나 로그인이 되지 않을 경우](/assets/lost-root-password-or-cannot-login.md)

- [mysql 백업 세팅.md](/assets/mysql-backup-setting.md)

---

## TODO

- Python Client (단순 Client / Django) 연결 포함 
  
  Python 환경에서 MySQL 에 Client 연결 할 수 있도록, 샘플 코드 작성

  작성된 Python Client 는 `docker-compose` 환경에서 mysql 과 함께 동일한 네트워크 안에서 동작할 수 있도록 구성 

  가능하다면. DB CRUD 할 수 있는 테스트 예시 코드도 추가할 수 있다면 좋다!

  - **django-client 는 git submodule 추가 로 관리 할 수 있을지 고려**

    → 우선은 단일 python-client 만 먼저 생각하도록 하자 !
  
  신규 브랜치 별도 생성 - 브랜치 명 : python-mysql-client / django-mysql-client
