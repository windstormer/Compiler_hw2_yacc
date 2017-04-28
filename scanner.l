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
key "for"|"while"|"do"|"if"|"else"|"switch"|"break"|"continue"|"true"|"false"|"case"|"return"|"void"|"null"|"const"|"default"
type "int"|"double"|"short"|"float"|"char"|"bool"|"unsigned double"|"unsigned int"|"unsigned short"|"unsigned float"|"unsigned char"|"struct"|"unsigned"
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
}

<STATE>{chars} {
	strcpy(tempstring,yytext);
	PrintToken("#char");
}

<STATE>{key} { 
	strcpy(tempstring,yytext);
	PrintToken("#key");
}
<STATE>{stdio} { 
	strcpy(tempstring,yytext);
	PrintToken("#key");
}
<STATE>{stdfile} { 
	strcpy(tempstring,yytext);
	PrintToken("#key");
}
<STATE>{stdchio} { 
	strcpy(tempstring,yytext);
	PrintToken("#key");
}
<STATE>{stdblio} { 
	strcpy(tempstring,yytext);
	PrintToken("#key");
}
<STATE>{stdfilepos} { 
	strcpy(tempstring,yytext);
	PrintToken("#key");
}
<STATE>{stderror} { 
	strcpy(tempstring,yytext);
	PrintToken("#key");
}
<STATE>{type} { 
	strcpy(tempstring,yytext);
	PrintToken("#key");
	return TYPE;
}

<STATE>{double_operator} {
	strcpy(tempstring,yytext);
	PrintToken("#op");
	return OP;
}

<STATE>{single_operator} {
	strcpy(tempstring,yytext);
	PrintToken("#op");
	return OP;
}

<STATE>{punctuation} {
	strcpy(tempstring,yytext);
	PrintToken("#punc");
	return PUNC;
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
	return NUM;
}

<STATE>{Double} {
	strcpy(tempstring,yytext);
	PrintToken("#double");
	return NUM;
}
<STATE>{Invalid_int} {
	fprintf(stderr, "Error at line %d: %s\n",yylineno,yytext);
	exit(1);
}

<STATE>{Int} {
	strcpy(tempstring,yytext);
	PrintToken("#integer");
	return NUM;
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
