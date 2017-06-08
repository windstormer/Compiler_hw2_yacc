%option yylineno

%{
	#include <stdio.h>
	#include <string.h>
	#include "y.tab.h"
int	lineCount=0;
char lastsentence[3000];
char tempstring[3000];
int token = 1;
int source = 1;

void PrintToken(const char str[])
{
	if(token==1)
	{
		fprintf(stdout,"%s:%s\n",str,tempstring);
	}
}

%}

stdio "printf"|"scanf"|"fprintf"|"fscanf"|"sprintf"|"sscanf"|"vfprintf"|"vprintf"|"vsprintf"
stdfile "fclose"|"fflush"|"fopen"|"freopen"|"remove"|"rename"|"setbuf"|"setvbuf"|"tmpfile"|"tmpnam"
stdchio "fgetc"|"fgets"|"fputc"|"fputs"|"getc"|"getchar"|"gets"|"putc"|"putchar"|"puts"|"ungetc"
stdblio "fread"|"fwrite"
stdfilepos "fgetpos"|"fseek"|"fsetpos"|"ftell"|"rewind"
stderror "clearerr"|"feof"|"ferror"|"perror"
key "for"|"while"|"do"|"if"|"else"|"switch"|"break"|"continue"|"case"|"return"|"void"|"null"|"const"|"default"
type "int"|"double"|"short"|"float"|"char"|"bool"|"unsigned double"|"unsigned int"|"unsigned short"|"unsigned float"|"unsigned char"|"struct"|"unsigned"
logic "true"|"false"
double_operator (\+\+|--|<<|>>|==|<=|>=|!=|\|\||\&\&)
single_operator (\+|-|<|>|\*|\/|!|\||\&|\%|=)
punctuation (:|;|,|\.|\[|\]|\(|\)|\{|\})
strings (\".*\")
Quote "
chars ('.'|'\\n'|'\\t')
id [a-zA-Z_][a-zA-Z_0-9]*
sci ([0-9]*\.?[0-9]+|[0-9]+\.[0-9]*)([eE][-+]?[0-9]+)
Double [0-9]*\.[0-9]+|[0-9]+\.[0-9]*
Int [1-9][0-9]*|0

Invalid_sci ([0-9]*\.?[0-9]+|[0-9]+\.[0-9]*)([eE][-+]?([0-9]*\.[0-9]+|[0-9]+\.[0-9]*))
Invalid_id [0-9]+[a-zA-Z_]+
Invalid_int 0[0-9]+|0[xX][0-9a-fA-F]+


%x COMMENT
%x STATE
%x RE

%%

.*\n {
	if(strcmp(yytext,"#pragma token on\n")==0) {
		token = 1;
	}
	if(strcmp(yytext,"#pragma source on\n")==0)	{
		source = 1;
	}

		strcpy(lastsentence,yytext);

			yyless(0);
			BEGIN STATE;
		
}
<STATE>"#pragma source off" {
	source = 0;
}
<STATE>"#pragma source on" {
	source = 1;
}

<STATE>"#pragma token off" {
	token = 0;
}
<STATE>"#pragma token on" {
	token = 1;
}

<STATE>\n {
	if(source==1)
	{
		lineCount++;
		fprintf(stdout,"%d:%s", lineCount,lastsentence);
		BEGIN 0;
	}else
	{
		lineCount++;
		BEGIN 0;
	}
	return ENDLINE;
}
<STATE>\/\*.*\*\/ {
}
<STATE>\/\* {	
	BEGIN COMMENT;
}
<COMMENT>\n {
	lineCount++;
	fprintf(stdout,"%d:%s", lineCount,lastsentence);
	BEGIN RE;
}
<RE>.*\n {
	strcpy(lastsentence,yytext);
	yyless(0);
	BEGIN COMMENT;
}
<COMMENT>\*\/ {
	BEGIN STATE;
}
<COMMENT>. {
}

<STATE>\/\/.* {
}


<STATE>{strings} {
	strncpy(tempstring,yytext+1,strlen(yytext)-2);
	tempstring[strlen(yytext)-2]='\0';
	PrintToken("#string");
	return STR;
}

<STATE>{chars} {
	strcpy(tempstring,yytext);
	PrintToken("#char");
	return CHA;
}

<STATE>{key} { 
	strcpy(tempstring,yytext);
	PrintToken("#key");
	if(strcmp(yytext,"const")==0)
		return CONS;
	if(strcmp(yytext,"void")==0)
		return VOI;
	if(strcmp(yytext,"for")==0)
		return FOR;
	if(strcmp(yytext,"if")==0)
		return IF;
	if(strcmp(yytext,"else")==0)
		return ELSE;
	if(strcmp(yytext,"do")==0)
		return DO;
	if(strcmp(yytext,"while")==0)
		return WHILE;
	if(strcmp(yytext,"return")==0)
		return RETURN;
	if(strcmp(yytext,"break")==0)
		return BREAK;
	if(strcmp(yytext,"continue")==0)
		return CONTINUE;
	if(strcmp(yytext,"switch")==0)
		return SWITCH;
	if(strcmp(yytext,"case")==0)
		return CASE;
	if(strcmp(yytext,"default")==0)
		return DEFAULT;
	if(strcmp(yytext,"null")==0)
		return NUL;

}
<STATE>{stdio} { 
	strcpy(tempstring,yytext);
	PrintToken("#key");
	return ID;
}
<STATE>{stdfile} { 
	strcpy(tempstring,yytext);
	PrintToken("#key");
	return ID;
}
<STATE>{stdchio} { 
	strcpy(tempstring,yytext);
	PrintToken("#key");
	return ID;
}
<STATE>{stdblio} { 
	strcpy(tempstring,yytext);
	PrintToken("#key");
	return ID;
}
<STATE>{stdfilepos} { 
	strcpy(tempstring,yytext);
	PrintToken("#key");
	return ID;
}
<STATE>{stderror} { 
	strcpy(tempstring,yytext);
	PrintToken("#key");
	return ID;
}
<STATE>{type} { 
	strcpy(tempstring,yytext);
	PrintToken("#key");
	if(strcmp(yytext,"struct")!=0)
		return TYPE;
}
<STATE>{logic} { 
	strcpy(tempstring,yytext);
	PrintToken("#key");
	return TF;
}

<STATE>{double_operator} {
	strcpy(tempstring,yytext);
	PrintToken("#op");
	if(strcmp(yytext,"||")==0)
	 return LOR;
	if(strcmp(yytext,"&&")==0)
	 return LAND;
	if(strcmp(yytext,"++")==0)
	 return DP;
	if(strcmp(yytext,"--")==0)
	 return DM;
	if(strcmp(yytext,">=")==0)
	 return COMP;
	if(strcmp(yytext,"<=")==0)
	 return COMP;
	if(strcmp(yytext,"==")==0)
	 return COMP;
	if(strcmp(yytext,"!=")==0)
	 return COMP;
}

<STATE>{single_operator} {
	strcpy(tempstring,yytext);
	PrintToken("#op");

	if(strcmp(yytext,"=")==0)
	 return '=';
	if(strcmp(yytext,"+")==0)
	 return '+';
	if(strcmp(yytext,"-")==0)
	 return '-';
	if(strcmp(yytext,"*")==0) 
	 return '*';
	if(strcmp(yytext,"/")==0)
	 return '/';
	if(strcmp(yytext,"%")==0)
	 return '%';
	if(strcmp(yytext,"!")==0)
	 return '!';
	if(strcmp(yytext,">")==0)
	 return COMP;
	if(strcmp(yytext,"<")==0)
	 return COMP;

}

<STATE>{punctuation} {
	strcpy(tempstring,yytext);
	PrintToken("#punc");
	if(strcmp(yytext,";")==0)
		return ';';
	if(strcmp(yytext,",")==0)
		return ',';
	if(strcmp(yytext,"}")==0)
		return '}';
	if(strcmp(yytext,"{")==0)
		return '{';
	if(strcmp(yytext,"(")==0)
		return '(';
	if(strcmp(yytext,")")==0)
		return ')';
	if(strcmp(yytext,"[")==0)
		return '[';
	if(strcmp(yytext,"]")==0)
		return ']';
	if(strcmp(yytext,":")==0)
		return ':';
}

<STATE>" "|"\t"

<STATE>{id} {
	strcpy(tempstring,yytext);
	PrintToken("#id");
	return ID;
}

<STATE>{Invalid_id} {
	fprintf(stderr, "Error at line %d: %s\n",yylineno,yytext);
	exit(1);
}
<STATE>{Invalid_sci} {
	fprintf(stderr, "Error at line %d: %s\n",yylineno,yytext);
	exit(1);
}

<STATE>{sci} {
	strcpy(tempstring,yytext);
	PrintToken("#sci");
	return DOU;
}

<STATE>{Double} {
	strcpy(tempstring,yytext);
	PrintToken("#double");
	return DOU;
}
<STATE>{Invalid_int} {
	fprintf(stderr, "Error at line %d: %s\n",yylineno,yytext);
	exit(1);
}

<STATE>{Int} {
	strcpy(tempstring,yytext);
	PrintToken("#integer");
	return IN;
}

<STATE>. {
	fprintf(stderr, "Error at line %d: %s\n",yylineno,yytext);
	exit(1);
}


%%
int yywrap()
{
	return 1;
}
