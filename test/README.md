# Tests

## Structure

`test.py` will search through the `tests` directory for:
- .cn files, to be compiled
- `reference`, the reference output directory
- `cnc` and `pycn`, the output directories

All cn files in the root of the tests dir will be compiled and moved into the
relevant output dir. The files in the output dirs will then be tested against
the expected output of the compilation, provided in `reference`. It is assumed
that all cn files in the root of tests have an appropriate `reference` output.

## Running Tests

To test the current source:

```console
$ make -C ..
$ python test.py
```

Which should give output like the following:

```
                     cnc  pycn
File1.cn:            000  000
```

The meaning of the flags is as follows:
0. compiler errors
1. hpp comparison
2. cpp comparison

A 0 indicates success, any other value indicates failure.
If a file failed to compile, the corresponding errors will be appended to
output.

## Adding Tests

To add a new test, write a .cn implementation of a program, followed by what
the expected output of the program when the cnatural compiler is run on it
would be as a .cpp and .hpp implementation in `reference`.

- Each test should explore only one feature of syntax.
- The filename should detail exactly what testcase is being explored.
- You should only include features that are already tested, excluding the
specific syntax the testcase is for.

For example, before writing any tests for functions in a class, a test should
be made for global functions.
