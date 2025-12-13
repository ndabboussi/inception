# MARIADB
FROM debian:bookworm

# Install MariaDB server
RUN	apt update -y && \
	apt upgrade -y && \
	apt-get install mariadb-server mariadb-client -y && \
	apt clean && \
	rm -rf /var/lib/apt/lists/*

RUN mkdir -p /var/lib/mysql /var/run/mysqld && \
    chown -R mysql:mysql /var/lib/mysql /var/run/mysqld

COPY tools/init_database.sh /init_database.sh
RUN chmod +x /init_database.sh

EXPOSE 3306

ENTRYPOINT ["/init_database.sh"]
