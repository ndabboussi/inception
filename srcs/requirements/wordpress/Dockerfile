# WORDPRESS
FROM debian:bookworm

RUN apt update && apt install -y \
    php8.2-fpm php8.2-mysql php-curl php-gd php-xml php-mbstring php-zip \
    && apt-get -y install wget curl mariadb-client less ca-certificates \
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



# FROM debian:bookworm

# RUN apt update && apt-get install -y \
#     php-fpm \
#     php-mysql \
#     php-xml \
#     php-zip \
#     && apt-get -y install wget curl mariadb-client \
#     && apt upgrade -y \
#     && apt clean \
#     && rm -rf /var/lib/apt/lists/*

# RUN mkdir -p /var/www/wordpress
# RUN chown -R www-data:www-data /var/www/wordpress

# # RUN wget https://fr.wordpress.org/wordpress-6.0-fr_FR.tar.gz -P /var/www
# # RUN cd /var/www && tar -xzf wordpress-6.0-fr_FR.tar.gz && rm wordpress-6.0-fr_FR.tar.gz

# # Download latest stable WordPress in French
# RUN wget https://fr.wordpress.org/latest-fr_FR.tar.gz -O /tmp/wordpress.tar.gz \
#     && tar -xzf /tmp/wordpress.tar.gz --strip-components=1 -C /var/www/wordpress \
#     && rm /tmp/wordpress.tar.gz

# COPY ./tools/init_wordpress.sh /init_wordpress.sh
# RUN chmod +x /init_wordpress.sh

# RUN sed -i 's|^listen = .*|listen = 0.0.0.0:9000|' /etc/php/8.2/fpm/pool.d/www.conf \
#  && sed -i 's|^;listen.allowed_clients.*|listen.allowed_clients = 0.0.0.0|' /etc/php/8.2/fpm/pool.d/www.conf

# EXPOSE 9000

# ENTRYPOINT ["/init_wordpress.sh"]
