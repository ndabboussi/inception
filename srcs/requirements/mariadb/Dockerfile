FROM debian:bookworm

# Install MariaDB server
RUN	apt update -y && \
	apt upgrade -y && \
	apt-get install mariadb-server -y && \
	apt clean && \
	rm -rf /var/lib/apt/lists/*


RUN mkdir -p /run/mysqld && \
	# chown mysql:mysql /run/mysqld
	chown -R mysql:mysql /run/mysqld /var/lib/mysql

COPY tools/init_database.sh /init_database.sh
RUN chmod +x /init_database.sh

EXPOSE 3306

ENTRYPOINT ["/init_database.sh"]



# FROM debian:12-slim

# RUN apt-get update && \
#     DEBIAN_FRONTEND=noninteractive apt-get install -y mariadb-server && \
#     apt-get clean && rm -rf /var/lib/apt/lists/*

# # Create needed directories
# RUN mkdir -p /run/mysqld && \
#     chown -R mysql:mysql /run/mysqld && \
#     mkdir -p /var/lib/mysql && \
#     chown -R mysql:mysql /var/lib/mysql

# # Initialize database
# RUN mariadb-install-db \
#     --user=mysql \
#     --datadir=/var/lib/mysql \
#     --auth-root-authentication-method=normal

# EXPOSE 3306

# USER mysql

# CMD ["mysqld", "--datadir=/var/lib/mysql"]
