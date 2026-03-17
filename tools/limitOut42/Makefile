NAME = limitOut42

CFLAGS = -Wall -Werror -Wextra

all: limitOut42.c
	cc $(CFLAGS) -o $(NAME) limitOut42.c

clean:
	rm -f limitOut42

fclean: clean

re: fclean all

test0: all
	bash -c './limitOut42 42< <(cat limitOut42.c)'

.phony: all test0 clean fclean

