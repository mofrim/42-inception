# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    Makefile                                           :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: fmaurer <fmaurer42@posteo.de>              +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2025/08/11 20:50:49 by fmaurer           #+#    #+#              #
#    Updated: 2026/03/17 09:34:04 by fmaurer          ###   ########.fr        #
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

SEC_DIR = secrets
REQ_DIR	=	$(SRCDIR)/requirements
WP_DIR	=	$(REQ_DIR)/wordpress
MARIA_DIR	=	$(REQ_DIR)/mariadb
NGINX_DIR	=	$(REQ_DIR)/nginx

# files bringing the secrets from the outside.
INCEPTION_DOTENV = $(SRCDIR)/.env
INCEPTION_VMPW = vm/inception-vmpw

all: $(NAME)

$(NAME): .setup_done run

# real-file target for ensuring make will only run once
.setup_done:
	$(call log_msg_start,Alrighty! Running for the first time. Doing setup...)
	@sleep 0.5
	$(output_color_grey)
	@$(MAKE) -s dotenv-vmpw
	@$(MAKE) -s sec-setup
	@$(MAKE) -s limitOut42
	@touch .setup_done && chmod 100 .setup_done

$(INCEPTION_DOTENV):
	$(call log_msg_start,Copying in .env from elsewhere...)
	$(output_color_grey)
	@tools/setup_dotenv_vmpw.sh
	$(output_colr_reset)
	$(call log_msg_end,Done!)

$(INCEPTION_VMPW): $(INCEPTION_DOTENV)

dotenv-vmpw: $(INCEPTION_VMPW)

$(SEC_DIR):
	$(output_color_grey)
	mkdir -p $(SEC_DIR)
	$(output_colr_reset)

# INSIGHT: wow! this is really crappy! the ifeq (...) statement will be
# evaluated _anytime_ make is called with some other rule!
sec-setup: $(SEC_DIR)
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

limitOut42:
	$(call log_msg_start,Building limitOut42...)
	$(output_color_grey)
	@$(MAKE) -C tools/limitOut42
	$(call log_msg_end,Done!)

limitOut42-clean:
	$(call log_msg_start,Cleaning limitOut42...)
	$(output_color_grey)
	@$(MAKE) -C tools/limitOut42 fclean
	$(call log_msg_end,Done!)

#### VM hot stuff ####

run: .setup_done
	$(call log_msg_start,Now really going for it... Starting vm_setup!)
	@+cd vm && ./0_vm_install.sh
	$(call log_msg_mid,Launching the VM...)
	@+cd vm && ./2_launch_vm.sh
	$(call log_msg_end,I hope you enjoyed Inception!)

run-vm: .setup_done
	$(call log_msg_mid,Launching the VM...)
	@+cd vm && ./2_launch_vm.sh
	$(call log_msg_end,I hope you enjoyed Inception!)

#### Direct docker stuff ####

dev: .setup_done
	$(call log_msg_start,Okay calling docker compose up directly!)
	@$(MAKE) -s dock-build

dock: .setup_done
	cd $(SRCDIR) && $(DOCKER) compose -p "inc" up

dock-build: .setup_done
	cd $(SRCDIR) && $(DOCKER) compose -p "inc" up --build

dock-down:
	cd $(SRCDIR) && $(DOCKER) compose -p "inc" down -v

dock-re: dock-clean dock-build

dock-clean:
	$(call log_msg_start,Cleaning runtime docker stuff...)
	$(output_color_grey)
	-$(DOCKER) rm -f $$($(DOCKER) ps -qa)
	-$(DOCKER) volume rm -f $$($(DOCKER) volume ls -q)
	-$(DOCKER) network rm -f inception.net
	$(call log_msg_end,Done.)

#### cleanup recipes ####

vm-clean:
	$(call log_msg_start,Cleaning up vm-files for a fresh start...)
	rm -rf vm/inception
	rm -f vm/nixos.qcow2
	rm -f vm/vm-conf.nix
	$(call log_msg_end,Done.)

sec-clean:
	$(call log_msg_start,Cleaning up keys and certs...)
	$(output_color_grey)
	rm -f $(WP_DIR)/mysql/*.pem
	rm -f $(MARIA_DIR)/ssl/*.pem
	rm -f $(NGINX_DIR)/conf/*.pem
	rm -rf secrets
	$(call log_msg_end,Done!)

# wipe everything
fclean:
	$(call log_msg_start, Cleaning up hard...)
	@$(MAKE) vm-clean
	@$(MAKE) dock-clean
	@$(MAKE) sec-clean
	@$(MAKE) limitOut42-clean
	$(call log_msg_mid,Removing setup lockfile...)
	$(output_color_grey)
	rm -f .setup_done
	$(call log_msg_mid,Even removing .env an vmpw files...)
	$(output_color_grey)
	rm -f $(SRCDIR)/.env vm/inception-vmpw
	@echo
	$(call log_msg_end, Cleaning up hard... is done!)

re: fclean all

.PHONY: all $(NAME) re fclean dev run dotenv-vmpw sec-setup sec-ca \
	sec-maria-wp sec-nginx dock dock-down dock-re dock-clean dock-build logs \
	vm-clean sec-clean run-vm limitOut42 limitOut42-clean
