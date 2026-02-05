# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    Makefile                                           :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: fmaurer <fmaurer42@posteo.de>              +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2025/08/11 20:50:49 by fmaurer           #+#    #+#              #
#    Updated: 2026/02/05 15:51:56 by fmaurer          ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

NAME = inception

# some colors for the log msgs
GRN = \e[0;32m
RED = \e[1;31m
WHT = \e[1;37m
GRE = \e[37m
YLW = \e[1;93m
RST = \e[0m
MSGOPN = $(YLW)--(($(GRN)
MSGEND = $(YLW)))--$(RST)

# logmsg makefile functions
log_msg_start = @$(ECHO) "\n$(MSGOPN) $(1) $(MSGEND)"
log_msg_mid = @$(ECHO) "$(MSGOPN) $(1) $(MSGEND)"
log_msg_end = @$(ECHO) "$(MSGOPN) $(1) $(MSGEND)\n"
log_msg_single = @$(ECHO) "\n$(MSGOPN) $(1) $(MSGEND)\n"

# output coloring
output_color_grey = @$(ECHON) "$(GRE)"
output_colr_reset =  @$(ECHON) "$(RST)"

# WoooOOooOOoOoow! Make. supports. setting. environment variables. for. all.
# subshells. amazing.
# These Variables are needed for all the setup scripts to run
export INCEP_TOOLDIR = $(shell readlink -f ./tools)

# TODO: choose this value depending on system, cause on school PCs `-e` does
# not have an effect.
HOST = $(shell hostname)
ifeq ($(findstring wolfsburg,$(HOST)), wolfsburg)
	ECHO = echo
	ECHON = echo -n
else
	ECHO = echo -e
	ECHON = echo -en
endif

# to be clear here.
DOCKER = docker

SRCDIR = srcs

REQ_DIR	=	$(SRCDIR)/requirements
WP_DIR	=	$(REQ_DIR)/wordpress
MARIA_DIR	=	$(REQ_DIR)/mariadb
NGINX_DIR	=	$(REQ_DIR)/nginx

# files bringing the secrets from the outside.
INCEPTION_DOTENV = $(SRCDIR)/.env
INCEPTION_VMPW = vm/inception-vmpw

all: $(NAME)

$(NAME): .setup_done
	$(call log_msg_single,Setup done! Now type \"make run\" or \"make dev\" to start the show!)
	@+bash -c 'source .inceptionenv'

# real-file target for ensuring make will only run once
.setup_done:
	$(call log_msg_start,Alrighty! Running for the first time. Doing setup...)
	@sleep 0.5
	$(output_color_grey)
	@$(MAKE) -s sec-setup
	@$(MAKE) -s dotenv-vmpw
	@touch .setup_done && chmod 100 .setup_done

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

# create the root cert
sec-ca:
	$(call log_msg_start,Creating the CA cert...)
	$(output_color_grey)
	cd secrets && ../tools/gen_ca_cert.sh
	$(output_colr_reset)
	$(call log_msg_end,Done with CA Cert!)


# only generate the secrets for the db and wp communication
sec-maria-wp:
	$(call log_msg_start,Creating SSL certs for mariadb...)
	$(output_color_grey)
	cd secrets && ../tools/gen_mariadb_wp_certs.sh
	mkdir -p $(WP_DIR)/mysql $(MARIA_DIR)/ssl
	mv secrets/client-*.pem $(WP_DIR)/mysql
	# yeah, right. leave CA cert  & key in 'secrets' dir as we need them for the
	# vm system config
	cp secrets/ca-cert.pem $(WP_DIR)/mysql
	cp secrets/ca-cert.pem $(MARIA_DIR)/ssl
	mv secrets/server-*.pem $(MARIA_DIR)/ssl
	$(call log_msg_end,Done Creating SSL certs for mariadb!)

# only generate nginx secrets
sec-nginx:
	$(call log_msg_start,Creating SSL Certs for nginx...)
	$(output_color_grey)
	cd secrets && ../tools/gen_nginx_cert.sh
	mkdir -p $(NGINX_DIR)/conf
	mv secrets/nginx-server-cert.pem $(NGINX_DIR)/conf/server-cert.pem
	mv secrets/nginx-server-key.pem $(NGINX_DIR)/conf/server-key.pem
	$(call log_msg_end,Done creating SSL Certs for nginx!)

# this recipe only works on machines where fmaurer.42.fr was redirected to
# localhost in /etc/hosts.
dev: .setup_done
	$(call log_msg_start,Okay calling docker compose up directly!)
	$(call log_msg_mid,But first: checking if fmaurer.42.fr is reachable...)
ifeq ($(shell ping -c 1 fmaurer.42.fr &> /dev/null || echo "nope"), nope)
	$(call log_msg_end,Not doing it. fmaurer.42.fr needs to be pingable)
else
	$(call log_msg_mid,Alrighty! Running docker compose up!)
	cd $(SRCDIR) && docker compose up --build
endif

#### VM hot stuff ####

run: .setup_done
ifneq ($(INCEPTION_SHELL),ok)
	$(call log_msg_start,P-L-Z run 'source .inceptionenv' first!)
else
	$(call log_msg_start,Now really going for it... Starting vm_setup!)
	@cd vm && ./0_vm_install.sh
	$(call log_msg_mid,Launching the VM...)
	@cd vm && ./2_launch_vm.sh
	$(call log_msg_end,I hope you enjoyed Inception!)
endif

quick-run: .setup_done
ifneq ($(INCEPTION_SHELL),ok)
	$(call log_msg_start,P-L-Z run 'source .inceptionenv' first!)
else
	$(call log_msg_start,Now really going for it... Starting vm_setup!)
	@+cd vm && ./42_quick_run.sh
	$(call log_msg_mid,Launching the VM...)
	@+cd vm && ./2_launch_vm.sh
	$(call log_msg_end,I hope you enjoyed Inception!)
endif

#### Direct docker stuff ####

comp:
	$(DOCKER) compose -f ./$(SRCDIR)/docker-compose.yml up --build

comp-down:
	$(DOCKER) compose -f ./$(SRCDIR)/docker-compose.yml down -v

comp-re: clean comp

# FIXME: DEPRECATE or adopt this!
logs:
	$(call log_msg_start,nginx logs...)
	-$(DOCKER) exec -it inc_nginx cat '/var/log/nginx/error.log'
	-$(DOCKER) exec -it inc_nginx cat '/var/log/nginx/access.log'
	$(call log_msg_mid,wp logs...)
	-$(DOCKER) exec -it inc_wp cat '/var/log/php84/error.log'
	$(call log_msg_mid,wp_db logs...)
	-$(DOCKER) logs inc_wp_db
	sudo cat ./wp_db/$$( $(DOCKER) logs inc_wp_db | grep Logging | sed -e "s/^.*'\/var\/lib\/mysql\///g" -e "s/'.$$//g")

#### cleanup recipes ####

vm-clean:
	$(call log_msg_start,Cleaning up vm-files for a fresh start...)
	rm -rf vm/inception/{*,.*}
	rm -f vm/nixos.qcow2
	rm -f vm/vm-conf.nix
	$(call log_msg_end,Done.)

sec-clean:
	$(call log_msg_start,Cleaning up keys and certs...)
	$(output_color_grey)
	rm -f $(WP_DIR)/mysql/*.pem
	rm -f $(MARIA_DIR)/ssl/*.pem
	rm -f $(NGINX_DIR)/conf/*.pem
	rm -rf secrets/*

clean:
	$(call log_msg_start,Cleaning runtime docker stuff...)
	$(output_color_grey)
	sudo rm -rf wp_data wp_db && mkdir wp_data wp_db
	-$(DOCKER) rm -f $$($(DOCKER) ps -qa)
	-$(DOCKER) volume rm $$($(DOCKER) volume ls -q)
	$(call log_msg_end,Done.)

fclean:
	$(call log_msg_start, Cleaning up hard...)
	@$(MAKE) -s vm-clean
	@$(MAKE) -s clean
	@$(MAKE) -s sec-clean
	$(call log_msg_mid,Removing setup lockfile...)
	rm -f .setup_done
	$(call log_msg_mid,Even removing .env an vmpw files...)
	rm -f $(SRCDIR)/.env vm/inception-vmpw
	$(call log_msg_end, Cleaning up hard... is done!)

re: fclean all

.PHONY: all $(NAME) dotenv-vmpw sec-setup sec-ca sec-maria-wp sec-nginx dev \
	run comp comp-down comp-re logs vm-clean sec-clean clean fclean re quick-run
