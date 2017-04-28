parser: scanner.l parser.y
	lex scanner.l
	byacc -d parser.y
	gcc -o parser lex.yy.c y.tab.c
clean:
	rm -f parser
	rm -f lex.yy.c
