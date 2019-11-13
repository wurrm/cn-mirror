cn: src/lex.yy.c src/cn.tab.c src/cn.tab.h
	gcc src/cn.tab.c src/lex.yy.c -lfl -o cn

src/cn.tab.c src/cn.tab.h: src/cn.y
	bison -d src/cn.y

src/lex.yy.c: src/cn.l src/cn.tab.h
	flex src/cn.l
