# my inception docker journey 

## learnings

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

