scanner: scanner.l
	lex scanner.l
	gcc -o scanner lex.yy.c
clean:
	rm -f scanner
	rm -f lex.yy.c
