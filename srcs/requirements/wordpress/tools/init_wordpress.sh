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

# PHP_FPM_BIN=$(which php-fpm8.2 || which php-fpm || true)
# if [ -z "$PHP_FPM_BIN" ]; then
#     echo "[ERROR] php-fpm binary not found!"
#     exit 1
# fi

# while [ ! -f /var/www/wordpress/index.php ]; do
#     echo "Waiting for WordPress files..."
#     sleep 1
# done
# exec "$PHP_FPM_BIN" -F



# #!/bin/bash
# set -e

# # -------------------------
# # Environment variables
# # -------------------------

# WP_DATABASE_PASSWORD="$(cat /run/secrets/db_password)"
# WP_ADMIN_PASSWORD="$(cat /run/secrets/wp_admin_password)"
# WP_USER_PASSWORD="$(cat /run/secrets/wp_user_password)"

# if [ -z "$WP_DATABASE" ] || [ -z "$WP_DATABASE_USER" ] || [ -z "$WP_DATABASE_PASSWORD" ] || [ -z "$WP_ADMIN" ] || [ -z "$WP_ADMIN_PASSWORD" ] || [ -z "$WP_ADMIN_EMAIL" ]; then
#     echo "[Error] Required environment variables WP_DATABASE, WP_DATABASE_USER, WP_DATABASE_PASSWORD, BASE_HOST, WP_ADMIN, WP_ADMIN_PASSWORD, or WP_ADMIN_EMAIL are not set."
#     exit 1
# fi

# # -------------------------
# # Create PHP-FPM socket directory
# # -------------------------
# mkdir -p /run/php
# chown www-data:www-data /run/php

# # -------------------------
# # Wait for MariaDB
# # -------------------------
# echo "[INFO] Waiting for MariaDB..."
# until mysqladmin ping -h "mariadb" -u"$WP_DATABASE_USER" -p"$WP_DATABASE_PASSWORD" --silent; do
#     echo "[INFO] Database not ready. Retrying..."
#     sleep 2
# done
# echo "[INFO] MariaDB is ready!"

# # -------------------------
# # Setup WordPress
# # -------------------------
# cd /var/www/wordpress

# if [ ! -f wp-config.php ]; then
#     echo "[INFO] Downloading WordPress..."
#     wp core download --path=/var/www/wordpress --allow-root

#     echo "[INFO] Creating wp-config.php..."
#     wp config create --path=/var/www/wordpress \
#                      --dbname="$WP_DATABASE" \
#                      --dbuser="$WP_DATABASE_USER" \
#                      --dbpass="$WP_DATABASE_PASSWORD" \
#                      --dbhost="mariadb" \
#                      --dbprefix="$WP_TABLE_PREFIX" \
#                      --allow-root

#     echo "[INFO] Installing WordPress..."
#     wp core install --path=/var/www/wordpress \
#                     --url="$WP_URL" \
#                     --title="$WP_TITLE" \
#                     --admin_user="$WP_ADMIN" \
#                     --admin_password="$WP_ADMIN_PASSWORD" \
#                     --admin_email="$WP_ADMIN_EMAIL" \
#                     --allow-root

#     echo "[INFO] Creating additional user..."
#     wp user create "$WP_USER_NAME" "$WP_USER_EMAIL" \
#                    --role=editor \
#                    --user_pass="$WP_USER_PASSWORD" \
#                    --allow-root

#     wp plugin install --path=/var/www/wordpress \
#                 redis-cache \
#                 --activate \
#                 --allow-root

#     echo "[INFO] Configure Redis settings in wp-config.php..."
#     wp config set --path=/var/www/wordpress WP_REDIS_HOST redis --allow-root
#     wp config set --path=/var/www/wordpress WP_REDIS_PORT 6379 --allow-root
#     wp config set --path=/var/www/wordpress WP_REDIS_TIMEOUT 1 --allow-root
#     wp config set --path=/var/www/wordpress WP_REDIS_READ_TIMEOUT 1 --allow-root
#     wp config set --path=/var/www/wordpress WP_REDIS_DATABASE 0 --allow-root

#     echo "[INFO] Creating user..."
#     wp user create      --path=/var/www/wordpress \
#                         "$WP_USER_NAME" \
#                         "$WP_USER_EMAIL" \
#                         --role=editor \
#                         --user_pass="$WP_USER_PASSWORD" \
#                         --allow-root

#     wp redis enable --path=/var/www/wordpress --allow-root

#     echo "[INFO] WordPress setup completed!"

# else
#     echo "[INFO] WordPress already configured."
# fi

# # -------------------------
# # Force php-fpm to listen on TCP
# # -------------------------

# PHP_VERSION=$(php -r 'echo PHP_MAJOR_VERSION.".".PHP_MINOR_VERSION;')
# PHP_POOL_CONF="/etc/php/$PHP_VERSION/fpm/pool.d/www.conf"

# if [ -f "$PHP_POOL_CONF" ]; then
#     sed -i 's|listen = .*|listen = 0.0.0.0:9000|' "$PHP_POOL_CONF"
#     sed -i 's|listen.allowed_clients.*|listen.allowed_clients = 0.0.0.0|' "$PHP_POOL_CONF"
# else
#     echo "[ERROR] PHP pool config $PHP_POOL_CONF not found!"
#     exit 1
# fi

# # -------------------------
# # Fix permissions
# # -------------------------
# chown -R www-data:www-data /var/www/wordpress
# chmod -R 775 /var/www/wordpress

# # -------------------------
# # Start php-fpm in foreground
# # -------------------------
# exec php-fpm -F






# #!/bin/bash

# set -e

# if [ -z "$WP_DATABASE" ] || [ -z "$WP_DATABASE_USER" ] || [ -z "$WP_DATABASE_PASSWORD" ] || [ -z "$WP_ADMIN" ] || [ -z "$WP_ADMIN_PASSWORD" ] || [ -z "$WP_ADMIN_EMAIL" ]; then
#     echo "Error: Required environment variables WP_DATABASE, WP_DATABASE_USER, WP_DATABASE_PASSWORD, BASE_HOST, WP_ADMIN, WP_ADMIN_PASSWORD, or WP_ADMIN_EMAIL are not set."
#     exit 1
# fi

# # Create PHP-FPM socket directory
# mkdir -p /run/php
# chown www-data:www-data /run/php

# # Test database connection
# echo "Testing database connection..."
# while ! mysqladmin ping -h"mariadb" -u"$WP_DATABASE_USER" -p"$WP_DATABASE_PASSWORD" --silent; do
#     echo "Database connection test failed. Retrying..."
#     sleep 2
# done
# echo "Database connection successful!"

# # Download WordPress if not present
# if [ ! -f /var/www/html/wp-config.php ]; then
#     echo "Setting up WordPress..."
#     wp core download    --path=/var/www/html \
#                         --allow-root

#     wp config create    --path=/var/www/html \
#                         --dbname=$WP_DATABASE \
#                         --dbuser=$WP_DATABASE_USER \
#                         --dbpass=$WP_DATABASE_PASSWORD \
#                         --dbhost=mariadb \
#                         --dbprefix=$WP_TABLE_PREFIX \
#                         --allow-root

#     wp core install     --path=/var/www/html \
#                         --url="$WP_URL" \
#                         --title="$WP_TITLE" \
#                         --admin_user="$WP_ADMIN" \
#                         --admin_password="$WP_ADMIN_PASSWORD" \
#                         --admin_email="$WP_ADMIN_EMAIL" \
#                         --allow-root

#     wp plugin install --path=/var/www/html \
#                 redis-cache \
#                 --activate \
#                 --allow-root

#     # Configure Redis settings in wp-config.php
#     wp config set --path=/var/www/html WP_REDIS_HOST redis --allow-root
#     wp config set --path=/var/www/html WP_REDIS_PORT 6379 --allow-root
#     wp config set --path=/var/www/html WP_REDIS_TIMEOUT 1 --allow-root
#     wp config set --path=/var/www/html WP_REDIS_READ_TIMEOUT 1 --allow-root
#     wp config set --path=/var/www/html WP_REDIS_DATABASE 0 --allow-root

#     wp user create      --path=/var/www/html \
#                         "$WP_USER_NAME" \
#                         "$WP_USER_EMAIL" \
#                         --role=editor \
#                         --user_pass="$WP_USER_PASSWORD" \
#                         --allow-root

#     wp redis enable --path=/var/www/html --allow-root
    
#     echo "WordPress setup completed!"
# else
#     echo "WordPress already configured."
# fi

# sed -i 's/listen = \/run\/php\/php7.4-fpm.sock/listen = 0.0.0.0:9000/' /etc/php/7.4/fpm/pool.d/www.conf

# # Set permissions Redis friendly
# chown -R 1000:1000 /var/www/html
# chmod -R 775 /var/www/html

# # Start PHP-FPM in the foreground
# exec php-fpm7.4 -F




# #!/bin/sh
# set -e

# cd /var/www/wordpress

# MYSQL_PASSWORD="$(cat /run/secrets/db_password)"

# # Wait for MariaDB
# until mysql -h mariadb -u"$MYSQL_USER" -p"$MYSQL_PASSWORD" -e "SHOW DATABASES;" 2> /dev/null; do
#     echo "[INFO] Waiting for MariaDB..."
#     sleep 1
# done

# # Generate wp-config.php if missing
# if [ ! -f wp-config.php ]; then
#     cp wp-config-sample.php wp-config.php

#     sed -i "s/database_name_here/$MYSQL_DATABASE/" wp-config.php
#     sed -i "s/username_here/$MYSQL_USER/" wp-config.php
#     sed -i "s/password_here/$MYSQL_PASSWORD/" wp-config.php
#     sed -i "s/localhost/mariadb/" wp-config.php
# fi

# exec php-fpm8.2 -F

# --allow-root