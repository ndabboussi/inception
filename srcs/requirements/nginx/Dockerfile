FROM debian:bookworm

# Install nginx and openssl
RUN apt-get update && apt-get install -y \
    nginx \
    openssl \
    && rm -rf /var/lib/apt/lists/*

# Create SSL directory
RUN mkdir -p /etc/nginx/ssl

# Generate self-signed SSL cert
# DOMAIN_NAME will be passed from docker-compose via env_file
RUN openssl req -x509 -nodes -days 365 \
    -newkey rsa:2048 \
    -keyout /etc/nginx/ssl/selfsigned.key \
    -out /etc/nginx/ssl/selfsigned.crt \
    -subj "/C=FR/ST=Paris/L=Paris/O=42/OU=Inception/CN=ndabbous.42.fr"

# Copy custom NGINX config
COPY conf/nginx.conf /etc/nginx/nginx.conf

# Allow web directory
RUN mkdir -p /var/www/wordpress
RUN chown -R www-data:www-data /var/www/wordpress

# Ensure nginx runs in foreground (no daemon hacks)
CMD ["nginx", "-g", "daemon off;"]






# # VERSION 1
# LABEL version="1.0" maintainer="ndabbous "

# RUN	apt update && \
# 	apt install -y nginx openssl && \
# 	apt upgrade -y && \
# 	apt clean && \
# 	rm -rf /var/lib/apt/lists/*

# # Create SSL certificate
# RUN mkdir -p /etc/nginx/ssl && \
#     openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
#     -keyout /etc/nginx/ssl/nginx.key \
#     -out /etc/nginx/ssl/nginx.crt \
#     -subj "/C=FR/ST=Paris/L=Paris/O=42/OU=42/CN=ndabbous.42.fr"

# COPY ./nginx.conf /etc/nginx/nginx.conf

# RUN chown -R www-data:www-data /var/www/wordpress && chmod -R 755 /var/www/wordpress
# RUN mkdir -p /var/run/nginx

# EXPOSE 443

# ENTRYPOINT ["nginx", "-g", "daemon off;"]





# VERSION 2
# RUN apt install vim -y
# RUN apt install curl -y
# RUN mkdir -p /etc/nginx/ssl
# RUN apt install OpenSSL -y

# #RUN openssl req -x509 -nodes -out /etc/nginx/ssl/inception.crt -keyout /etc/nginx/ssl/inception.key -subj "/C=FR/ST=IDF/L=Paris/O=42/OU=42/CN=login.42.fr/UID=login"
# RUN mkdir -p /var/run/nginx

# COPY conf/nginx.conf /etc/nginx/nginx.conf

# RUN chmod 755 /var/www/html
# RUN chown -R www-data:www-data /var/www/html 

# CMD [ "nginx", "-g", "daemon off;" ]

# -y automaticcaly answers 'yes' to package installation 

# # Install nginx and openssl
# RUN apt-get update && apt-get install -y \
#     nginx \
#     openssl \
#     && rm -rf /var/lib/apt/lists/*

# # Create SSL directory
# RUN mkdir -p /etc/nginx/ssl

# # Generate self-signed SSL cert
# # DOMAIN_NAME will be passed from docker-compose via env_file
# RUN openssl req -x509 -nodes -days 365 \
#     -newkey rsa:2048 \
#     -keyout /etc/nginx/ssl/selfsigned.key \
#     -out /etc/nginx/ssl/selfsigned.crt \
#     -subj "/C=FR/ST=Paris/L=Paris/O=42/OU=Inception/CN=localhost"

# # Copy custom NGINX config
# COPY conf/nginx.conf /etc/nginx/nginx.conf

# # Ensure nginx runs in foreground (no daemon hacks)
# CMD ["nginx", "-g", "daemon off;"]
