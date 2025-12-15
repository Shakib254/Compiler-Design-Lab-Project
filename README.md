flex lexer.l
bison -d parser.y
gcc lex.yy.c parser.tab.c -o a.exe

a.exe < IO.ks
a.exe < loop.ks
a.exe <math.ks
