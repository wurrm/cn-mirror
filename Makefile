NAME := cn
CC := gcc
LEX := flex
YACC := bison
SRCDIR := src
BUILDDIR := build
TESTDIR := test
TARGET := bin/$(NAME)

SRCEXT := c
SOURCES := $(shell find $(SRCDIR) -type f -name "*.$(SRCEXT)")
OBJECTS := $(patsubst $(SRCDIR)/%,$(BUILDDIR)/%,$(SOURCES:.$(SRCEXT)=.o))
CFLAGS := -g -Wall
LIB := -lfl
YACCFLAGS := -v
LEXFLAGS := -v
INC := -I include

$(TARGET): $(OBJECTS) $(BUILDDIR)/y.tab.c $(BUILDDIR)/lex.yy.c
	$(CC) $^ -o $(TARGET) $(INC) $(LIB)

$(BUILDDIR)/lex.yy.c: $(SRCDIR)/$(NAME).l
	$(LEX) $(LEXFLAGS) -o $@ $<

$(BUILDDIR)/y.tab.c: $(SRCDIR)/$(NAME).y
	@mkdir -p $(BUILDDIR)
	$(YACC) $(YACCFLAGS) -o $@ -d $<

$(BUILDDIR)/%.o: $(SRCDIR)/%.$(SRCEXT)
	@mkdir -p $(@D)
	$(CC) $(CFLAGS) $(INC) -c -o $@ $<

.PHONY: clean tests run

run:
	$(TARGET)

clean:
	$(RM) -r $(BUILDDIR) $(TARGET)

tests:
	$(CC) $(CFLAGS) $(TESTDIR)/test.cpp $(INC) -o bin/cntest
