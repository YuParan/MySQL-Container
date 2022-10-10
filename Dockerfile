# ARG Env-Parameter:
ARG MYSQL_VERSION=8.0.30

# Base Image
FROM mysql:${MYSQL_VERSION}

# Open Port for the Python App
EXPOSE 3306