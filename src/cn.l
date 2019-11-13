%{

#include <stdio.h>
#include <string.h>

#include "cn.tab.h"

%}

%%

^[\t]           { // For simplicity, only tabs are currently supported.
                    return START_INDENT;
                }
[\t]            {
                    return INDENT;
                }
\n              {
                    return NL;
                }
[A-Za-z#\/].+   { // This regex is a temporary simplification.
                    yylval.sval = strdup(yytext); // Will be free()d by bison.
                    return STATEMENT;
                }

%%
