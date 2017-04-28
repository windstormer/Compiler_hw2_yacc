%{
#include <stdio.h>
#include <stdlib.h>
extern int lineCount;
extern char lastsentence[3000];
extern char* yytext;
%}
%union{
	char* sVal;
}
%token ID OP NUM PUNC TYPE ENDLINE
%%

Whole: TYPE S ENDLINE Whole{printf("0\n");}
     | ENDLINE Whole;
     ;
S: S exp PUNC {printf("1\n");}
 | exp PUNC {printf("2\n");}
 ; 
exp: ID exp_plum {printf("3\n");}
   | ID {printf("4\n");}
   ;
exp_plum: OP NUM {printf("5\n");}
        ;
%%
int main(void){
	yyparse();
	return 0;
}
int yyerror(char *s){
	fprintf( stderr, "*** Error at line %d: %s\n", lineCount+1, lastsentence );
	fprintf( stderr, "\n" );
	fprintf( stderr, "Unmatched token: %s\n", yytext );
	fprintf( stderr, "*** syntax error\n");
	exit(-1);
}