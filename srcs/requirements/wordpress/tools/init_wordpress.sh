#!/bin/bash
set -e

# ----------------------------------------------------
# Read secrets
# ----------------------------------------------------
WP_DATABASE_PASSWORD="$(cat /run/secrets/db_password)"
WP_ADMIN_PASSWORD="$(cat /run/secrets/wp_admin_password)"
WP_USER_PASSWORD="$(cat /run/secrets/wp_user_password)"

# ----------------------------------------------------
# Check required vars
# ----------------------------------------------------
REQUIRED_VARS="WP_DATABASE WP_DATABASE_USER WP_DATABASE_PASSWORD WP_ADMIN WP_ADMIN_PASSWORD WP_ADMIN_EMAIL WP_URL"
for var in $REQUIRED_VARS; do
    if [ -z "${!var}" ]; then
        echo "[ERROR] Missing required variable: $var"
        exit 1
    fi
done

# ----------------------------------------------------
# Ensure php-fpm directory exists
# ----------------------------------------------------
mkdir -p /run/php
chown www-data:www-data /run/php

# ----------------------------------------------------
# Wait for MariaDB
# ----------------------------------------------------
echo "[INFO] Waiting for MariaDB..."
until mysqladmin ping -h "$MYSQL_HOST" -u"$WP_DATABASE_USER" -p"$WP_DATABASE_PASSWORD" --silent; do
    echo "  ...still waiting"
    sleep 2
done
echo "[INFO] MariaDB is UP"

# ----------------------------------------------------
# Install WordPress if not present
# ----------------------------------------------------
cd /var/www/wordpress

if [ ! -f wp-config.php ]; then
    echo "[INFO] Downloading WordPress..."
    wp core download --allow-root

    echo "[INFO] Creating wp-config.php..."
    wp config create \
        --dbname="$WP_DATABASE" \
        --dbuser="$WP_DATABASE_USER" \
        --dbpass="$WP_DATABASE_PASSWORD" \
        --dbhost="$MYSQL_HOST" \
        --dbprefix="${WP_TABLE_PREFIX:-wp_}" \
        --allow-root

    echo "[INFO] Installing WordPress..."
    wp core install \
        --url="$WP_URL" \
        --title="$WP_TITLE" \
        --admin_user="$WP_ADMIN" \
        --admin_password="$WP_ADMIN_PASSWORD" \
        --admin_email="$WP_ADMIN_EMAIL" \
        --skip-email \
        --allow-root

    echo "[INFO] Creating editor user..."
    wp user create "$WP_USER_NAME" "$WP_USER_EMAIL" \
        --role=editor \
        --user_pass="$WP_USER_PASSWORD" \
        --allow-root

    # echo "[INFO] Installing Redis plugin (if Redis is available)..."
    # wp plugin install redis-cache --activate --allow-root || true

    echo "[INFO] WordPress installation completed!"

    # # ----------------------------------------------------
    # # Fix site URL and home if using custom port
    # # ----------------------------------------------------
    # docker exec -it wordpress wp option update siteurl "https://ndabbous.42.fr:4403" --allow-root
    # docker exec -it wordpress wp option update home "https://ndabbous.42.fr:4403" --allow-root

    # docker exec -it wordpress wp option get siteurl --allow-root
    # docker exec -it wordpress wp option get home --allow-root


else
    echo "[INFO] WordPress already installed."
fi

# ----------------------------------------------------
# Configure PHP-FPM to listen on TCP 0.0.0.0:9000
# ----------------------------------------------------
PHP_VERSION=$(php -r 'echo PHP_MAJOR_VERSION.".".PHP_MINOR_VERSION;')
PHP_POOL_CONF="/etc/php/$PHP_VERSION/fpm/pool.d/www.conf"

echo "[INFO] Configuring PHP-FPM: $PHP_POOL_CONF"
cat > "$PHP_POOL_CONF" <<'EOF'
[www]
user = www-data
group = www-data

listen = 0.0.0.0:9000
listen.owner = www-data
listen.group = www-data
listen.mode = 0666

pm = dynamic
pm.max_children = 5
pm.start_servers = 2
pm.min_spare_servers = 1
pm.max_spare_servers = 3

clear_env = no
EOF

# ----------------------------------------------------
# Permissions
# ----------------------------------------------------
chown -R www-data:www-data /var/www/wordpress
chmod -R 775 /var/www/wordpress

# ----------------------------------------------------
# Start PHP-FPM
# ----------------------------------------------------
echo "[INFO] Starting PHP-FPM..."
exec php-fpm8.2 -F -R
