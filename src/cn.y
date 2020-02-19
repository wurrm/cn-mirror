%{

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <limits.h> // For MAX_PATH

#include "curly.h"

// Flex Definitions
extern int yylex();
extern int yyparse();
extern FILE *yyin;

//declared in cn.l
extern int yylineno;

void yyerror(const char *s);

// Required Globals
// TODO Surely there's a nicer of getting things to yyparse? Check the docs.
FILE *fout;

int indentBlockDepth = 0;
int indentPrev = 0;

// Function Definitions
void addBracketsAndSemicolons(FILE *fout, int indentCurr, int *indentBlockDepth, int *indentPrev);
int parse(char *finpath);

%}

%union {
    int ival;
    char *sval;
}

%token NL
%token START_INDENT
%token INDENT

%token <sval> MACRO
%token <sval> EXPR

%type <ival> line_indent
%type <sval> codeline

%start codefile

%%

codefile:
        | codefile line         { }
;

line:
        NL                      { fprintf(fout, "\n"); }
        | codeline NL           { fprintf(fout, "%s\n", $1); free($1); }
;

codeline:
        MACRO                   {
                                    $$ = $1;
                                }
        | EXPR                  {
                                    addBracketsAndSemicolons(fout, 0, &indentBlockDepth, &indentPrev);
                                    $$ = $1;
                                }
        | line_indent EXPR      {
                                    addBracketsAndSemicolons(fout, $1, &indentBlockDepth, &indentPrev);
                                    $$ = $2;
                                }

line_indent:
        START_INDENT            { $$ = 1; }
        | line_indent INDENT    { $$ = $1 + 1; }
;

%%

int parse(char filepath[MAX_PATH])
{

    FILE *fin = fopen(filepath, "r");
    if (!fin)
    {
        return 1;
    }
    yyin = fin;

    // We make some assumptions about filepath here.
    // It would be better to write a function that handles path conversion in more detail.
    char *pch;
    pch = strstr(filepath, ".cn");
    strncpy(pch, ".cpp\0", 5);
    fout = fopen(filepath, "w+");

    do
    {
        yyparse();
    } while(!feof(yyin));
    addBracketsAndSemicolons(fout, 0, &indentBlockDepth, &indentPrev); // Close any open brackets.

    fclose(fin);
    fclose(fout);
}

void addBracketsAndSemicolons(FILE *fout, int indentCurr, int *indentBlockDepth, int *indentPrev)
{
    int err = _addBracketsAndSemicolons(fout, indentCurr, indentBlockDepth, indentPrev);

    if (err == 1)
    {
        // TODO Perhaps now is a good time to start counting lns too?
        yyerror("Inconsistent indentation block width");
    }
}

void yyerror(const char *s) {
    fprintf(stderr, "(Line: %d) Parsing error: %s", yylineno, s);
    exit(1);
}
