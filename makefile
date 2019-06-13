CC		:=	gcc -m32
CC_FLAGS	:=	-Wall -g
ASM		:=	nasm
ASM_FLAGS	:=	-f elf -g
LINK		:=	ld

SRC_DIR		:=	src
OBJ_DIR		:=	obj
LIST_DIR	:=	list
BIN_DIR		:=	bin

all: ass3

ass3:	$(OBJ_DIR)/ass3.o $(OBJ_DIR)/scheduler.o $(OBJ_DIR)/printer.o $(OBJ_DIR)/drone.o $(OBJ_DIR)/target.o
	$(CC) -o $(BIN_DIR)/ass3.bin $(OBJ_DIR)/ass3.o $(OBJ_DIR)/scheduler.o $(OBJ_DIR)/printer.o $(OBJ_DIR)/drone.o $(OBJ_DIR)/target.o

# .c/.s compile rules
$(OBJ_DIR)/%.o : $(SRC_DIR)/%.c
	$(CC) -c $(CC_FLAGS) $< -o $@

$(OBJ_DIR)/%.o : $(SRC_DIR)/%.s
	$(ASM) $(ASM_FLAGS) $< -o $@ -l $(subst .o,.lst,$(subst $(OBJ_DIR),$(LIST_DIR),$@))

clean:
	rm $(BIN_DIR)/*.bin $(OBJ_DIR)/*.o $(LIST_DIR)/*.lst
