# Having evrything in a docker-compose would be cleaner, but QNAP Container station couldn't manage docer-composed containers

#create traefik network
docker network create --subnet=10.10.10.0/24 traefik_net

# Start Traefik container
docker run -d --name reverse_proxy -p 48080:8080 -p 40080:80 -p 40443:443 -v /share/Public/Container-data/traefik:/etc/traefik -v /share/Public/Container-data/traefik/letsencrypt:/letsencrypt traefik:latest
docker network connect --ip 10.10.10.2 traefik_net reverse_proxy 
# Remember to config NAT forwarding on your router to forward 80 and 443 ports to this container.

# Start Ghost container
docker run -d --name ghost_blog --net traefik_net --ip 10.10.10.5 -v /share/Public/Container-data/ghost-blog:/var/lib/ghost/content ghost:latest 

# Start MariaDB container
docker run -d --name mariadb-nc --net traefik_net --ip 10.10.10.6  -v /share/Public/Container-data/nextcloud/mariadb:/var/lib/mysql -e MARIADB_ROOT_PASSWORD=mariarootpwd -e MARIADB_DATABASE=nextclouddb -e MARIADB_USER=ncadmin -e MARIADB_PASSWORD=ncadminpwd mariadb:latest

# Start Nextcloud container
docker run -d --name nextcloud --net traefik_net --ip 10.10.10.7 -v /share/Public/Container-data/nextcloud/html-data:/var/www/html nextcloud:latest
# in the first time access Nextcloud, input mariaDB information.

# This container update Cloudflare DDNS 
docker-compose -f cloud-ddns-compose.yaml up -d
docker run -d --name cloudflare-ddns -v /share/Public/Container-data/cloudflare-ddns/config.json:/config.json -e PUID=1000 -e PGID=1000 timothyjmiller/cloudflare-ddns:latest