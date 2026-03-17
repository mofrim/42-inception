# fmaurer's Inception USER_DOC

## Services provided

- Nginx
- MariaDB
- Redis Server
- Php-fpm 8.3 serving Wordpress 6.9.4

## How to start / stop the project

To run and build the full VM just run `make`. When the VM is finally ready you
can type `ciao` in the terminal or select `ciao` from the menu you get with a
right-click on the Desktop. Afterwards in the shell you started the project from
type `exit` or hit `Ctrl-D`.

## How to access webpage and admin-panel

After running `make` inside the VM the webpage will open automatically in
Firefox browser when everything is finally build and running. The admin-panel
you can either select via the bookmark in the bookmark toolbar there, or enter
`https://fmaurer.42.fr/wp-admin` in the URL-bar.

## How to locate and manage credentials

You have to provide a file `~/inception-dotenv` containing these variables set:

        # path to the volumes. (obsolete)
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

Also create a file `~/inception-vmpw` with a hashed password for the VM. You can
create one `mkpasswd`.

All other secrets (mostly SSL certs) are generated during build.

## How to check that services are running correctly

In VM or local dev: `docker ps`. There all services should be marked as
`(healthy)`. Another test would be to open the webpage (either
`https://localhost` in local-dev or `https://fmaurer.42.fr`) and try some things
out (create post, comment, etc).

