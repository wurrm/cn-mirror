%{

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdbool.h>

#include <libgen.h>

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
FILE *fcpp;
FILE *fhpp;

int indentBlockDepth = 0;
int indentPrev = 0;
int indentFloor = 0;

char prevExpr[100];

// Function Definitions
void addBracketsAndSemicolons(FILE *fout, int indentCurr, int indentBlockDepth, int *indentPrev);
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

                                    if (strncmp($1, "class", 5) == 0)
                                    {
                                        // Temporarily increment by only 1 until we know indent depth.
                                        indentFloor += (indentBlockDepth) ? indentBlockDepth : 1;
                                    }

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
                                            // TODO If we need declaration to cpp, if in a class we need to add class name, and we need to remove default values etc.
                                            //      This will probably require a sub-parser for top level declarations.
                                            fprintf(fcpp, "%s\n", prevExpr); // TODO already printed a NL, move back one or delete it for gdb hack.
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

                                    if (strncmp($2, "class", 5) == 0)
                                    {
                                        // TODO Spaces!
                                        indentFloor += indentBlockDepth;
                                    }

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
