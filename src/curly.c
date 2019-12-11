#include "curly.h"

void addBrackets(FILE *fout, int indentCurr, int *indentBlockDepth, int *indentPrev)
{
    // TODO Fail if nullptrs
    if (indentCurr != 0)
    {
        if (*indentBlockDepth == 0)
        {
            *indentBlockDepth = indentCurr;
        }

        if (indentCurr % *indentBlockDepth != 0)
        {
            // TODO Good error message.
            // Perhaps now is a good time to start counting lns too?
            yyerror("Bad indentation");
        }

        indentCurr /= *indentBlockDepth;
    }

    int indentDiff = indentCurr - *indentPrev;

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

    *indentPrev = indentCurr;
}
