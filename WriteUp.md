# A HowTo-Inception WriteUp

by fmaurer


## Overview

The goal of the Inception Project is to use container-technology to set up a
nginx server, serving a worpress website. Worpress is a PHP Application and as
such needs a PHP-backend to run. Also Wordpress stores all website data in a
database so we also need a database running somewhere. This makes 3 services:

- Webserver: Nginx
- PHP-Backend: PHP-fpm
- Database: MariaDB (a SQL Database)

In order to provide the 3 different services, we are supposed to write
individual *Dockerfiles* for baking them into each into a separate
*docker-container*. In order to launch, connect them via a virtual network,
managing persistent data-storage, observing there health-status these services
have to be orchestrated via a *docker-compose-file*. That's it. Ah! There are 2
little constraints given by the `subject.pdf` that urge us to build and launch
the whole thing in a *Virtual Machine*:

- The hostname of our website should be `https://LOGIN.42.fr`, where `LOGIN` is
  our own login. And it should really run like that when we open the URL in a
  browser. This is only possible by editing the `/etc/hosts` file under Linux
  which we can't on school-computers.

- The persistent-storage volumes should be stored in `/home/LOGIN/data` dir
  **without** the use of so-called *bind-mounts*. With bind-mounts allowed we
  could simply specify the dir a volume should be stored in, in our
  compose-file by using a bind-mount. But, as we can't do it like this, the only
  chance we got is editing the docker-daemon's config file. Which again, we can
  not do on school-computers.

I will now explain the technical details from the smallest unit, the
Dockerfiles, up to the compose-file, follwing this structure:

- Dockerfile
- .env-File
- Compose-File
- Makefile

## Dockerfiles

This is my Dockerfile for the Nginx image:

```Dockerfile
FROM alpine:3.22

RUN apk update && apk upgrade && apk add --no-cache nginx openssl curl bash \
			iproute2-ss;

# Create directories for SSL certificates
RUN mkdir -p /etc/nginx/ssl /var/www/html;

COPY conf/nginx.conf /etc/nginx/nginx.conf
COPY conf/server-cert.pem /etc/nginx/ssl/
COPY conf/server-key.pem /etc/nginx/ssl/

COPY ./index.html /var/www/html
COPY ./bla.css /var/www/html

RUN addgroup -g 1001 www && adduser nginx www \
			&& chown -R nginx:www /var/www/html;

# create entrypoint script
COPY nginx-entry.sh /nginx-entry.sh
RUN chmod 700 /nginx-entry.sh;
ENTRYPOINT ["/nginx-entry.sh"]

# no need to run it with `-g "daemon off;"` as we have `daemon on;` in our
# config ;)
CMD ["nginx"]
```

As you can see in the Dockerfile the following things are done:

- Choose a base image

- Update package info and install all packages we want to use in this container
  (also added `curl`, `ss` and `bash` here for testing and being able to connect
  to the container interactively via `docker exec -it <container-name>
  /bin/bash`)

- Copy over key, config files, whatever, from the current dir the Dockerfile
  lives in and set permissions

- Copy the *entrypoint-script* to the container, set proper permissions (should
  definitely only be executable and editable by root) and set it as the
  `ENTRYPOINT` to the docker image.

- Specify the final `CMD` that is being executed finally when the container is
  up and running. This has to be a program that runs in the **foreground**
  indefinitely. And, of course, this should always be the application / service
  a specific container provides.

### The meta-logic of a Dockerfile / The ENTRYPOINT

So, inside the `Dockerfile` we set things up for everything that persistently
goes into the container image. The `ENTRYPOINT` is the place where we do all
setup and configuration of the image **that might change every-time we start the
container image**. For example we might want to change some port values for
certain services. Or, like in the wordpress container, we need to have some more
complex logic for creating default users, databse and so on, which require
extensive shell-scripting. This all goes into the *entrypoint-script*. This is
my `nginx-entry.sh`:

```bash
#!/bin/bash
set -e

function entry_msg () {
  echo "[nginx-entry.sh] $1"
}

config_file="/etc/nginx/nginx.conf"

# the only thing we do here is sedding in the server_name AND server_port from
# env
if [[ -f $config_file ]]; then
	entry_msg "sedding in current server_name"
	sed -i "s/server_name .*;/server_name $DOMAIN_NAME;/" $config_file
	entry_msg "... and the current port"
	sed -i "s/listen [0-9]\+ ssl;/listen $NGINX_PORT ssl;/" $config_file
	sed -i "s/listen \[.*;/listen \[::\]:$NGINX_PORT ssl;/" $config_file
	entry_msg "... and the current php-fpm port"
	sed -i "s/fastcgi_pass wp.*;/fastcgi_pass wp:$PHPFPM_PORT;/" $config_file
fi

exec "$@"
```

This is the simplest of all of the services. It's only purpose is to insert from
external environment variables (more on this later) the current DOMAIN_NAME and
some port-numbers. The last line is pretty important

```bash
exec "$@"
```

This has to be in every entrypoint-script. As it makes the command given as
`CMD` in the `Dockerfile` being executed. If we omit this line, the `CMD` will
never be run.

## The .env-File

What is the best practice for configuring a docker-compose project? The answer
for most project used today is: *Setting common variables that have to be shared
among services and secrets in a `.env`-File and work with those variables in the
compose-file & the Dockefiles. My `.env` file **which has to be in the same dir
as the compose-file** e.g. has this content in it:

```env
NGINX_PORT=1111
MARIADB_PORT=3306
PHPFPM_PORT=9999

# variables for mariadb container
MARIA_ROOT_PW=bla
MARIA_DB=wp
MARIA_USER=wp_user
MARIA_USER_PW=blubblubllub

# variables needed for configuring wp/php-fpm container
DOMAIN_NAME=fmaurer.42.fr
WP_SITE_TITLE="fmaurer's inception wp"
WP_DB_HOST=db
WP_DB_USER=wp_user
WP_DB_PW=blablabla
WP_DB_NAME=wp
[...]
```

It is a best practice for all settings that might change somewhere in the future
or depending on the environment (different ports, hostnames may be needed) where
your services are deployed by whoever (usernames, passwords might change) to set
a variable in the `.env`.

**WARNING: But, this `.env` contains secrets and therefore must not be pushed or
committed to your repo at any time!!!** It is a common workflow to keep this
file seperate from the repo and push / copy it manually to its destination
before build / during deployment.

## The compose-file.

This is an excerpt from my compose-file:

```yaml
services:
  nginx:
    container_name: inc-nginx
    image: inc-nginx
    build: ./requirements/nginx
    restart: unless-stopped
    volumes:
      - wp_data:/var/www/html/wp
    environment:
      DOMAIN_NAME: ${DOMAIN_NAME}
      NGINX_PORT: ${NGINX_PORT}
      PHPFPM_PORT: ${PHPFPM_PORT}
    ports:
      - "$NGINX_PORT:$NGINX_PORT"
    healthcheck:
      test: curl -kf https://fmaurer.42.fr:$$NGINX_PORT
      interval: 15s
      timeout: 3s
      retries: 3
      start_period: 5s
    depends_on:
      wp:
        condition: service_healthy
    # MAGIC! setting a network alias fmaurer.42.fr -> nginx-container.
    # this makes WP-sitehealth happy finally
    networks:
      inception.net:
        aliases:
          - fmaurer.42.fr

[....]

networks:
  inception.net:
    name: inception.net
    driver: bridge


# named volumes (good) vs. ....
#
# only problem on school computers was, you first needed to find out that docker
# is running rootless with "Docker root dir: /home/fmaurer/goinfre/docker/" =>
# link subdir `volumes` of this to ~/data.

volumes:
  wp_data:
  wp_db:
  redis_data:

# ... bind mounts (bad), see also:
# https://github.com/MatchbookLab/local-persist on this matter.

# volumes:
#   wp_data:
#     name: inc-wp_data
#     driver: local
#     driver_opts:
#       type: none
#       o: bind
#       device: ${DATA_DIR}/wp_data
#   wp_db:
#     name: inc-wp_db
#     driver: local
#     driver_opts:
#       type: none
#       o: bind
#       device: ${DATA_DIR}/wp_db

```

As you can see the variables from `.env`-file are referred to in the individual
service-section using the `${VAR_NAME}` or `$VAR_NAME` or `$$VAR_NAME` syntax
depending on context. When we set them in a `environment`-block the variables
get forwarded to the container image and can be used in the entrypoint-script
for example (this is the main purpose i would say).

Also, i have a `healthcheck` section for every service. This is a command that
is run inside the container and if its exit status is `0` the container is
recognized as healthy. This is also a best practice in docker-DevOps.

In the `volumes`-section of the compose-file i have left the commented-out
version using bind-mounts. In my final project i opted for the solution by
changing the `data-root` setting of the docker-daemon in the VM to
`/home/LOGIN/data`. But, actually, using bind-mount is the cleaner and more
common approach.

Ah! The network. Yeah, docker-networking is actually pretty easy. Just define a
network like i did and add it to every service, et voilà, from each services
container the other containers are reachable by there sercvice name, e.g.
`nginx` in the nginx case.

## The Makefile

Basically only runs `docker compose up -d --build` :)

## Appendix / Docker cheatsheet:

- To spin up services: `docker compose up` (add `--build` if you also want to
  build images)
- To run project as daemon run `docker compose up -d`
- `docker ps` shows status of currently running containers
- `docker volume ls` && `docker volume inspect <vol_name>`
- `docker exec -it <container_name> /bin/bash` to explore inside containers
  (needs bash being installed inside container)
- `docker compose down -v` inside `srcs` folder (or specify compose file via
  `-f` param)
- `docker images` to see which images you have on your system
- in the individual docker-image dirs in `srcs/requirements` and  `srcs/bonus`
  you can build the images using `docker build -t <your_image_name> .` and then
  run them using `docker run <your_image_name>`, but this might fail because
  some parameters might not be set properly!
- to remove containers use `docker rm <image_hash>`
- to remove volumes: `docker volume rm`
- to inspect / remove a docker-network: `docker network ls/inspect ...`
- clean-up everything docker-related (good for a fresh start, had a recipe for
  this in my Makefile): `docker rm -f $(docker ps -qa); docker volume rm -f
  $(docker volume ls -q); docker network rm -f inception.net`

