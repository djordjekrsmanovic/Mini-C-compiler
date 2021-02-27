%option noyywrap yylineno
%{
   #include <string.h>
   #include "micko.tab.h"
   #include "defs.h"
   extern YYSTYPE yylval;
%}

%%

[ \t\n]+             { /* skip */ }

"int"                { yylval.i = INT;  return _TYPE; }
"unsigned"           { yylval.i = UINT; return _TYPE; }
"void"							 { yylval.i=VOID; return _TYPE;}
"if"                 { return _IF; }
"else"               { return _ELSE; }
"return"             { return _RETURN; }
"loop"							 { return _LOOP;}
"branch"						 { return _BRANCH;}
"one"								 { return _ONE;}
"two"								 { return _TWO;}
"three"							 { return _THREE;}
"other"							 { return _OTHER;}
"while"							 { return _WHILE;}
"switch"             { return _SWITCH;}
"case"							 { return _CASE;}
"default"						 { return _DEFAULT;}
"break"							 { return _BREAK;}

	
"("                  { return _LPAREN; }
")"                  { return _RPAREN; }
"{"                  { return _LBRACKET; }
"}"                  { return _RBRACKET; }
";"                  { return _SEMICOLON; }
"="                  { return _ASSIGN; }

"+"                  { yylval.i = ADD; return _AROP; }
"-"                  { yylval.i = SUB; return _AROP; }

"<"                  { yylval.i = LT; return _RELOP; }
">"                  { yylval.i = GT; return _RELOP; }
"<="                 { yylval.i = LE; return _RELOP; }
">="                 { yylval.i = GE; return _RELOP; }
"=="                 { yylval.i = EQ; return _RELOP; }
"!="                 { yylval.i = NE; return _RELOP; }
","									 {return _COMMA;}
"++"								 {return _INCREMENT;}
"->"								 {return _ARROW;}
"["									 {return _LSQRBRACKET;}	
"]"									 {return _RSQRBRACKET;}
"?"									 {return _UPITNIK;}	
":"									 {return _DVOTACKA;}

[a-zA-Z][a-zA-Z0-9]* { yylval.s = strdup(yytext); 
                       return _ID; }
[+-]?[0-9]{1,10}     { yylval.s = strdup(yytext); 
                       return _INT_NUMBER;}
[0-9]{1,10}[uU]      { yylval.s = strdup(yytext); 
                       yylval.s[yyleng-1] = 0;
                       return _UINT_NUMBER;}

"/*"([^*]|"\n"|(\*+([^*/]|"\n")))*"*"+"/" {}
\/\/.*               { /* skip */ }
.                    { printf("line %d: LEXICAL ERROR on char %c\n", yylineno, *yytext);}
%%
