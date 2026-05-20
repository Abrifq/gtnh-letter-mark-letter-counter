#!/usr/bin/env -S make -f
# Make it executable, just in case.

#Set basic options here
CC=gcc
CFLAGS=-Wall -Wextra -Werror -pedantic -pedantic-errors -D_POSIX_SOURCE -D_POSIX_C_SOURCE=200809L -g

#Put imported libraries' package names here. The makefile will call pkg-config accordingly.
#For example: gl
LIB_PKGS =
# Put imported libraries' LIBRARY FILE PATH here. (lib/libtest/bin/libtest.so)
LOCAL_LIBS =
# Put imported libraries' INCLUDE FOLDER here. (For example, put lib/ here and "libtest/include/libtest.h" in the code) 
LOCAL_LIB_INCLUDES =

# Currently supports one target.
# You can just give it a binary name to build an executable.
TARGET_NAME=letterCounter

# Or you can define it like `(name).so` or `(name).dll` to make it build with `-fPIC -shared` automatically.
# Here is an example:
# TARGET_NAME=libtest.so

##region Basic auto-setup
BIN_FOLDER=bin/
OBJ_FOLDER=obj/
SRC_FOLDER=src/
DEP_FOLDER=deps/
HEADERS_FOLDER=include/
BASEDIRS= $(BIN_FOLDER) $(SRC_FOLDER) $(DEP_FOLDER) $(HEADERS_FOLDER) $(OBJ_FOLDER)
.PRECIOUS: $(BASEDIRS)
LDLIBS += $(addprefix -l ,$(LOCAL_LIBS))
CFLAGS += $(addprefix -I ,$(HEADERS_FOLDER))

ifneq ($(strip $(LIB_PKGS)),) #if there is package libraries to import:
LDLIBS =`pkg-config --libs-only-l $(LIB_PKGS)` $(LOCAL_LIBS)
LDFLAGS =`pkg-config --libs-only-L --libs-only-other $(LIB_PKGS)`
CFLAGS +=`pkg-config --cflags $(LIB_PKGS)`
endif

all: $(BIN_FOLDER)$(TARGET_NAME)
##endregion

# There is two ways to add our source files:
# You can either define the files manually.

# Here is an example for the manual way. You MAY miss some files this way.
# However, by defining it this way, you can divide big files into many source files, and then import it with `#include "source.c"`.
# You do you.

# SRC_FILES = main.c subfolder/example.c\
# 	tests.c

# Or you can use `find` to find the files automatically.
SRC_FILES = $(patsubst ./%, %, $(shell cd $(SRC_FOLDER); find -name "*.c"))

##region rule definitions
SRC = $(addprefix $(SRC_FOLDER),$(SRC_FILES))
OBJ = $(addprefix $(OBJ_FOLDER),$(SRC_FILES:%.c=%.o))
DEPS =$(addprefix $(DEP_FOLDER),$(SRC_FILES:%.c=%.d))

BIN_SUBFOLDERS = $(dir $(addprefix $(BIN_FOLDER),$(TARGET_NAME)))
OBJ_SUBFOLDERS = $(dir $(OBJ))
DEP_SUBFOLDERS = $(dir $(DEPS))
SRC_SUBFOLDERS = $(dir $(SRC))

SUBFOLDERS = $(SRC_SUBFOLDERS) $(DEP_SUBFOLDERS) $(OBJ_SUBFOLDERS)
.PRECIOUS: $(SUBFOLDERS)

#Should use rule below and the extra flag defined here to make a shared object
$(BIN_FOLDER)%.so $(BIN_FOLDER)%.dll: private LDFLAGS += -shared
$(BIN_FOLDER)%.so $(BIN_FOLDER)%.dll: CFLAGS += -fPIC

$(BIN_FOLDER)%: $(OBJ) | $(BIN_SUBFOLDERS)
#Default `%: %.o` recipe.
#We have to use it here explicitly because target name doesn't have to match an object name.
	$(LINK.o) $^ $(LOADLIBES) $(LDLIBS) -o $@

.PHONY: clean
clean:
	-rm -r $(DEP_FOLDER)
	-rm -r $(OBJ_FOLDER) 
	-rm -r $(BIN_FOLDER)

$(OBJ_FOLDER)%.o : $(SRC_FOLDER)%.c | $(OBJ_SUBFOLDERS)
#Default '%.o: %.c' recipe.
	$(COMPILE.c) $(OUTPUT_OPTION) $<

.PHONY: %/
%/:
	@mkdir -p $@

$(DEP_FOLDER)%.d: $(SRC_FOLDER)%.c | $(DEP_SUBFOLDERS)
	gcc -MM -MF $@ $(CFLAGS) -c $< -MT $@ -MT $(patsubst $(SRC_FOLDER)%,$(OBJ_FOLDER)%,$(patsubst %.c,%.o,$<))

include $(DEPS)
##endregion