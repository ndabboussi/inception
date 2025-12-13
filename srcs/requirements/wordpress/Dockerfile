# WORDPRESS
FROM debian:bookworm

RUN apt update && apt install -y \
    php8.2-fpm php8.2-mysql php-curl php-gd php-xml php-mbstring php-zip \
    && apt-get -y install wget curl mariadb-client less ca-certificates \
    && apt update && apt install -y net-tools \
    && apt clean && rm -rf /var/lib/apt/lists/*

# Install WP-CLI
RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
    && chmod +x wp-cli.phar \
    && mv wp-cli.phar /usr/local/bin/wp

# WordPress directory
RUN mkdir -p /var/www/wordpress && chown -R www-data:www-data /var/www/wordpress

# Copy entrypoint
COPY ./tools/init_wordpress.sh /init_wordpress.sh
RUN chmod +x /init_wordpress.sh

EXPOSE 9000

ENTRYPOINT ["/init_wordpress.sh"]
