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
int switchcase=0;
int default_place=0;

%}
%start program

%token ID PUNC TYPE CHAR_TYPE
%token IN DOU TF CHA STR
%token ENDLINE
%token CONS VOI
%token LOR LAND LNOT COMP DP DM
%token FOR
%token IF ELSE
%token DO WHILE
%token BREAK CONTINUE RETURN
%token SWITCH CASE DEFAULT

%left LOR
%left LAND
%nonassoc '!'
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
	| line use ';' { compound[stack]=1; }
	| line fun_struct
	| 
	;
/////////////////using///////////////////
use: usage
   | RETURN condition
   | CONTINUE
   | BREAK
   ;
usage: ID '=' expression
   | ID Arr '=' expression
   | expression
   ;

/////////////////Function define////////////////
fun_struct: '{' {if(function_exist==1)function_exist=2;else stack++;}
	   | '}' {
	   	compound[stack]=0;
	   	if(stack!=0)stack--;
	   	else function_exist=3;
	   	if(switchcase==1) yyerror("switch with no case");
	   	default_place=0;
	   }
	   ;
fun: id_fun {
      if(compound[stack]==1) yyerror("strict order");
     	if(function_exist==2) yyerror("function nested");
    	function_exist=1;
    				}
   | for_fun 
   | if_fun
   | while_fun
   | switch_fun
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
func_invocation: ID '(' expr ')'
       ;
////////////////if-condition define/////////////
if_fun: IF '(' expression ')'
	  | ELSE
	  ;
////////////////while-loop define////////////////
while_fun: WHILE '(' expression ')' sem_or_not
		 | DO
		 ;
////////////////switch define//////////////////
switch_fun: SWITCH '(' ID ')' {switchcase=1;}
		  | CASE int_char ':' {switchcase=0;if(default_place==1)yyerror("default not at last");}
		  | DEFAULT ':' {default_place=1;}
		  ;
////////////////for-loop define///////////////
for_fun: FOR '(' for_init ';' condition ';' for_last ')' sem_or_not
	   ;
sem_or_not: ';'	//self-define
	   | 
	   ;
condition: expression
		 | 
		 ;
for_init: 
		| usage ',' for_init
		| usage
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
int_char: IN
		| CHA
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
          | '!' expression
          | func_invocation
          | ID Arr
          ;

%%
int main(void){
	yyparse();
	if(function_exist!=3)
	{
		lastsentence[0]='\0';
		yyerror(" ");
	}
  printf("No syntax error!\n");
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