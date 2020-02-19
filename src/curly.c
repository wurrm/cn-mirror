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

    // just an idea
    // use strstr. for example const char class = 'class', and char / const char 'input'. pch = strstr(input, class)   
    // if (pch) {}	prints no ;
    
    // if that does not work, I found a link where someone created a semicolon compiler. it dictates that 


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
