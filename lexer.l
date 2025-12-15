%{
#include "parser.tab.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>


int yylineno = 1;


#ifdef _WIN32
#ifndef strdup
#define strdup _strdup
#endif
#endif
%}


digit [0-9]
letter [a-zA-Z_]
id {letter}({letter}|{digit})*
strlit \"([^\\\"]|\\.)*\"
floatnum {digit}+\.({digit}+)


%%


"num" { return NUM; }
"float" { return FLOAT_T; }
"text" { return TEXT; }
"show" { return SHOW; }
"take" { return TAKE; }
"when" { return WHEN; }
"otherwise" { return OTHERWISE; }
"loop" { return LOOP; }
"begin" { return BEGIN_T; }
"end" { return END_T; }


"gt" { return GT; }
"lt" { return LT; }
"is" { return IS; }


"+" { return PLUS; }
"-" { return MINUS; }
"*" { return MULT; }
"/" { return DIV; }


";" { return SEMICOLON; }
"=" { return ASSIGN; }
"(" { return LPAREN; }
")" { return RPAREN; }


--.* { /* comment */ }
[ \t\r]+ { /* ignore whitespace */ }
\n { yylineno++; }


{floatnum} { yylval.fval = atof(yytext); return FLOAT_LITERAL; }
{digit}+ { yylval.fval = atof(yytext); return NUMBER; }


{id} { yylval.sval = strdup(yytext); return ID; }


{strlit} {
char *s = strdup(yytext);
s[strlen(s)-1] = '\0';
memmove(s, s+1, strlen(s));
yylval.sval = s;
return STRING_LITERAL;
}


. {
printf("Unknown character at line %d: %s\n", yylineno, yytext);
}


%%
int yywrap() { return 1; }