%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

extern int lineCount;
extern char lastsentence[3000];
extern char* yytext;
int function_exist=0;

%}
%start program
%union{
	char* sVal;
}
%token ID OP PUNC TYPE CHAR_TYPE
%token IN DOU TF CHA STR
%token ENDLINE
%token CONS VOI
%%

program:line ENDLINE program;
     | 
     ;

line: line TYPE S
    | line CONS TYPE cons_S
    | line TYPE fun {function_exist=1;}
    | line '{' {function_exist=2;}
	| line '}' {function_exist=3;}
	| 
	;
/////////////////Function define////////////////
fun: ID '(' para ')'
   | ID '(' ')'
   ;
para: para_style ',' para
    | para_style
    ;

para_style: TYPE ID
          | TYPE ID Arr
          ;
/////////////////Normal exp/////////////////////
S: S exp ';'
 | exp ','
 | exp ';'
 ; 

exp: ID exp_plum
   | ID Arr Arr_INI
   | ID Arr
   ;

/////////////////Const exp///////////
cons_S: cons_S cons_exp ';'
 | cons_exp ','
 | cons_exp ';'
 ; 

cons_exp: ID exp_plum
   ;



exp_plum: OP NUM
		| 
        ;
////////////////Normal Array////////////////
Arr: PUNC IN PUNC
   | Arr PUNC IN PUNC
   ;
Arr_INI: OP '{' NUM con '}' /*={con}*/
   | OP '{' NUM '}'
   ;   
con: con ',' NUM //connect
   | ',' NUM
   ;

///////////////Value select//////////////   
NUM: IN
   | DOU
   | TF
   | CHA
   | STR
   ;
%%
int main(void){
	yyparse();
	if(function_exist!=3)
	{
		lastsentence[0]='\0';
		yyerror(" ");
	}
	return 0;
}
int yyerror(char *s){
	fprintf( stderr, "*** Error at line %d: %s\n", lineCount+1, lastsentence );
	fprintf( stderr, "\n" );
	fprintf( stderr, "Unmatched token: %s\n", yytext );
	fprintf( stderr, "*** syntax error\n");
	exit(-1);
}