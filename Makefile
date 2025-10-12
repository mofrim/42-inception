# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    Makefile                                           :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: fmaurer <fmaurer42@posteo.de>              +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2025/08/11 20:50:49 by fmaurer           #+#    #+#              #
#    Updated: 2025/10/12 14:53:11 by fmaurer          ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

NAME = inception

# some colors for the log msgs
# GRN = \033[1;92m
GRN = \e[0;32m
RED = \e[1;31m
WHT = \e[1;37m
GRE = \e[37m
YLW = \e[1;93m
RST = \e[0m
MSGOPN = $(YLW)--(($(GRN)
MSGEND = $(YLW)))--$(RST)

# this is really a makefile function defn !!! not exactly necessary but fancy.
log_msg = @$(ECHO) "$(MSGOPN) $(1) $(MSGEND)"
colr_grey = @$(ECHO) "$(GRE)"
reset_colr =  @$(ECHO) "$(RST)"

# Control preproc consts in constants.h based on build host:
# TODO: choose this value depending on system, cause on school PCs `-e` does
# not have an effect.
ECHO = echo -e

DOCKER = docker

REQ_DIR	=	src/requirements
WP_DIR	=	$(REQ_DIR)/wordpress
MARIA_DIR	=	$(REQ_DIR)/mariadb
NGINX_DIR	=	$(REQ_DIR)/nginx

all: $(NAME)

# TODO: do not re-create keys and certs if they already exist. meaning check for
# relevant files AND if they are not empty -> create a script which does that.
# Also include copying the dotenv file into src dir. Of course, before doing
# this check if there is already a non-empty src/.env!
$(NAME): mksec
	$(call log_msg,Setup done! Now type \"make run\" or \"make test\" to start the show!)

dev:
	$(call log_msg,Okay calling docker compose up directly!)
	$(call log_msg,But first: checking if fmaurer.42.fr is reachable...)
ifeq ($(shell ping -c 1 fmaurer.42.fr &> /dev/null || echo "nope"), nope)
	$(call log_msg,Not doing it. fmaurer.42.fr needs to be pingable)
else
	$(call log_msg,Alrighty! Running docker compose up!)
	cd src && docker compose up --build
endif

mksec: mksec-ca mksec-maria-wp mksec-nginx

mksec-ca:
	$(call log_msg,Creating the CA cert...)
	$(colr_grey)
	cd secrets && ../tools/gen_ca_cert.sh
	$(reset)
	$(call log_msg,Done CA Cert!)

mksec-maria-wp:
	$(call log_msg,Creating SSL certs for mariadb...)
	$(make_it_grey)
	cd secrets && ../tools/gen_mariadb_wp_certs.sh
	mkdir -p $(WP_DIR)/mysql $(MARIA_DIR)/ssl
	mv secrets/client-*.pem $(WP_DIR)/mysql
	cp secrets/ca-cert.pem $(WP_DIR)/mysql
	cp secrets/ca-cert.pem $(MARIA_DIR)/ssl
	mv secrets/server-*.pem $(MARIA_DIR)/ssl
	$(reset)
	$(call log_msg,Done Creating SSL certs for mariadb!)

mksec-nginx:
	$(call log_msg,Creating SSL Certs for nginx...)
	cd secrets && ../tools/gen_nginx_cert.sh
	mkdir -p $(NGINX_DIR)/conf
	mv secrets/nginx-server-cert.pem $(NGINX_DIR)/conf/server-cert.pem
	mv secrets/nginx-server-key.pem $(NGINX_DIR)/conf/server-key.pem
	$(call log_msg,Done creating SSL Certs for nginx!)

get-dotenv:
	"$(call log_msg,Copying in .env from elsewhere...)
	cp ~/inception-dotenv src/.env

touch-flagfile:
	$(call log_msg,Wow! Finished Setup for first time. Creating flagfile.)
	touch .flagfile

nginx:
	$(DOCKER) build -t inception_nginx $(REQ_DIR)/nginx/

nginx-run: nginx
	$(DOCKER) run -p 80:80 -p 443:443 inception_nginx
	#$(DOCKER) exec -it inception /bin/bash 

wp:
	$(DOCKER) build -t inc_wp $(REQ_DIR)/wordpress/

db:
	$(DOCKER) build -t inc_db $(REQ_DIR)/mariadb

db-run:
	-$(DOCKER) rm -f $$($(DOCKER) ps -qa)
	$(DOCKER) build -t inc_db $(REQ_DIR)/mariadb && $(DOCKER) run --name inc_db -d -v /home/frido/c0de/42/theCore/16-inception/incept/wp_db:/var/lib/mysql inc_db:latest

play:
	$(DOCKER) build -t inc_play ./play/
	$(DOCKER) run -it inc_play # necessary to add `-it` for an interactive sesh

comp:
	# $(DOCKER) compose -f ./srcs/docker-compose.yml up -d --build
	$(DOCKER) compose -f ./src/docker-compose.yml up --build

comp-nobuild:
	$(DOCKER) compose -f ./src/docker-compose.yml up

comp-down:
	$(DOCKER) compose -f ./src/docker-compose.yml down -v

comp-re: clean comp

logs:
	$(call log_msg,nginx logs...)
	-$(DOCKER) exec -it inc_nginx cat '/var/log/nginx/error.log'
	-$(DOCKER) exec -it inc_nginx cat '/var/log/nginx/access.log'
	$(call log_msg,wp logs...)
	-$(DOCKER) exec -it inc_wp cat '/var/log/php84/error.log'
	$(call log_msg,wp_db logs...)
	-$(DOCKER) logs inc_wp_db
	sudo cat ./wp_db/$$( $(DOCKER) logs inc_wp_db | grep Logging | sed -e "s/^.*'\/var\/lib\/mysql\///g" -e "s/'.$$//g")

sec-clean:
	rm -f $(WP_DIR)/mysql/*.pem
	rm -f $(MARIA_DIR)/ssl/*.pem
	rm -f $(NGINX_DIR)/conf/*.pem

clean:
	sudo rm -rf wp_data wp_db && mkdir wp_data wp_db
	-$(DOCKER) rm -f $$($(DOCKER) ps -qa)
	-$(DOCKER) volume rm $$($(DOCKER) volume ls -q)
	rm .flagfile

.PHONY: $(NAME) all nginx nginx-run play db-run db mksec-maria-wp
