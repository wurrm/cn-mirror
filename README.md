# cn, the cnatural compiler
## v0.0.0-alpha

This repository contains the first (?) release of the cnatural compiler (`cn`).
This version does not currently support/does not currently guarantee support for macros,
constructs with scopes (except functions and classes) and certain function argument
syntax. Let us know how you find it!

cnatural and cn are based on Charles Fox's implementation by the same name,
available [here](https://gitlab.com/charles.fox/cnatural).

## cnatural

The cnatural language as implemented here is a lightweight twist on C++: all
expressions in cnatural are valid C++ expressions, and no additional syntax is
added. Instead, some features are replaced by information that will already be
present in most C++ code:
- A newline, rather than a semicolon, ends a statement
- Indentation level, rather than curly brackets, start and ends blocks
- Declarations not in function scope will act as if defined in a hpp file of
the same name as the current file

## cn

`cn` compiles cnatural code to equivalent C++. It is written in C and uses
flex & bison to generate the parser. `cn` is a 'lite' parser - most of the
stream passes straight into a cpp or hpp file without the syntax being
analysed, and in general cn only considers syntax at the start and end of
expressions. The exception to this is situations where a declaration would need
to be represented differently in the header and cpp file, or affects the
representation of later declarations.
