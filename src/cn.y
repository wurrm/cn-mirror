%{

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define MAX_PATH 4096

// Flex Definitions
extern int yylex();
extern int yyparse();
extern FILE *yyin;

void yyerror(const char *s);

// Required Globals
FILE *fout;

int indentBlockDepth = 0; // How many indents are in a block for this file.
int indentPrev = 0;

// Function Definitions
void addBrackets();
int parse(char *finpath);

%}

%union {
    int ival;
    char *sval;
}

%token NL
%token START_INDENT
%token INDENT
%token <sval> STATEMENT

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
        STATEMENT               { addBrackets(0); $$ = $1; }
        | line_indent STATEMENT { addBrackets($1); $$ = $2; }

line_indent:
        START_INDENT            { $$ = 1; }
        | line_indent INDENT    { $$ = $1 + 1; }
;

%%

void addBrackets(int indentCurr)
{
    if (indentCurr != 0)
    {
        if (indentBlockDepth == 0)
        {
            indentBlockDepth = indentCurr;
        }

        if (indentCurr % indentBlockDepth != 0)
        {
            // TODO Good error message.
            // Perhaps now is a good time to start counting lns too?
            yyerror("Bad indentation");
        }

        indentCurr /= indentBlockDepth;
    }

    int indentDiff = indentCurr - indentPrev;

    if (indentDiff > 0)
    {
        for (int i = 0; i < indentDiff; ++i)
        {
            fprintf(fout, "{");
        }
    }
    else if (indentDiff < 0)
    {
        for (int i = 0; i < -indentDiff; ++i)
        {
            fprintf(fout, "};");
        }
    }

    indentPrev = indentCurr;
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
    char *pch;
    pch = strstr(filepath, ".cn");
    strncpy(pch, ".cpp\0", 5);
    fout = fopen(filepath, "w+");

    do
    {
        yyparse();
    } while(!feof(yyin));
    addBrackets(0); // Close any open brackets.

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
