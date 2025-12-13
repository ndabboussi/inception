#!/bin/bash
set -e #safety mechanism to exit immediatly if any cmd fails, returning non-zero exit code

MYSQL_PASSWORD="$(cat /run/secrets/db_password)"
MYSQL_ROOT_PASSWORD="$(cat /run/secrets/db_root_password)"

# ---------------------------------------------------------
# Check required environment variables
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


# Ensure data directory exists
mkdir -p "$DB_DIR"
chown -R mysql:mysql "$DB_DIR"

# ---------------------------------------------------------
# Initialize if empty
# ---------------------------------------------------------
if [ ! -d "$DB_DIR/mysql" ] || [ -z "$(ls -A $DB_DIR/mysql 2>/dev/null)" ]; then
    echo "[INFO] Initializing MariaDB..."
    mysql_install_db --user=mysql --ldata="$DB_DIR"
    echo "[INFO] Starting temporary MariaDB for initial setup..."
    mysqld_safe --datadir="$DB_DIR" --bind-address=127.0.0.1 &
    pid=$!

    # Wait until MariaDB is ready
    until mysqladmin ping -h 127.0.0.1 --silent; do
        sleep 1
    done

    echo "[INFO] Creating database and user..."
    mysql -h 127.0.0.1 -u root <<EOF
CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\`;
CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'%';
ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';
ALTER USER 'root'@'%' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';
GRANT ALL PRIVILEGES ON *.* TO 'Nina'@'localhost' IDENTIFIED BY 'THE_PASSWORD';
FLUSH PRIVILEGES;
EOF

    echo "[INFO] Shutting down temporary MariaDB..."
    mysqladmin -u root -p"$MYSQL_ROOT_PASSWORD" shutdown
fi

echo "[INFO] Starting MariaDB in foreground..."
exec mysqld_safe --datadir="$DB_DIR" --bind-address=0.0.0.0
