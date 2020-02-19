%{

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <limits.h> // For MAX_PATH
#include <stdbool.h>

#include <libgen.h>

#include "curly.h"

// Flex Definitions
extern int yylex();
extern int yyparse();
extern FILE *yyin;

//declared in cn.l
extern int yylineno;

void yyerror(const char *s);

// Required Globals
// TODO Surely there's a nicer of getting things to yyparse than making everything global? Check the docs.
FILE *fcpp;
FILE *fhpp;

int indentBlockDepth = 0;
int indentPrev = 0;
int indentFloor = 0;

// TODO Lots of arbritrary constant values, could do with tweaking.
char functionPrefixes[8][100];

char prevExpr[100];

// Function Definitions
void addBracketsAndSemicolons(FILE *fout, int indentCurr, int indentBlockDepth, int *indentPrev);
void handleClasses(char const *expr);
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
        NL                      {
                                    fprintf(fhpp, "\n");
                                    fprintf(fcpp, "\n");
                                }
        | codeline NL           {
                                    free($1);
                                    fprintf(fhpp, "\n");
                                    fprintf(fcpp, "\n");
                                }
;

codeline:
        MACRO                   {
                                    // TODO Implement syntax match logic for line_indent MACRO
                                    fprintf(fhpp, "%s", $1);
                                    $$ = $1;
                                }
        | EXPR                  {
                                    // TODO Put this into a function goddammit.
                                    if (indentPrev > 0)
                                    {
                                        addBracketsAndSemicolons(fcpp, indentFloor, indentBlockDepth, &indentPrev);
                                    }

                                    indentFloor = 0;

                                    addBracketsAndSemicolons(fhpp, 0, indentBlockDepth, &indentPrev);
                                    fprintf(fhpp, "%s", $1);

                                    // TODO strcpy is not necessarily safe.
                                    strcpy(prevExpr, $1);

                                    handleClasses($1);

                                    $$ = $1;
                                }
        | line_indent EXPR      {
                                    if (indentBlockDepth == 0)
                                    {
                                        indentBlockDepth = $1;
                                        indentFloor *= indentBlockDepth;
                                    }

                                    if ($1 > indentFloor)
                                    {
                                        if (indentPrev == indentFloor)
                                        {
                                            // If move above floor, write previous and new expr to cpp.

                                            // TODO This is a 10 second hack to implement MVP, really we need a subparser for declarations.
                                            char temp[100];
                                            char *ident = strstr(prevExpr, "(");
                                            do { --ident; } while (ident != prevExpr && *(ident-1) != ' ');
                                            int const diff = ident - prevExpr;
                                            strncpy(temp, prevExpr, diff);
                                            temp[diff] = '\0';
                                            strcat(temp, functionPrefixes[indentFloor / indentBlockDepth]);
                                            strcat(temp, ident);

                                            fprintf(fcpp, "%s\n", temp); // TODO already printed a NL, move back one or delete it for gdb hack.
                                        }
                                        addBracketsAndSemicolons(fcpp, $1, indentBlockDepth, &indentPrev);
                                        fprintf(fcpp, "%s", $2);
                                    }
                                    else
                                    {
                                        if (indentPrev > indentFloor)
                                        {
                                            // If move below floor, close remaining brackets in implementation.
                                            addBracketsAndSemicolons(fcpp, indentFloor, indentBlockDepth, &indentPrev);
                                        }

                                        indentFloor = $1;

                                        addBracketsAndSemicolons(fhpp, $1, indentBlockDepth, &indentPrev);
                                        fprintf(fhpp, "%s", $2);
                                    }

                                    // TODO strcpy is not necessarily safe.
                                    strcpy(prevExpr, $2);

                                    handleClasses($2);

                                    $$ = $2;
                                }

line_indent:
        START_INDENT            { $$ = 1; }
        | line_indent INDENT    { $$ = $1 + 1; }
;

%%

void handleClasses(char const *expr)
{
    if (strncmp(expr, "class ", 6) == 0)
    {
        indentFloor += (indentBlockDepth) ? indentBlockDepth : 1;

        // TODO Works, but would be much prettier in subparser.
        char const *temp = expr + 6; // Move ahead by strlen("class ")
        char const *p = temp;
        do { ++p; } while (*p != '\0' && *p != ' ');
        int x = indentFloor;
        if (indentBlockDepth) { x /= indentBlockDepth; }
        strncpy(functionPrefixes[x], temp, p - temp);
        functionPrefixes[x][p - temp + 1] = '\0';
        strcat(functionPrefixes[x], "::");
    }
}

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
    // TODO Do this properly.
    char *pch;
    pch = strstr(filepath, ".cn");
    strncpy(pch, ".cpp\0", 5);
    fcpp = fopen(filepath, "w+");
    pch = strstr(filepath, ".cpp");
    strncpy(pch, ".hpp\0", 5);
    fhpp = fopen(filepath, "w+");

    fprintf(fcpp, "#include \"%s\"", basename(filepath));

    do
    {
        yyparse();
    } while(!feof(yyin));
    // Close any open brackets.
    addBracketsAndSemicolons(fcpp, indentFloor, indentBlockDepth, &indentPrev);
    addBracketsAndSemicolons(fhpp, 0, indentBlockDepth, &indentPrev);

    fclose(fin);
    fclose(fhpp);
    fclose(fcpp);
}

void addBracketsAndSemicolons(FILE *fcpp, int indentCurr, int indentBlockDepth, int *indentPrev)
{
    int err = _addBracketsAndSemicolons(fcpp, indentCurr, indentBlockDepth, indentPrev);

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
