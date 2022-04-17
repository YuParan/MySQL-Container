# ARG Env-Parameter:
ARG MYSQL_VERSION=8.0.26
ARG MYSQL_PORT=3306

# Base Image
FROM mysql:${MYSQL_VERSION}

# Open Port for the Python App
EXPOSE ${MYSQL_PORT}