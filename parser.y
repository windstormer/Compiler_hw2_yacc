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
%token ID OP PUNC TYPE CHAR_TYPE
%token IN DOU TF CHA STR/*STR not done yet*/
%token ENDLINE
%token CONS VOI
%%

program:line ENDLINE program;
     | 
     ;

line: line TYPE S
    | line CONS TYPE cons_S
    | line CHAR_TYPE CHAR_S
	| 
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

   /////////////////Char and Char array////////////////
CHAR_S: CHAR_S CHAR_exp ';'
	  | CHAR_exp ','
	  | CHAR_exp ';'
	  ; 
CHAR_exp: ID exp_plum
        | ID Arr StringINI
        ;
StringINI: OP STR
         | 
         ;


exp_plum: OP NUM
		| 
        ;
////////////////Normal Array////////////////
Arr: PUNC IN PUNC
   | Arr PUNC IN PUNC
   ;
Arr_INI: OP PUNC NUM CON PUNC /*={2CON}*/
   | OP PUNC NUM PUNC
   ;   
CON: CON ',' NUM
   | ',' NUM
   ;

///////////////Value select//////////////   
NUM: IN
   | DOU
   | TF
   | CHA
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