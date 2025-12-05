FROM debian:bookworm

RUN apt update && apt install -y \
    php-fpm php-mysql curl \
    && apt clean \
    && rm -rf /var/lib/apt/lists/*

# COPY config/www.conf /etc/php/8.2/fpm/pool.d/www.conf

RUN mkdir -p /var/www/wordpress
RUN chown -R www-data:www-data /var/www/wordpress

CMD ["php-fpm8.2", "-F"]
