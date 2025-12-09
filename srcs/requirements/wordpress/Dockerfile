FROM debian:bookworm

RUN apt update && apt-get install -y \
    php-fpm \
    php-mysql \
    php-xml \
    php-zip \
    && apt-get -y install wget curl mariadb-client \
    && apt upgrade -y \
    && apt clean \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /var/www/wordpress
RUN chown -R www-data:www-data /var/www/wordpress

RUN wget https://fr.wordpress.org/wordpress-6.0-fr_FR.tar.gz -P /var/www
RUN cd /var/www && tar -xzf wordpress-6.0-fr_FR.tar.gz && rm wordpress-6.0-fr_FR.tar.gz

RUN	chown -R root:root /var/www/wordpress
# COPY ./init_wordpress.sh /init_wordpress.sh
# RUN chmod +x /init_wordpress.sh

EXPOSE 9000

CMD ["php-fpm8.2", "-F"]
# ENTRYPOINT ["/init_wordpress.sh"]




# # WORDPRESS
# FROM debian:bookworm

# RUN apt update && \
#     apt install -y php-fpm php-mysql php-curl php-gd php-xml php-mbstring php-zip wget curl mariadb-client && \
#     apt upgrade -y && \
#     apt clean && \
#     rm -rf /var/lib/apt/lists/*

# # Install wp-cli
# RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && \
#     chmod +x wp-cli.phar && \
#     mv wp-cli.phar /usr/local/bin/wp

# # Copy initialization script
# COPY ./init_wordpress.sh /init_wordpress.sh
# RUN chmod +x /init_wordpress.sh

# EXPOSE 9000

# ENTRYPOINT ["/init_wordpress.sh"]





# FROM debian:bookworm

# # install php-fpm + extensions + utilities
# RUN apt-get update && apt-get install -y \
#     php-fpm php-mysql php-xml php-mbstring php-curl php-gd php-zip \
#     curl unzip less gnupg ca-certificates \
#   && rm -rf /var/lib/apt/lists/*

# # install wp-cli
# RUN curl -fsSL https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar -o /usr/local/bin/wp \
#  && chmod +x /usr/local/bin/wp \
#  && wp --info >/dev/null 2>&1 || true

# # create wp working dir and give permissions
# RUN mkdir -p /var/www/wordpress && chown -R www-data:www-data /var/www/wordpress

# COPY init_wordpress.sh /usr/local/bin/init_wordpress.sh
# RUN chmod +x /usr/local/bin/init_wordpress.sh

# WORKDIR /var/www/wordpress

# EXPOSE 9000

# # run entrypoint, then exec php-fpm in foreground (PID 1)
# ENTRYPOINT ["/usr/local/bin/init_wordpress.sh"]
# CMD ["php-fpm", "-F"]




