#include "curly.h"

int _addBracketsAndSemicolons(FILE *fout, int indentCurr, int indentBlockDepth, int *indentPrev)
{
    // TODO Fail if nullptrs
    if (indentCurr != 0)
    {
        if (indentCurr % indentBlockDepth != 0)
        {
	    return 1;
        }

	indentCurr /= indentBlockDepth;
    }

    int indentDiff = indentCurr - *indentPrev;

    if (indentDiff > 0)
    {
        for (int i = 0; i < indentDiff; ++i)
        {
            fprintf(fout, "{");
        }
    }
    else
    {
	fprintf(fout, ";");
    }

    if (indentDiff < 0)
    {
        for (int i = 0; i < -indentDiff; ++i)
        {
            fprintf(fout, "};");
        }
    }

    *indentPrev = indentCurr;

    return 0;
}
