# inception

https://www.youtube.com/watch?v=eGz9DS-aIeY
https://www.youtube.com/watch?v=DM65_JyGxCo
https://www.youtube.com/watch?v=pg19Z8LL06w
https://devopssec.fr/article/decouverte-et-installation-de-docker
https://docs.docker.com/compose/

https://www.educative.io/blog/docker-compose-tutorial
https://www.aquasec.com/cloud-native-academy/docker-container/docker-networking/

Dockerfile instructions: https://www.nicelydev.com/docker/mots-cles-supplementaires-dockerfile#:~:text=Le%20mot%2Dcl%C3%A9%20EXPOSE%20permet,utiliser%20l'option%20%2Dp%20.

Docker and local host: https://www.youtube.com/watch?v=F2il_Mo5yww

NGINX: https://nginx.org/en/docs/beginners_guide.html


DOCKER IMAGES
## Afficher de l'aide
docker help
docker <sous-commande> --help

## Afficher des informations sur l'installation de Docker
docker --version
docker version
docker info

## Executer une image Docker
docker run hello-world

## Lister des images Docker
docker image ls
# ou
docker images

## Supprimer une image Docker
docker images rmi <IMAGE_ID ou IMAGE_NAME>  # si c'est le nom de l'image qui est spécifié alors il prendra par défaut le tag latest
    -f ou --force : forcer la suppression

## Supprimer tous les images Docker
docker rmi -f $(docker images -q)

## Rechercher une image depuis le Docker hub Registry
docker search ubuntu
    --filter "is-official=true" : Afficher que les images officielles

## Télécharger une image depuis le Docker hub Registry
docker pull <IMAGE_NAME>  # prendra par défaut le tag latest
docker pull ubuntu:16.04 # prendra le tag 16.04



DOCKER CONTAINER 
## Exécuter une image Docker
docker run <CONTAINER_ID ou CONTAINER_NAME>
    -t ou --tty : Allouer un pseudo TTY
    --interactive ou -i : Garder un STDIN ouvert
    --detach ou -d : Exécuter le conteneur en arrière-plan
    --name : Attribuer un nom au conteneur
    --expose: Exposer un port ou une plage de ports
    -p ou --publish : Mapper un port  "<PORT_CIBLE:PORT_SOURCE>"
    --rm : Supprimer automatiquement le conteneur quand on le quitte

## Lister des conteneurs en état running Docker
docker container ls
# ou
docker ps
    -a ou --all : Afficher tous les conteneurs peut-importe leur état

## Supprimer un conteneur Docker
docker rm <CONTAINER_ID ou CONTAINER_NAME>
    -f ou --force : forcer la suppression

## Supprimer tous les conteneurs Docker
docker rm -f $(docker ps -aq)

## Exécuter une commande dans un conteneur Docker
docker exec <CONTAINER_ID ou CONTAINER_NAME> <COMMAND_NAME>
    -t ou --tty : Allouer un pseudo TTY
    -i ou --interactive : Garder un STDIN ouvert
    -d ou --detach : lancer la commande en arrière plan

## sorties/erreurs d'un conteneur
docker logs <CONTAINER_ID ou CONTAINER_NAME>
    -f : suivre en permanence les logs du conteneur
    -t : afficher la date et l'heure de la réception de la ligne de log
    --tail <NOMBRE DE LIGNE> = nombre de lignes à afficher à partir de la fin (par défaut "all")


## Transformer un conteneur en image
docker commit <CONTAINER_NAME ou CONTAINER_ID> <NEW IMAGENAME>
    -a ou --author <string> : Nom de l'auteur (ex "John Hannibal Smith <hannibal@a-team.com>")
    -m ou --message <string> : Message du commit



DOCKER COMPOSE

## Exécuter les services du docker-compose.yml
docker-compose up
    -d : Exécuter les conteneurs en arrière-plan

## Lister des conteneurs du Docker Compose
docker-compose ls
    -a ou --all : afficher aussi les conteneurs stoppés

## Sorties/erreurs des conteneurs du Docker Compose
docker-compose logs
    -f : suivre en permanence les logs du conteneur
    -t : afficher la date et l'heure de la réception de la ligne de log
    --tail=<NOMBRE DE LIGNE> = nombre de lignes à afficher à partir de la fin pour chaque conteneur.

## Tuer les conteneurs du Docker Compose
docker-compose kill

## Stopper les conteneurs du Docker Compose
docker-compose stop
    -t ou --timeout : spécifier un timeout en seconde avant le stop (par défaut : 10s)

## Démarrer les conteneurs du Docker Compose
docker-compose start

## Arrêtez les conteneurs et supprimer les conteneurs, réseaux, volumes, et les images
docker-compose down
    -t ou --timeout : spécifier un timeout en seconde avant la suppression (par défaut : 10s)

## Supprimer des conteneurs stoppés du Docker Compose
docker-compose rm
    -f ou --force : forcer la suppression

## Lister les images utilisées dans le docker-compose.yml
docker-compose images


docker compose -f srcs/docker-compose.yml build --no-cache mariadb


docker compose -f srcs/docker-compose.yml down -v

docker compose -f srcs/docker-compose.yml up --build -d

Pour l’arrêter :    
docker-compose -f  srcs/docker-compose.yml  stop

Pour supprimer le build :    
docker-compose -f  srcs/docker-compose.yml  down -v

docker system prune -af 
SUPPRIME TOUT



mariadb testing: 
    docker exec -it mariadb mysql -u root -p
        SHOW DATABASES;
        SELECT User, Host FROM mysql.user;

        USE wordpress;
        SELECT comment_ID, comment_post_ID, comment_author, comment_content, comment_approved
        FROM wp_comments;

        UPDATE wp_comments SET comment_approved = 1;
        






















TEST WORDPRESS
docker exec -it wordpress bash
    ps aux | grep php-fpm

        You MUST see:

        php-fpm: master process
        php-fpm: pool www
        php-fpm: pool www

    netstat -tulpn | grep php
        Expected (port):
        tcp   LISTEN   0 0 127.0.0.1:9000   php-fpm


✅ 3. Check that Nginx can reach php-fpm

Inside the nginx container:

    docker exec -it nginx bash
        apt update && apt install -y curl
        curl http://wordpress:9000

        nc -vz wordpress 9000


If php-fpm responds, you get something like:

File not found.


docker exec -it wordpress ps aux

Also check port:

docker exec -it wordpress ss -tlnp


You should see something like:

LISTEN 0  128 0.0.0.0:9000  ...


2️⃣ Check Docker network

Make sure nginx can resolve wordpress:

docker exec -it nginx ping wordpress


Expected:

PING wordpress (172.x.x.x) ...


If it fails → network config issue.


3️⃣ Test connection from nginx to WordPress container
docker exec -it nginx bash
apt update && apt install -y curl
curl -v http://wordpress:9000


If you get connection refused → php-fpm is not listening on TCP

If you get some response → php-fpm works, problem is nginx config