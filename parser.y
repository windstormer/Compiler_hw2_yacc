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
int curstack=0;

%}
%start program

%token ID TYPE CHAR_TYPE
%token IN DOU TF CHA STR NUL
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
%left COMP
%left '+' '-'
%left '*' '/' '%'
%nonassoc unary
%left DP DM
%left '[' ']'

%%

program:line ENDLINE program
     |
     ;

line: line TYPE lots_of_declaration ';' {
                                          if(compound[stack]==1) yyerror("strict order");
                                          if(switchcase==2&&curstack==stack)yyerror("define in switchcase");
                                        }
    | line CONS TYPE cons_lots_of_declaration ';' {if(compound[stack]==1) yyerror("strict order");}
    | line fun 
	| line use ';' {  if(stack==0) yyerror("statement in global"); compound[stack]=1; }
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
fun_struct: '{' {if(function_exist==1)function_exist=2; stack++;}
	   | '}' {
      	   	compound[stack]=0;
      	   	if(stack!=0)stack--; 
            if(function_exist==2)function_exist=3;
      	   	if(switchcase==1) yyerror("switch with no case");
      	   	default_place=0;
            switchcase = 0;
            curstack=0;
      	   }
	   ;
fun: id_fun {
              if(compound[stack]==1) yyerror("strict order");
             	if(function_exist==2) yyerror("function nested");
            	function_exist=1;
    				}
   | for_fun {  if(stack==0) yyerror("statement in global");}
   | if_fun {  if(stack==0) yyerror("statement in global");}
   | while_fun {  if(stack==0) yyerror("statement in global");}
   | switch_fun {  if(stack==0) yyerror("statement in global");}
   ;

id_fun: TYPE ID '(' para ')'
   | VOI ID '(' para ')'
   ;

para: para_style ',' para
    | para_style
    | 
    ;

para_style: TYPE ID
          | TYPE ID Arr_declare
          ;
func_invocation: ID '(' lots_of_expression ')'
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
		  | CASE int_char ':' {switchcase=2;curstack=stack;if(default_place==1)yyerror("default not at last");}
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
for_last: usage ',' for_last
		| usage
		| 
		;
/////////////////Normal declaration/////////////////////
lots_of_declaration: declaration ',' lots_of_declaration
                   | declaration
                   ; 

declaration: ID normal_init
           | ID Arr_declare Arr_INI
           | ID Arr_declare
           | ID '(' para ')'
           ;

/////////////////Const declaration///////////
cons_lots_of_declaration: cons_declaration ',' cons_lots_of_declaration
                        | cons_declaration
                        ;

cons_declaration: ID '=' expression
                ;



normal_init: '=' init_expression
           | 
           ;


////////////////Normal Array////////////////
Arr: '[' lots_of_expression ']'
   | Arr '[' lots_of_expression ']'
   ;
Arr_declare: '[' IN ']'
           | Arr_declare '[' IN ']'
           ;
Arr_INI: '=' '{' lots_of_expression '}'
       ; 


///////////////Value select//////////////   
NUM: IN
   | DOU
   | TF
   | CHA
   | STR
   | NUL
   ;

INT_DOUBLE: IN
          | DOU
          ;
UNUM: '-' INT_DOUBLE %prec unary
    | '+' INT_DOUBLE %prec unary
    | NUM
    ;
int_char: IN
    		| CHA
    		;

///////////////expression////////////////
lots_of_expression: expression ',' lots_of_expression
                	| expression
                	| 
                	;  


expression: expression '+' expression
          | expression '-' expression
          | expression '*' expression
          | expression '/' expression
          | expression '%' expression
          | ID DP
          | ID DM
          | expression COMP expression
          | expression LOR expression
          | expression LAND expression
          | '(' expression ')'
          | ID
          | UNUM
          | '!' expression 
          | ID Arr
          | func_invocation
          ;

init_expression: init_expression '+' init_expression
          | init_expression '-' init_expression
          | init_expression '*' init_expression
          | init_expression '/' init_expression
          | init_expression '%' init_expression
          | ID DP
          | ID DM
          | init_expression COMP init_expression
          | init_expression LOR init_expression
          | init_expression LAND init_expression
          | '(' init_expression ')'
          | ID
          | UNUM
          | '!' init_expression
          | ID Arr
          ;

%%
int main(void){
	yyparse();
	if(function_exist!=3)
	{
    lastsentence[0]='\0';
		yyerror("Need at least one function");
	}
  fprintf(stdout,"No syntax error!\n");
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