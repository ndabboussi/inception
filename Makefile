MAKE = make

DEFAULT = \033[0m
DEF_COLOR = \033[0;90m
WHITE = \033[1;37m
GREEN = \033[0;92m
YELLOW = \033[0;93m
CYAN = \033[0;96m
UNDERLINE = \033[4m
BOLD = \033[1m

all:
	docker compose -f srcs/docker-compose.yml up --build

clean:
	docker compose -f srcs/docker-compose.yml down

fclean:
	docker compose -f srcs/docker-compose.yml down -v --rmi all

re: fclean all
