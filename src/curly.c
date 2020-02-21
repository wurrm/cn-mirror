#include "curly.h"

int _addBracketsAndSemicolons(FILE *fout, int indentCurr, int indentBlockDepth, int *indentPrev)
{
    int tempPrev = (indentBlockDepth) ? *indentPrev / indentBlockDepth : 0;
    int tempCurr = (indentBlockDepth) ? indentCurr / indentBlockDepth : 0;

    // TODO Fail if nullptrs
    if (indentCurr != 0)
    {
        if (indentCurr % indentBlockDepth != 0)
        {
	    return 1;
        }
    }

    int indentDiff = tempCurr - tempPrev;

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
