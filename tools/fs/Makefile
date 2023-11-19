SRC   = $(wildcard source/*.c)
DEPS  = $(wildcard source/*.h)
OBJ   = $(addsuffix .o,$(subst source/,bin/,$(basename ${SRC})))
FLAGS = -std=c99 -Wall -Wextra -Werror -pedantic -g
OUT   = ../bin/fs

compile: ./bin $(OBJ) $(SRC) $(DEPS)
	$(CC) $(OBJ) -o $(OUT)

./bin:
	mkdir -p bin

bin/%.o: source/%.c $(DEPS)
	$(CC) -c $< $(FLAGS) -o $@

