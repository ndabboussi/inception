#NGINX
FROM debian:bookworm

# Install nginx and openssl
RUN apt-get update && apt-get install -y \
    nginx \
    openssl \
    && apt update && apt install -y curl \
    && apt update && apt install -y netcat-openbsd \
    && rm -rf /var/lib/apt/lists/*

# Create SSL directory
RUN mkdir -p /etc/nginx/ssl

# Generate self-signed SSL cert
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

EXPOSE 443

# Ensure nginx runs in foreground (no daemon hacks)
CMD ["nginx", "-g", "daemon off;"]
