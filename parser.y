%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

extern int lineCount;
extern char lastsentence[3000];
extern char* yytext;
%}
%start program
%union{
	char* sVal;
}
%token ID OP NUM PUNC TYPE ENDLINE SEM COMMA
%%

program: TYPE S ENDLINE program
     | ENDLINE program;
     | 
     ;

S: S exp SEM
 | exp COMMA
 | exp SEM
 ; 

exp: ID exp_plum
   | ID
   | ID Arr INI
   | ID Arr
   ;

exp_plum: OP NUM
        ;
Arr: PUNC NUM PUNC
   | Arr PUNC NUM PUNC
   ;
INI: OP PUNC NUM CON PUNC
   | OP PUNC NUM PUNC
   ;
CON: CON COMMA NUM
   | COMMA NUM
   ;
%%
int main(void){
	yyparse();
	return 0;
}
int yyerror(char *s){
	fprintf( stderr, "*** Error at line %d: %s\n", lineCount, lastsentence );
	fprintf( stderr, "\n" );
	fprintf( stderr, "Unmatched token: %s\n", yytext );
	fprintf( stderr, "*** syntax error\n");
	exit(-1);
}