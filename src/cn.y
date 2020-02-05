%{

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "curly.h"

// TODO This feels clumsy. How do others do this?
#define MAX_PATH 4096

// Flex Definitions
extern int yylex();
extern int yyparse();
extern FILE *yyin;

void yyerror(const char *s);

// Required Globals
// TODO Surely there's a nicer of getting things to yyparse? Check the docs.
FILE *fout;

int indentBlockDepth = 0;
int indentPrev = 0;

// Function Definitions
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

int main(int argc, char **argv)
{
    if (argc == 1)
    {
        fprintf(stderr, "No files provided.\n");
        exit(1);
    }

    for (int i = 1; i < argc; ++i)
    {
        if (parse(argv[i]))
        {
            fprintf(stderr, "Error writing to file %s\n", argv[i]);
        }
    }
}

void yyerror(const char *s) {
    fprintf(stderr, "Parse error: %s\n", s);
    exit(1);
}
