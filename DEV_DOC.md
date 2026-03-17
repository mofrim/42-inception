# fmaurer's Inception DEV_DOC

## How to setup environment from scratch

1) On school computers (`wolfsburg` somewhere in hostname) copy a dotenv-file
   containing all the variables used in the compose-file and elsewhere in the
   project to `~/inception-dotenv`. This file must contain these variables:

        # path to the volumes.
        DATA_DIR=

        # variables for mariadb container
        MARIA_ROOT_PW=
        MARIA_DB=
        MARIA_USER=
        MARIA_USER_PW=

        # variables needed for configuring wp/php-fpm container
        DOMAIN_NAME=
        WP_SITE_TITLE=
        WP_DB_HOST=
        WP_DB_USER=
        WP_DB_PW=
        WP_DB_NAME=
        WP_ADMIN_USER=
        WP_ADMIN_PW=
        WP_ADMIN_MAIL=
        WP_USER2=
        WP_USER2_PW=
        WP_USER2_MAIL=
        # generated keys and saltes from https://api.wordpress.org/secret-key/1.1/salt/
        WP_CFG_AUTH_KEY=
        WP_CFG_SECURE_AUTH_KEY=
        WP_CFG_LOGGED_IN_KEY=
        WP_CFG_NONCE_KEY=
        WP_CFG_AUTH_SALT=
        WP_CFG_SECURE_AUTH_SALT=
        WP_CFG_LOGGED_IN_SALT=
        WP_CFG_NONCE_SALT=
        # redis pw
        REDIS_PW=

2) also create/copy a file `~/inception-vmpw` which contains a hashed password
  which will be used in the vm for both normal user and root. you can create
  one using the `mkpasswd` cli-tool.

3) For local, Not-in-VM development there are 2 ways to work on containers and
   the whole setup:

  1. If you have got super-user rights on your local machine you can edit
     `/etc/hosts`

     ``` conf
      127.0.0.1 fmaurer.42.fr
     ```

     This will make DNS resolve the adress `fmaurer.42.fr` to localhost. This is the
     canonical way of doing it. 

  2. If you cannot edit `/etc/hosts`. You will first have to run `make dotenv`
     which more or less simply copies in the secrets. The `.env` file is now
     located in `srcs/.env`. There you can set the `DOMAIN_NAME` variable to
     `localhost`. After that run `make dev` which will create all certs, and
     spin up the local docker compose services.
     
     If you already ran `make dev` once with wrong `DOMAIN_NAME` (i.e. not
     `localhost` for local dev without `/etc/hosts` being edited), you also have
     to regenerate secrets. Therefore run

     - `make fclean` to clean up everything
     - `make dotenv`
     - set DOMAIN_NAME in `srcs/.env` to localhost
     - `make dev`

4) Now you can edit dockerfiles etc. If you want to reload the whole compose
   session there is also `make dock-re`. For simply building images there is
   `make dock-build`. If you want to tear down your running services from
   another terminal run `make dock-down`. For simply launching services without
   building use `make dock-build`. To clean up all images and volumes run  `make
   dock-clean`. (Tip: you can find all make recipes by typing in `make d` on
   cmdline and then hit the TAB key)

In order to start from a fresh repo you can always run `make fclean`. `make re`
also is there but this will build and launch the VM.

## How to build and launch using Makefile and Docker Compose

To launch the overall setup / building process for local dev: `make dev`. For
the detailed docker stuff: look above. Of course you can also go into `srcs/`
folder **after you ran `make setup`** at least once before and run `docker
compose up --build`.

## Relevant commands to manage containers and volumes

See above for my `make`-integrated docker management tools. Here a list of
possible `docker` commands useful for all of this:

- To spin up services: `docker compose up` (add `--build` if you also want to
  build images)
- To run project as daemon run `docker compose up -d`
- `docker ps` shows status of currently running containers
- `docker volume ls` && `docker volume inspect <vol_name>`
- `docker exec -it <container_name> /bin/bash` to explore inside containers
- `docker compose down -v` inside `srcs` folder (or specify compose file via
  `-f` param)
- `docker images` to see which images you have on your system
- in the individual docker-image dirs in `srcs/requirements` and  `srcs/bonus`
  you can build the images using `docker build -t <your_image_name> .` and then run them
  using `docker run <your_image_name>`, but this might fail because some
  parameters might not be set properly!
- to remove containers use `docker rm <image_hash>`
- to remove volumes: `docker volume rm`
- to inspect / remove a docker-network: `docker network ls/inspect ...`

## Where is project data stored and how does it persist?

I chose to store project data in named docker volumes as the `subject.pdf`
forbid us to use bind-mounts. This means for local dev on school computers the
data will be stored in rootless docker daemons `data-root` dir, which you can
find via `docker info`. This is in my case `/goinfre/fmaurer/docker`. The
volumes, if they exist will be located in a subfolder `volumes` there.

Inside the VM i set the data root to "/home/fmaurer/data" in order to fulfill
the subject requirements

```nix
virtualisation.docker = {
  enable = true;
  daemon.settings = {
    data-root = "/home/fmaurer/data";
  };
};
```

