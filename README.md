*This project has been created as part of the 42 curriculum by fmaurer*

# Inception

## Description

In this project the goal was to run a complete Stack serving a Wordpress page
via a Nginx webserver using a docker-compose setup.

The whole project should run in a VM as the domain of the Webpage should be set
to `fmaurer.42.fr` which does not really exists. Therefore it was necessary to
edit the `/etc/hosts` file in order to redirect DNS request to `fmaurer.42.fr`
to `127.0.0.1`.

As i am an enthusiastic NixOS user i chose to also make the VM setup completely
declaratively. In order to be able to build the final VM-NixOS image i created a
minimal NixOS installer image which is first run as a VM to install the real
Inception-VM. Finally the Inception-VM is booted and the project is being build
& run.

### VM vs. Docker

Docker is a more lightweight approach then a VM as it does not boot a complete
virtual System with using a seperate kernel. Instead it uses the host kernel and
accesses devices through this. Like that a docker image is less
resource-intensive than a VM and takes less space on disk. Also it is great that
you configure a docker image declaratively in a Dockerfile. For non-NixOS VMs
this is not so easily possible.

### Secrets vs ENV Vars

The way i chose to handle secrets is by keeping them completely seperate in a
`.env` file in `srcs/` which i do not commit to git. This file will have to be
transferred separately before building the docker images. This is a very common
and simple approach. In this file all secrets are specified as environment
variables which can be used during runtime inside the container.
Another more advanced and sophisticated approach exists via the subcommand
`docker secret`. E.g. by running `echo "bla" | docker secret create
my_secret_data -` one can store the secret phrase "bla" in a named
docker-secret. Then in a compose file one can access this secret by declaring
```Dockerfile
services:
  myapp:
    secrets:
      - my_secret_data
```

which will make the secret available in the running container under
`/run/secrets/my_secret_data`. From command line a secret can be added to a
container using the `--secret` param. BUT, this is all only available in Docker
Swarm environments!

### Docker Network vs. Host Network

Per default docker creates a virtual network for its containers. This is called
a *bridge* network. Containers on the same bridged-network can communicate with
each other. All containers also get connected to the host-network via NAT. This
is the same as in home networks that connect to the internet over router. All
computers on a home network are "hidden" behind the router and there ports are
not exposed per default.
It is also possible to make containers use the host network. Then all services
running inside a container will seem as if they were running directly on the
host also exposing all there ports immediately. This is a less secure variant of
docker networking and normally not necessary.

### Docker Volumes vs. Bind Mounts

Docker Volumes are the standard way of managing persistent storage in docker.
They are normally stored in a default location (`/var/lib/docker/volumes`) and
can be listed using the cmd `docker volume ls`. Using CLI they can be created &
used by

```sh
# Create a volume
docker volume create my_volume

# Use it in a container
docker run -d -v my_volume:/app/data myapp
```

For a volume example in a compose-file see [my
compose-file](srcs/docker-compose.yml). These volumes can be used across
containers and file-systems, and data is still isolated from the host fs.

Bind mounts are essentially mounting a directory from the host machine to a
container. This can be done by 

```sh
docker run -d -v $(pwd):/app/data myapp
```

This especially useful for development where you want to mount the dir
containing the source code to a dev container f.ex. Also, it allows to control
where the data is stored. IMHO, this is the only solution for mounting the
storage volumes demanded in this exercise to the custom dir `/home/<login>/data`
?!?!!?

Inside my compose file i have:

```docker
volumes:
  wp_data:
    name: inc-wp_data

    # could also be nfs, cloudstor...
    driver: local
    driver_opts:

      # nfs, ext4...
      type: none

      # noatime, uid=... etc.
      o: bind
      
      # path on device
      device: ${DATA_DIR}/wp_data
```

As i understand it this is a **named volume** which uses a bind mount under the
hood.

I think what the subject did not want is specifying this on the command line.


## Instructions

- Running `make` will generate all secrets using host openssl tools & drop you
  into inception shell

- Then running `make run` will
  
  1) Launch the installer iso vm, copy over the inception-vm nix config,
     partition the qcow-image and install the system to the qcow
  2) Pause and ask to start the inception-vm, and if you like, do so.

- The VM directly boots to a XServer, where a Terminal is being opened and
  `docker compose up --build` is being run in the `srcs/` folder where the main
  services-related project files reside.

- There is also `make dev` to build and run the docker images on the host
  machine. Name resolution will not work unless you are allowed to edit
  `/etc/hosts`. I used this recipe (and all the others in the Makefile) for
  local development on my own machine.



## Resources


- [https://ssl-config.mozilla.org/](https://ssl-config.mozilla.org/) nice for
  generating default nginx cfg
- [https://www.ssllabs.com/ssltest/](https://www.ssllabs.com/ssltest/) maybe use
- [https://docs.docker.com/reference/](https://docs.docker.com/reference/)
  this for testing ssl setup of my own sites.
- [https://search.nixos.org/options](https://search.nixos.org/options)
- [nixos.org](https://nixos.org/)
- [redis documentation](https://redis-doc-test.readthedocs.io/en/latest/topics/quickstart/#installing-redis)
- and many more

## Learnings

- always use `apk add --no-cache` in Dockerfiles with alpine image base. makes
  the image smaller because downloaded install pkgs are not included. which of
  course is fine.

- `ENTRYPOINT [ "/bin/bash", "-i" ]` would be the code that is run when the
  image is called via `docker run -it image_name`. `-it` is necessary here
  because a interactive terminal needs to be allocated for bash to run
  interactively

- when installing php-fpm in the container there was a `www.conf` file in the
  `/etc/php-fpm..` folder. this file caused my site not being served and i had
  quite a bit of a time debugging this.

### the ssl issue

_the solution, for zarquon's sake!_

all the certificate generation info on the web **and** in all AIs is
**outdated**!!! there once was a time where setting a `CommonName` to the
servers domain would be enough, but this is different today.

at least one ressource mentioning the correct way of generating certs:

[ssl correct](https://itsfoss.gitlab.io/post/how-to-generate-self-signed-ssl-certificates-using-openssl/)

- handy command for printing cert metadata in plaintext: `openssl x509 -in
  your_certificate_file.pem -text -noout`

- how to test ssl is working with curl: `curl -vI https://fmaurer.42.fr`. to
  turn of certificate verification add `-k`. than it works

- verify ssl with openssl direct: `openssl s_client -connect fmaurer.42.fr:443
  -servername fmaurer.42.fr`
