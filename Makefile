# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    Makefile                                           :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: fmaurer <fmaurer42@posteo.de>              +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2025/08/11 20:50:49 by fmaurer           #+#    #+#              #
#    Updated: 2025/10/08 16:41:42 by fmaurer          ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

NAME = inception

# some colors for the log msgs
GRN = \033[38;5;40m
RED = \033[1;31m
WHT = \033[1;37m
EOC = \033[1;0m
YLW = \033[38;5;3m
MSGOPN = $(YLW)[[$(GRN)
MSGEND = $(YLW)]]$(EOC)

# this is really a makefile function defn !!! not exactly necessary but fancy.
log_msg = $(MSGOPN) $(1) $(MSGEND)

# Control preproc consts in constants.h based on build host:
ECHO = echo -e

all: $(NAME)

$(NAME): create-mariadb-ssl create-ngingx-ssl get-dotenv
	@$(ECHO) "$(call log_msg,Setup done! Now type \"make run\" to start the show!)"

create-mariadb-ssl:
	@$(ECHO) "$(call log_msg,Creating SSL certs for mariadb...)"
	cd srcs/requirements/mariadb/ssl && ./gen_certs.sh

create-ngingx-ssl:
	@$(ECHO) "$(call log_msg,Creating SSL certs for nginx...)"
	cd srcs/requirements/nginx/conf && ../tools/create_selfsigned_cert.sh

get-dotenv:
	@$(ECHO) "$(call log_msg,Copying in .env from elsewhere...)"
	cp ~/inception-dotenv srcs/.env

touch-flagfile:
	@$(ECHO) "$(call log_msg,Wow! Finished Setup for first time. Creating flagfile.)"
	touch .flagfile

nginx:
	docker build -t inception_nginx ./srcs/requirements/nginx/

nginx-run: nginx
	docker run -p 80:80 -p 443:443 inception_nginx
	#docker exec -it inception /bin/bash 

wp:
	docker build -t inc_wp ./srcs/requirements/wordpress/

db:
	docker build -t inc_db ./srcs/requirements/mariadb

db-run:
	-docker rm -f $$(docker ps -qa)
	docker build -t inc_db ./srcs/requirements/mariadb && docker run --name inc_db -d -v /home/frido/c0de/42/theCore/16-inception/incept/wp_db:/var/lib/mysql inc_db:latest

play:
	docker build -t inc_play ./play/
	docker run -it inc_play # necessary to add `-it` for an interactive sesh

comp:
	# docker compose -f ./srcs/docker-compose.yml up -d --build
	docker compose -f ./srcs/docker-compose.yml up --build

comp-nobuild:
	docker compose -f ./srcs/docker-compose.yml up

comp-down:
	docker compose -f ./srcs/docker-compose.yml down -v

comp-re: clean comp

logs:
	@$(ECHO) "$(call log_msg,nginx logs...)"
	-docker exec -it inc_nginx cat '/var/log/nginx/error.log'
	-docker exec -it inc_nginx cat '/var/log/nginx/access.log'
	@$(ECHO) "$(call log_msg,wp logs...)"
	-docker exec -it inc_wp cat '/var/log/php84/error.log'
	@$(ECHO) "$(call log_msg,wp_db logs...)"
	-docker logs inc_wp_db
	sudo cat ./wp_db/$$(docker logs inc_wp_db | grep Logging | sed -e "s/^.*'\/var\/lib\/mysql\///g" -e "s/'.$$//g")

clean:
	sudo rm -rf wp_data wp_db && mkdir wp_data wp_db
	-docker rm -f $$(docker ps -qa)
	-docker volume rm $$(docker volume ls -q)
	rm .flagfile

.PHONY: $(NAME) all nginx nginx-run play db-run db touch-flagfile create-mariadb-ssl create-ngingx-ssl get-dotenv
