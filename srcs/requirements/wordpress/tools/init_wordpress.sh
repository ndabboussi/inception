#!/bin/sh
set -e

# Basic required environment variables
: "${MYSQL_DATABASE:?Missing MYSQL_DATABASE}"
: "${MYSQL_USER:?Missing MYSQL_USER}"
: "${MYSQL_HOST:=mariadb}"

# Read DB password from Docker secret
if [ -f "/run/secrets/db_password" ]; then
    MYSQL_PASSWORD="$(cat /run/secrets/db_password)"
else
    echo "[ERROR] Missing /run/secrets/db_password"
    exit 1
fi

# Create WordPress directory if missing
mkdir -p /var/www/wordpress
chown -R www-data:www-data /var/www/wordpress

echo "[INFO] Simple entrypoint starting php-fpm..."
exec php-fpm -F
