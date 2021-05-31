# This is not the best way to setup. To make it more secured, you should create a docker network and connect all containers to traefik only in that network.
# Having evrything in a docker-compose would be cleaner, but QNAP Container station couldn't manage docer-composed containers

# Start Traefik container
docker run -d --name reverse_proxy -p 48080:8080 -p 40080:80 -p 40443:443 -v $PWD/traefik.yaml:/etc/traefik/traefik.yaml -v $PWD/dynamic_config.yaml:/etc/traefik/dynamic_config.yaml traefik:latest

# Start MariaDB container for nextcloud
docker run -d --name mariadb-nc -p 43306:3306  -v <persistent-db-storage>:/var/lib/mysql -e MARIADB_ROOT_PASSWORD=mariarootpwd -e MARIADB_DATABASE=nextclouddb -e MARIADB_USER=ncadmin -e MARIADB_PASSWORD=ncadminpwd mariadb:latest
# Start Nextcloud container
docker run -d --name nextcloud -p 30080:80 -v <persistent-data-storage>:/var/www/html nextcloud:latest


# Start Ghost container
docker run -d --name ghost_blog -p 2368:2368 -v <persistent-storage>:/var/lib/ghost/content ghost:latest 
# This container update Cloudflare DDNS 
docker-compose -f cloud-ddns-compose.yaml up -d