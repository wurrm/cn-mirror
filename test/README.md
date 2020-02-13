# Tests

To test the current source:

```console
$ make -C ..
$ python tests.py
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
