%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

void yyerror(const char *s);
int yylex(void);

typedef enum { INT_VAR, FLOAT_VAR, TEXT_VAR } VarType;

struct Var {
    char name[100];
    VarType type;
    double fval;
    char sval[500];
};

struct Var vars[200];
int var_count = 0;

// Find variable index
int find_var(const char *s) {
    for (int i = 0; i < var_count; i++)
        if (strcmp(vars[i].name, s) == 0) return i;
    return -1;
}

// Set variable
void set_var(const char *name, VarType t, double fv, const char *sv) {
    int idx = find_var(name);
    if (idx == -1) {
        idx = var_count++;
        strcpy(vars[idx].name, name);
    }
    vars[idx].type = t;
    vars[idx].fval = fv;
    if (sv) strcpy(vars[idx].sval, sv);
}

// Evaluate condition
int eval_condition(int cond) { return cond; }

%}

%union {
    double fval;
    char *sval;
}

%token <fval> NUMBER FLOAT_LITERAL
%token <sval> STRING_LITERAL ID

%token NUM FLOAT_T TEXT SHOW TAKE WHEN OTHERWISE LOOP BEGIN_T END_T
%token GT LT IS SEMICOLON ASSIGN LPAREN RPAREN
%token PLUS MINUS MULT DIV

%left PLUS MINUS
%left MULT DIV

%type <fval> expr condition

%%

program:
    statements
    ;

statements:
      /* empty */
    | statements statement
    ;

statement:
      declaration
    | assignment
    | print_stmt
    | input_stmt
    | control
    ;

// ------------------- DECLARATION -------------------
declaration:
      NUM ID SEMICOLON        { set_var($2, INT_VAR, 0, NULL); free($2); }
    | FLOAT_T ID SEMICOLON    { set_var($2, FLOAT_VAR, 0.0, NULL); free($2); }
    | TEXT ID SEMICOLON       { set_var($2, TEXT_VAR, 0, ""); free($2); }
    ;

// ------------------- ASSIGNMENT -------------------
assignment:
      ID ASSIGN expr SEMICOLON {
        int i = find_var($1);
        if (i == -1) { yyerror("Variable not declared"); }
        else { vars[i].fval = $3; }
        free($1);
    }
    | ID ASSIGN STRING_LITERAL SEMICOLON {
        int i = find_var($1);
        if (i == -1) { yyerror("Variable not declared"); }
        else { strcpy(vars[i].sval, $3); }
        free($1); free($3);
    }
    ;

// ------------------- INPUT -------------------
input_stmt:
    TAKE LPAREN ID RPAREN SEMICOLON {
        int i = find_var($3);
        if (i == -1) { yyerror("Variable not declared"); }
        else {
            double val;
            scanf("%lf", &val);
            vars[i].fval = val;
        }
        free($3);
    }
    ;

// ------------------- PRINT -------------------
print_stmt:
      SHOW LPAREN expr RPAREN SEMICOLON      { printf("%g\n", $3); }
    | SHOW LPAREN STRING_LITERAL RPAREN SEMICOLON { printf("%s\n", $3); free($3); }
    ;

// ------------------- CONTROL STRUCTURES -------------------
control:
      WHEN LPAREN condition RPAREN BEGIN_T statements END_T optional_else
    | LOOP LPAREN condition RPAREN BEGIN_T statements END_T {
        // Simple runtime loop
        while ($3) {
            yyparse(); // recursively parse statements inside loop
            break;    // in real interpreter we would re-evaluate $3
        }
    }
    ;

optional_else:
      /* empty */
    | OTHERWISE BEGIN_T statements END_T
    ;

// ------------------- CONDITIONS -------------------
condition:
      expr GT expr { $$ = ($1 > $3); }
    | expr LT expr { $$ = ($1 < $3); }
    | expr IS expr { $$ = ($1 == $3); }
    ;

// ------------------- EXPRESSIONS -------------------
expr:
      NUMBER        { $$ = $1; }
    | FLOAT_LITERAL { $$ = $1; }
    | ID {
            int i = find_var($1);
            if (i == -1) { yyerror("Variable not declared"); $$ = 0; }
            else { $$ = vars[i].fval; }
            free($1);
        }
    | expr PLUS expr  { $$ = $1 + $3; }
    | expr MINUS expr { $$ = $1 - $3; }
    | expr MULT expr  { $$ = $1 * $3; }
    | expr DIV expr   { if ($3==0){ yyerror("Divide by zero"); $$=0;} else $$=$1/$3; }
    | LPAREN expr RPAREN { $$ = $2; }
    ;

%%

void yyerror(const char *s) {
    extern int yylineno;
    fprintf(stderr, "Error at line %d: %s\n", yylineno, s);
}

int main() {
    yyparse();
    return 0;
}