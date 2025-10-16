# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    Makefile                                           :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: fmaurer <fmaurer42@posteo.de>              +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2025/08/11 20:50:49 by fmaurer           #+#    #+#              #
#    Updated: 2025/10/16 09:04:33 by fmaurer          ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

# overall TODO: cleanup this mess!

NAME = inception

# some colors for the log msgs
# GRN = \e[1;92m
GRN = \e[0;32m
RED = \e[1;31m
WHT = \e[1;37m
GRE = \e[37m
YLW = \e[1;93m
RST = \e[0m
MSGOPN = $(YLW)--(($(GRN)
MSGEND = $(YLW)))--$(RST)

# lomsg makefile functions
log_msg_start = @$(ECHO) "\n$(MSGOPN) $(1) $(MSGEND)"
log_msg_mid = @$(ECHO) "$(MSGOPN) $(1) $(MSGEND)"
log_msg_end = @$(ECHO) "$(MSGOPN) $(1) $(MSGEND)\n"
log_msg_single = @$(ECHO) "\n$(MSGOPN) $(1) $(MSGEND)\n"

# output coloring
output_color_grey = @$(ECHON) "$(GRE)"
output_colr_reset =  @$(ECHON) "$(RST)"

# WoooOOooOOoOoow! Make. supports. setting. environment variables. for. all.
# subshells. woohoo.
export TOOLDIR = $(shell readlink -f ./tools)

# Control preproc consts in constants.h based on build host:
# TODO: choose this value depending on system, cause on school PCs `-e` does
# not have an effect.
ECHO = echo -e
ECHON = echo -en

# to be clear here.
DOCKER = docker

REQ_DIR	=	src/requirements
WP_DIR	=	$(REQ_DIR)/wordpress
MARIA_DIR	=	$(REQ_DIR)/mariadb
NGINX_DIR	=	$(REQ_DIR)/nginx

# files bringing the secrets from the outside.
INCEPTION_DOTENV = src/.env
INCEPTION_VMPW = vm/inception-vmpw

all: $(NAME)

$(NAME): setup
	$(call log_msg_single,Setup done! Now type \"make run\" or \"make dev\" to start the show!)

setup: .setup_done

# real-file target for ensuring make will only run once
.setup_done:
ifneq ($(INCEPTION_SHELL),ok)
	$(call log_msg_start,P-L-Z run 'source .inceptionenv' first!)
else
	$(call log_msg_start,Alrighty! Running for the first time. Doing setup...)
	@sleep 0.5
	$(output_color_grey)
	@$(MAKE) -s sec-setup
	@$(MAKE) -s dotenv-vmpw
	@touch .setup_done && chmod 100 .setup_done
endif

$(INCEPTION_DOTENV):
	$(call log_msg_start,Copying in .env from elsewhere...)
	$(output_color_grey)
	@tools/setup_dotenv_vmpw.sh
	$(output_colr_reset)
	$(call log_msg_end,Done!)

$(INCEPTION_VMPW): $(INCEPTION_DOTENV)

dotenv-vmpw: $(INCEPTION_DOTENV) $(INCEPTION_VMPW)

# INSIGHT: wow! this is really crappy! the ifeq (...) statement will be
# evaluated _anytime_ make is called with some other rule!
sec-setup:
ifeq ($(shell tools/check_sec.sh),ok)
	$(call log_msg_end,Secret setup already done. Skipping.)
else
	$(call log_msg_start,Setting up secrets...)
	$(output_color_grey)
	@$(MAKE) -s sec-ca
	@sleep 0.5
	@$(MAKE) -s sec-maria-wp
	@sleep 0.5
	@$(MAKE) -s sec-nginx
	@sleep 0.5
	$(output_colr_reset)
	$(call log_msg_end,Done setting up secrets.)
endif

sec-ca:
	$(call log_msg_start,Creating the CA cert...)
	$(output_color_grey)
	cd secrets && ../tools/gen_ca_cert.sh
	$(output_colr_reset)
	$(call log_msg_end,Done with CA Cert!)

sec-maria-wp:
	$(call log_msg_start,Creating SSL certs for mariadb...)
	$(output_color_grey)
	cd secrets && ../tools/gen_mariadb_wp_certs.sh
	mkdir -p $(WP_DIR)/mysql $(MARIA_DIR)/ssl
	mv secrets/client-*.pem $(WP_DIR)/mysql
	cp secrets/ca-cert.pem $(WP_DIR)/mysql
	cp secrets/ca-cert.pem $(MARIA_DIR)/ssl
	mv secrets/server-*.pem $(MARIA_DIR)/ssl
	$(call log_msg_end,Done Creating SSL certs for mariadb!)

sec-nginx:
	$(call log_msg_start,Creating SSL Certs for nginx...)
	$(output_color_grey)
	cd secrets && ../tools/gen_nginx_cert.sh
	mkdir -p $(NGINX_DIR)/conf
	mv secrets/nginx-server-cert.pem $(NGINX_DIR)/conf/server-cert.pem
	mv secrets/nginx-server-key.pem $(NGINX_DIR)/conf/server-key.pem
	$(call log_msg_end,Done creating SSL Certs for nginx!)

dev: setup
	$(call log_msg_start,Okay calling docker compose up directly!)
	$(call log_msg_mid,But first: checking if fmaurer.42.fr is reachable...)
ifeq ($(shell ping -c 1 fmaurer.42.fr &> /dev/null || echo "nope"), nope)
	$(call log_msg_end,Not doing it. fmaurer.42.fr needs to be pingable)
else
	$(call log_msg_mid,Alrighty! Running docker compose up!)
	cd src && docker compose up --build
endif

#### VM hot stuff ####

run: setup
ifneq ($(INCEPTION_SHELL),ok)
	$(call log_msg_start,P-L-Z run 'source .inceptionenv' first!)
else
	$(call log_msg_start,Now really going for it... Starting vm_setup!)
	cd vm && ./0_vm_install.sh
endif

#### Direct docker stuff ####

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
	$(call log_msg_start,nginx logs...)
	-$(DOCKER) exec -it inc_nginx cat '/var/log/nginx/error.log'
	-$(DOCKER) exec -it inc_nginx cat '/var/log/nginx/access.log'
	$(call log_msg_mid,wp logs...)
	-$(DOCKER) exec -it inc_wp cat '/var/log/php84/error.log'
	$(call log_msg_mid,wp_db logs...)
	-$(DOCKER) logs inc_wp_db
	sudo cat ./wp_db/$$( $(DOCKER) logs inc_wp_db | grep Logging | sed -e "s/^.*'\/var\/lib\/mysql\///g" -e "s/'.$$//g")

sec-clean:
	$(output_color_grey)
	rm -f $(WP_DIR)/mysql/*.pem
	rm -f $(MARIA_DIR)/ssl/*.pem
	rm -f $(NGINX_DIR)/conf/*.pem

clean:
	$(call log_msg_start,Cleaning runtime docker stuff...)
	$(output_color_grey)
	sudo rm -rf wp_data wp_db && mkdir wp_data wp_db
	-$(DOCKER) rm -f $$($(DOCKER) ps -qa)
	-$(DOCKER) volume rm $$($(DOCKER) volume ls -q)
	$(call log_msg_end,Done.)

fclean:
	$(call log_msg_start, Cleaning up hard...)
	@$(MAKE) -s clean
	@$(MAKE) -s sec-clean
	$(call log_msg_mid,Removing setup lockfile...)
	rm -f .setup_done
	$(call log_msg_mid,Even removing .env an vmpw files...)
	rm -f src/.env vm/inception-vmpw
	$(call log_msg_end, Cleaning up hard... is done!)

re: fclean all

.PHONY: $(NAME) all nginx nginx-run play db-run db sec sec-ca sec-maria-wp sec-nginx dotenv-vmpw dev sec-setup setup test
