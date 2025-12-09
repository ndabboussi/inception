#!/bin/bash
set -e #safety mechanisme to exit immediatly if any cmd fails, returning non-zero exit code

MYSQL_PASSWORD="$(cat "/run/secrets/db_password")"
MYSQL_ROOT_PASSWORD="$(cat "/run/secrets/db_root_password")"

# ---------------------------------------------------------
# 0) Check required environment variables
# ---------------------------------------------------------
if [ -z "$MYSQL_DATABASE" ]; then
    echo "[ERROR] Required environment variables SQL_DATABASE is not set."
    exit 1
fi

if [ -z "$MYSQL_USER" ]; then
    echo "[ERROR] Required environment variables SQL_USER is not set."
    exit 1
fi

if [ -z "$MYSQL_PASSWORD" ]; then
    echo "[ERROR] Required environment variables SQL_PASSWORD is not set."
    exit 1
fi

if [ -z "$MYSQL_ROOT_PASSWORD" ]; then
    echo "[ERROR] Required environment variables SQL_ROOT_PASSWORD is not set."
    exit 1
fi

DB_DIR="/var/lib/mysql" #stores all db files (tables, logs, etc)

echo "[INFO] Starting MariaDB initialization..."

# ---------------------------------------------------------
# 1) Detect if database was already initialized
# ---------------------------------------------------------
# if [ -d "$DB_DIR/ibdata1" ]; then
#     echo "[INFO] Database already initialized. Starting MariaDB normally..."
#     exec mysqld_safe --port=3306 --bind-address=0.0.0.0
#     # exit 0
# fi

# ---------------------------------------------------------
# 2) Secure initial database setup = Prepares a clean database ready to accept users and privileges.
# ---------------------------------------------------------
echo "[INFO] Initializing MariaDB data directory..."
mysql_install_db --user=mysql --ldata="$DB_DIR" > /dev/null 2>&1

# ---------------------------------------------------------
# 3) Apply SQL securely using --bootstrap
# ---------------------------------------------------------
echo "[INFO] Running initial SQL configuration..."

mariadbd --user=mysql --bootstrap <<EOF #runs the MariaDB daemon once for initial SQL commands, without starting the full server
-- Create root user with password
ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';

-- Create WordPress DB
CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\`;

-- Create WordPress user
CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';

-- Grant privileges
GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'%';

-- Apply changes
FLUSH PRIVILEGES;
EOF #a here-document, feeds multiple lines of SQL commands to the server

mysqladmin shutdown 
echo "[INFO] Initialization done."

# ---------------------------------------------------------
# 4) Start MariaDB normally
# ---------------------------------------------------------
# exec mysqld_safe

echo "[INFO] Starting MariaDB in the foreground..."
exec mysqld_safe --port=3306 --bind-address=0.0.0.0















#!/bin/bash
set -e #safety mechanism to exit immediatly if any cmd fails, returning non-zero exit code

MYSQL_PASSWORD="$(cat "/run/secrets/db_password")"
MYSQL_ROOT_PASSWORD="$(cat "/run/secrets/db_root_password")"

# ---------------------------------------------------------
# 0) Check required environment variables
# ---------------------------------------------------------
if [ -z "$MYSQL_DATABASE" ]; then
    echo "[ERROR] Required environment variables SQL_DATABASE is not set."
    exit 1
fi

if [ -z "$MYSQL_USER" ]; then
    echo "[ERROR] Required environment variables SQL_USER is not set."
    exit 1
fi

if [ -z "$MYSQL_PASSWORD" ]; then
    echo "[ERROR] Required environment variables SQL_PASSWORD is not set."
    exit 1
fi

if [ -z "$MYSQL_ROOT_PASSWORD" ]; then
    echo "[ERROR] Required environment variables SQL_ROOT_PASSWORD is not set."
    exit 1
fi


DB_DIR="/var/lib/mysql"

echo "[INFO] Starting MariaDB initialization..."
mysql_install_db --user=mysql --ldata="$DB_DIR" >/dev/null 2>&1

echo "[INFO] Running initial SQL configuration..."

mariadbd --user=mysql --bootstrap << EOF
ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';
CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\`;
CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'%';
FLUSH PRIVILEGES;
EOF

echo "[INFO] Initialization done."
echo "[INFO] Starting MariaDB in the foreground..."

exec mysqld_safe --port=3306 --bind-address=0.0.0.0


















#!/bin/bash
set -e #safety mechanism to exit immediatly if any cmd fails, returning non-zero exit code

MYSQL_PASSWORD="$(cat "/run/secrets/db_password")"
MYSQL_ROOT_PASSWORD="$(cat "/run/secrets/db_root_password")"

# ---------------------------------------------------------
# 0) Check required environment variables
# ---------------------------------------------------------
if [ -z "$MYSQL_DATABASE" ]; then
    echo "[ERROR] Required environment variables SQL_DATABASE is not set."
    exit 1
fi

if [ -z "$MYSQL_USER" ]; then
    echo "[ERROR] Required environment variables SQL_USER is not set."
    exit 1
fi

if [ -z "$MYSQL_PASSWORD" ]; then
    echo "[ERROR] Required environment variables SQL_PASSWORD is not set."
    exit 1
fi

if [ -z "$MYSQL_ROOT_PASSWORD" ]; then
    echo "[ERROR] Required environment variables SQL_ROOT_PASSWORD is not set."
    exit 1
fi

# ---------------------------------------------------------
# 1) Start temporary MariaDB
# ---------------------------------------------------------
mysqld_safe --datadir=/var/lib/mysql --skip-networking=0 &

echo "Waiting for MariaDB to start..."
while ! mysqladmin ping --silent; do
    sleep 1
done
echo "MariaDB temp started successfully."

# # ---------------------------------------------------------
# # 2) Run database creation using a HEREDOC
# # ---------------------------------------------------------

# echo "CREATE DATABASE IF NOT EXISTS \`$MYSQL_DATABASE\`;" > create_db.sql
# echo "CREATE USER IF NOT EXISTS '$MYSQL_USER'@'%' IDENTIFIED BY '$MYSQL_PASSWORD';" >> create_db.sql
# echo "GRANT ALL PRIVILEGES ON \`$MYSQL_DATABASE\`.* TO '$MYSQL_USER'@'%';" >> create_db.sql
# echo "FLUSH PRIVILEGES;" >> create_db.sql

# mariadb < create_db.sql
# rm create_db.sql

# mysqladmin shutdown

# echo "Starting MariaDB in the foreground..."

# # Start MariaDB in the foreground with proper binding
# exec mysqld_safe --port=3306 --bind-address=0.0.0.0 --datadir=/var/lib/mysql







# DB_DIR="/var/lib/mysql" #stores all db files (tables, logs, etc)

# echo "[INFO] Starting MariaDB initialization..."
# echo "[INFO] Initializing MariaDB data directory with mysql_install_db..."
# mysql_install_db --user=mysql --ldata="$DB_DIR"

# mysqld_safe --datadir=/var/lib/mysql --skip-networking=0 &

# # Wait for MariaDB to start
# echo "Waiting for MariaDB to start..."
# while ! mysqladmin ping --silent; do
#     sleep 1
# done
# echo "MariaDB temp started successfully."

echo "[INFO] Running mysqld in bootstrap mode to create database & users..."

mysqld --user=mysql --bootstrap <<EOF
ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';
CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\`;
CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'%';

FLUSH PRIVILEGES;
EOF

echo "[INFO] Shutting down bootstrap server..."
mysqladmin --user=root --password="${MYSQL_ROOT_PASSWORD}" shutdown || true

echo "[INFO] Starting MariaDB in safe mode..."
exec mysqld_safe --port=3306 --bind-address=0.0.0.0
# exec mysqld_safe --datadir="$DB_DIR"

