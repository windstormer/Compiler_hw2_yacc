%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

extern int lineCount;
extern char lastsentence[3000];
extern char* yytext;
int function_exist=0;
int compound[200]={0};
int stack=0;

%}
%start program
%union{
	char* sVal;
}
%token ID PUNC TYPE CHAR_TYPE
%token IN DOU TF CHA STR
%token ENDLINE
%token CONS VOI
%token LOR LAND LNOT COMP DP DM
%token FOR
%token IF ELSE

%left LOR
%left LAND
%nonassoc LNOT
%left COMP '='
%left '+' '-'
%left '*' '/' '%'
// %nonassoc IN
%left DP DM
%left '[' ']'

%%

program:line ENDLINE program;
     | 
     ;

line: line TYPE S ';' {if(compound[stack]==1) yyerror("strict order");}
    | line CONS TYPE cons_S ';' {if(compound[stack]==1) yyerror("strict order");}
    | line fun 
	| line use ';' {
    if(function_exist!=2) compound[stack]=1;
      }
  | line fun_struct
	| 
	;
/////////////////using///////////////////
use: ID exp_plum
   | ID Arr Arr_INI
   | func_return
   ;

/////////////////Function define////////////////
fun_struct: '{' {if(function_exist==1)function_exist=2;else stack++;}
	   | '}' {if(stack!=0)stack--;else function_exist=3;}
	   ;
fun: id_fun {
      if(compound[stack]==1) yyerror("strict order");
     	if(function_exist==2) yyerror("function nested");
    	function_exist=1;
    				}
   | for_fun 
   | if_fun
   ;

id_fun: TYPE ID '(' para ')'
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
func_return: ID '(' expr ')'
       ;
////////////////if-condition define/////////////
if_fun: IF '(' expression ')'
	  | ELSE
	  ;

////////////////for-loop define///////////////
for_fun: FOR '(' for_init ';' condition ';' for_last ')' end_for
	   ;
end_for: ';'	//self-define
	   | 
	   ;
condition: expression
		 | 
		 ;
for_init: S
		| 
		;
for_last: expression ',' for_last
		| expression
		| 
		;
/////////////////Normal exp/////////////////////
S: exp ',' S
 | exp
 ; 

exp: ID exp_plum
   | ID Arr Arr_INI
   | ID Arr
   ;

/////////////////Const exp///////////
cons_S: cons_exp ',' cons_S
      | cons_exp
      ;

cons_exp: ID exp_plum
   		;



exp_plum: '=' expression
		| '=' func_return
		| 
   		;


////////////////Normal Array////////////////
Arr: '[' expression ']'
   | Arr '[' expression ']'
   ;
Arr_INI: '=' '{' expr '}' /*={con}*/
   ; 


///////////////Value select//////////////   
NUM: IN
   | DOU
   | TF
   | CHA
   | STR
   ;
UNUM: '-' NUM
    | NUM
    ;

///////////////expression////////////////
expr: expression con
	| expression
	| 
	;  
con: con ',' expression //connect
   | ',' expression
   ;

expression: expression '+' expression
          | expression '-' expression
          | expression '*' expression
          | expression '/' expression
          | expression '%' expression
          | expression DP
          | expression DM
          | expression COMP expression
          | expression LOR expression
          | expression LAND expression
          | '(' expression ')'
          | ID
          | UNUM
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