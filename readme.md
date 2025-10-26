# my inception docker journey 

## ressources

- [https://ssl-config.mozilla.org/](https://ssl-config.mozilla.org/) nice for
  generating default nginx cfg
- [https://www.ssllabs.com/ssltest/](https://www.ssllabs.com/ssltest/) maybe use
  this for testing ssl setup of my own sites.

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
