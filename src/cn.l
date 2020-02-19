%{
// C++ BNF: https://www.nongnu.org/hcb/
// C++11 (and more) maintained grammars: http://slebok.github.io/zoo/index.html#cpp_cpp11

#include <stdio.h>
#include <string.h>

#include "y.tab.h"

// #define USER_INPUT_ACTION yylloc.first_line = yylloc.last_line = yylineno;
// ^^ if you wanted to implement first_line, first_column, last_line, last_column. uses YYLTYPE

%}

%option yylineno

%%

^[ \t]          { // For simplicity, only tabs are currently supported.
                    return START_INDENT;
                }
[ \t]           {
                    return INDENT;
                }
\n              { 
		    return NL;
                }
#.+             {
                    yylval.sval = strdup(yytext); // Will be free()d by bison.
                    return MACRO;
                }
[A-Za-z\/].+    { // This regex is a temporary simplification.
                    yylval.sval = strdup(yytext); // Will be free()d by bison.
                    return EXPR;
                }

%%
