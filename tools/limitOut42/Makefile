NAME = limitOut42

CFLAGS = -Wall -Werror -Wextra

all: limitOut42.c
	cc $(CFLAGS) -o $(NAME) limitOut42.c

test0: all
	./limitOut 42< <(cat lines.txt)

.phony: all test0

