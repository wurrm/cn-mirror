cn: src/lex.yy.c src/cn.tab.c src/cn.tab.h
	gcc src/cn.tab.c src/lex.yy.c -lfl -o cn

src/cn.tab.c src/cn.tab.h: src/cn.y
	bison -d -o src/cn.tab.c src/cn.y

src/lex.yy.c: src/cn.l src/cn.tab.h
	flex -o src/lex.yy.c src/cn.l
