%{
#include <stdio.h>
%}

% token ID op Num
%%


%%
int main(void){
	yyparse();
	return 0;
}

int yyerror(char *s){
	fprintf( stderr, "*** Error at line %d: %s\n", linenum, buff );
	fprintf( stderr, "\n" );
	fprintf( stderr, "Unmatched token: %s\n", yytext );
	fprintf( stderr, "*** syntax error\n");
	exit(-1);
}