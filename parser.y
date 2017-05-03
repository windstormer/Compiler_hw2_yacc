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
%token ID OP PUNC TYPE CHAR_TYPE VOI
%token IN DOU TF CHA STR
%token ENDLINE
%token CONS
%%

program:line ENDLINE program;
     | 
     ;

line: line TYPE S
    | line CONS TYPE cons_S
    | line fun {
     	if(function_exist==2) yyerror("function nested");
    	function_exist=1;
    				}
	| line fun_use
	| 
	;


/////////////////Function define////////////////
fun_use: ID '(' expr ')' ';'
	   | '{' {function_exist=2;}
	   | '}' {function_exist=3;}
	   ;
fun: TYPE ID '(' para ')'
   | TYPE ID '(' ')'
   | VOI ID '(' para ')'
   | VOI ID '(' ')'
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
		| OP ID '(' expr ')'
		| 
        ;


////////////////Normal Array////////////////
Arr: PUNC IN PUNC
   | Arr PUNC IN PUNC
   ;
Arr_INI: OP '{' expr '}' /*={con}*/
   ; 


///////////////Value select//////////////   
NUM: IN
   | DOU
   | TF
   | CHA
   | STR
   ;

///////////////expression////////////////
expr: NUM con
	| NUM
	| 
	;  
con: con ',' NUM //connect
   | ',' NUM
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
	fprintf( stderr, "Error message: %s\n",s);

	fprintf( stderr, "*** Error at line %d: %s\n", lineCount+1, lastsentence );
	fprintf( stderr, "\n" );
	fprintf( stderr, "Unmatched token: %s\n", yytext );
	fprintf( stderr, "*** syntax error\n");
	exit(-1);
}