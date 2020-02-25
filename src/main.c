#include <stdio.h>

int parse();

int main(int argc, char **argv)
{
    if (argc == 1)
    {
        fprintf(stderr, "No files provided.\n");
    }

    for (int i = 1; i < argc; ++i)
    {
        if (parse(argv[i]))
        {
            fprintf(stderr, "Error writing to file %s\n", argv[i]);
        }
    }
}
