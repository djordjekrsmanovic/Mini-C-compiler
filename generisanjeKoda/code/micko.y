%{
  #include <stdio.h>
  #include <stdlib.h>
  #include "defs.h"
  #include "symtab.h"
  #include "codegen.h"
	#include "stack.h"

  int yyparse(void);
  int yylex(void);
  int yyerror(char *s);
  void warning(char *s);

  extern int yylineno;
  int out_lin = 0;
  char char_buffer[CHAR_BUFFER_LENGTH];
  int error_count = 0;
  int warning_count = 0;
  int var_num = 0;
  int fun_idx = -1;
  int fcall_idx = -1;
  int lab_num = -1;
	int number_of_increment=0;
	incrementStack st;
	int reg=0; // registar koristen u ternarnom operatoru
	int tip_promjenljive=0;
	int num_of_return=0;
	int param_num=0;
	int pozicija=0; //predstavlja indeks niza atr2 u koji se stavljaju parametri funkcije
	int argument_function_cnt=0; //indeks za dobavljanje tipa parametra funkcije
	int loop_id_type=0;
	int compound_counter=0;
	int niz_compound[100];
	int dolazim_iz_if=0;
	int reg;
	int niz_arguments[100];
	int brojac_arguments=0;
	int broj_iskoristenih_reg=0;
	int tip_promjenljive_switch=0;
	int niz_case[100];
	int brojac_case=0;
	int switch_lab_num=-1;
	
  FILE *output;
%}

%union {
  int i;
  char *s;
}

%token <i> _TYPE
%token _IF
%token _ELSE
%token _RETURN
%token <s> _ID
%token <s> _INT_NUMBER
%token <s> _UINT_NUMBER
%token _LPAREN
%token _RPAREN
%token _LBRACKET
%token _RBRACKET
%token _ASSIGN
%token _SEMICOLON
%token <i> _AROP
%token <i> _RELOP
%token _COMMA;
%token _INCREMENT;
%token _LOOP;
%token _BRANCH;
%token _ONE;
%token _TWO;
%token _THREE;
%token _OTHER;
%token _ARROW;
%token _LSQRBRACKET;
%token _RSQRBRACKET;
%token _WHILE;
%token _UPITNIK;
%token _DVOTACKA;
%token _VOID;
%token _SWITCH
%token _BREAK
%token _DEFAULT
%token _CASE

%type <i> num_exp exp literal izraz1 opcioni_dio glob argument 
%type <i> function_call  rel_exp if_part

%nonassoc ONLY_IF
%nonassoc _ELSE

%%

program
  :global_variables function_list
      {  
        if(lookup_symbol("main", FUN) == NO_INDEX)
          err("undefined reference to 'main'");
      }
  ;

global_variables
	: /*empty*/
	| global_variables global_variable
	;

global_variable
	: glob _SEMICOLON
	;
	
glob 
	: _TYPE _ID {
		if(lookup_symbol($2, VAR|PAR|GVAR) == NO_INDEX)
           insert_symbol($2, GVAR, $1, var_num, NO_ATR);
        else 
           err("redefinition of '%s'", $2);
		code("\n%s:",$2);
		code("\n\t\tWORD\t\t1");
		$$=$1;
	}
	| glob _COMMA _ID{
			if (lookup_symbol($3,VAR|PAR|GVAR)==NO_INDEX)
				insert_symbol($3,GVAR,$1,var_num,NO_ATR);
			else
				err("redefinition of '%s'",$3);
			code("\n%s:",$3);
			code("\n\t\tWORD\t\t1");
			$$=$1;
		}

function_list
  : function
  | function_list function
  ;

function
  : _TYPE _ID
      {
        fun_idx = lookup_symbol($2, FUN);
        if(fun_idx == NO_INDEX)
          fun_idx = insert_symbol($2, FUN, $1, NO_ATR, NO_ATR);
        else 
          err("redefinition of function '%s'", $2);

        code("\n%s:", $2);
        code("\n\t\tPUSH\t%%14");
        code("\n\t\tMOV \t%%15,%%14");
      }
    _LPAREN parameter _RPAREN body
      {

								if (num_of_return==0 && get_type(fun_idx)!=VOID){
					warn("Function must have 'return statment'");

				}
        clear_symbols(fun_idx + 1);
        var_num = 0;
				pozicija=0;
				param_num=0;
				num_of_return=0;
        
        code("\n@%s_exit:", $2);
        code("\n\t\tMOV \t%%14,%%15");
        code("\n\t\tPOP \t%%14");
        code("\n\t\tRET");
      }
  ;

parameter
  : /* empty */
      { set_atr1(fun_idx, 0); }

  | _TYPE _ID
      {
				if ($1==VOID){
					err("Wrong type of parameter %s ",$2);
				}
        insert_symbol($2, PAR, $1, ++param_num, NO_ATR);
        set_atr1(fun_idx, 1);
        insertFunctionParameters(fun_idx,$1,pozicija++);
      }
	
	| parameter _COMMA _TYPE _ID
			{
				if ($3==VOID){
					err("Wrong type of parameter %s",$4);
				}
				if (lookup_symbol($4,VAR|PAR)==-1){
					insert_symbol($4,PAR,$3,++param_num,NO_ATR);
					set_atr1(fun_idx,param_num);
					insertFunctionParameters(fun_idx,$3,pozicija++);
				}else{
					err("Redefinition of parameter %s",$4);
				}
				
			}
  ;

body
  : _LBRACKET variable_list
      {
        if(var_num)
          code("\n\t\tSUBS\t%%15,$%d,%%15", 4*var_num);
        code("\n@%s_body:", get_name(fun_idx));
      }
    statement_list _RBRACKET
  ;

variable_list
  : /* empty */
  | variable_list variable
  ;

variable
  : _TYPE 
			 {
				tip_promjenljive=$1;
        //printf("%d",tip_promjenljive);
				if (tip_promjenljive==VOID)
					err("Wrong data type for variable ");
						

		}
			identificator_list _SEMICOLON
    

  ;

	identificator_list
	: _ID 
		{
			if(lookup_symbol($1,VAR|PAR)==-1 || get_atr2(lookup_symbol($1,VAR|PAR))!=compound_counter){
					insert_symbol($1,VAR,tip_promjenljive,++var_num,compound_counter);
			}else{
				//printf("%d",compound_counter);
				err("Redefinition of variable %s",$1);
			}
		}
	| identificator_list _COMMA _ID
		{
			if(lookup_symbol($3,VAR|PAR)==-1 || get_atr2(lookup_symbol($3,VAR|PAR))!=compound_counter){
					insert_symbol($3,VAR,tip_promjenljive,++var_num,compound_counter);
			}else{
				//printf("%d",compound_counter);
				err("Redefinition of variable %s",$3);
			}
		}
		
	;

statement_list
  : /* empty */
  | statement_list statement
  ;

statement
  : compound_statement
  | assignment_statement
  | if_statement
  | return_statement
	| increment_statement
	| loop_statement
	| branch_statement
	| function_call _SEMICOLON
	| while_statement
	| switch_statement
	| break_statement //dio dodatnog zadatka jer sam zelio da mogu napisati {a=a+5;b=b+1; break;} a ne {a=a+5;} break;
  ;

break_statement
	  : _BREAK _SEMICOLON{code("\n\t\tJMP @SWITCH_EXIT%d",switch_lab_num);}
		;

compound_statement
  : _LBRACKET{
				
				niz_compound[compound_counter]=get_last_element();
				//printf("%d\n",niz_compound[compound_counter]);
				compound_counter++;
			} 
			variable_list statement_list{
			//print_symtab();
			
			
			clear_symbols(niz_compound[--compound_counter]+1);
			//print_symtab();
			} 
			_RBRACKET
  ;
assignment_statement
  : _ID _ASSIGN num_exp _SEMICOLON
      {
        int idx = lookup_symbol($1, VAR|PAR|GVAR);
        if(idx == NO_INDEX)
          err("invalid lvalue '%s' in assignment", $1);
        else
          if(get_type(idx) != get_type($3))
            err("incompatible types in assignment");
				
        gen_mov($3, idx);
				
      }
  ;

num_exp
  : exp

  | num_exp _AROP exp
      {
        if(get_type($1) != get_type($3))
          err("invalid operands: arithmetic operation");
        int t1 = get_type($1);    
        code("\n\t\t%s\t", ar_instructions[$2 + (t1 - 1) * AROP_NUMBER]);
        gen_sym_name($1);
				
        code(",");
        gen_sym_name($3);
        code(",");
        free_if_reg($3);
        free_if_reg($1);
        $$ = take_reg();
        gen_sym_name($$);
        set_type($$, t1);
			}

	  
  ;





exp
  : literal

  | _ID
      {
        $$ = lookup_symbol($1, VAR|PAR|GVAR);
        if($$ == NO_INDEX)
          err("'%s' undeclared", $1);
      }

  | function_call
      {
        $$ = take_reg();
        gen_mov(FUN_REG, $$);
      }
  
  | _LPAREN num_exp _RPAREN
      { $$ = $2; }
	| _ID _INCREMENT
			{
					
					
					int index=lookup_symbol($1,VAR|PAR|GVAR);
					if (!(index!=-1 &&  (get_kind(index)==VAR || get_kind(index)==PAR || get_kind(index)==GVAR))){
						printf("USAO\n");
						err("wrong parameter %s for increment operation",$1);
						return 0;  
					}
				    
						int tip1=get_type(lookup_symbol($1,VAR|PAR|GVAR));
						int reg=take_reg();
						gen_mov(index,reg);
						//printf("TIP increment-a %d",index);
						code("\n\t\t%s\t", ar_instructions[ADD + (get_type(index) - 1) * AROP_NUMBER]);
						gen_sym_name(index);
						code(",$1,");
						gen_sym_name(index);
						//dolazim_iz_if=0;
						$$=reg;
						set_type($$,tip1);
					
					
			} 

	|  _LPAREN rel_exp {
					lab_num++;
				  code("\n\t\t%s\t@false%d", opp_jumps[$2], lab_num);
				
        	code("\n@true%d:", lab_num);
			}
		
		 _RPAREN _UPITNIK izraz1 _DVOTACKA izraz1
			{
					if (get_type($6)!=get_type($8))
							err("invalid operands type ");
					reg=take_reg();
					gen_mov($6,reg);
					code("\n\t\tJMP \t@exit%d", lab_num);
					
					code("\n@false%d:",lab_num);
					gen_mov($8,reg);
				
					code("\n@exit%d:",lab_num);
		
					$$=reg;
			
			
		}
  ;

izraz1
	: _ID{
		  $$ = lookup_symbol($1, VAR|PAR|GVAR);
        if($$ == NO_INDEX)
          err("'%s' undeclared", $1);
	}
	| literal

literal
  : _INT_NUMBER
      { $$ = insert_literal($1, INT); }

  | _UINT_NUMBER
      { $$ = insert_literal($1, UINT); }
  ;

function_call
  : _ID 
      {
        fcall_idx = lookup_symbol($1, FUN);
        if(fcall_idx == NO_INDEX)
          err("'%s' is not a function", $1);
      }
     _LPAREN argument {
			//printf("%d brojac argumenata \n",brojac_arguments);
			broj_iskoristenih_reg=take_reg(); // dobijem prvi sledeci i ako oduzmem 1 onda dobijem broj iskoriscenih
			broj_iskoristenih_reg-=1;
			for (int i=0;i<broj_iskoristenih_reg;i++){
					code("\n\t\t\tPUSH\t");
					gen_sym_name(i);
					
			}
			while(brojac_arguments>0){
				//free_if_reg(niz_arguments[brojac_arguments]);
				//printf("URADIO PUSH  \n");
      	code("\n\t\t\tPUSH\t");
     	  gen_sym_name(niz_arguments[--brojac_arguments]);
				
			}
				brojac_arguments=0;

			}_RPAREN
      {

				if(get_atr1(fcall_idx) != $4){
          err("wrong number of args to function '%s'", get_name(fcall_idx));
				}
        if(get_atr1(fcall_idx) != $4)
          err("wrong number of arguments");
        code("\n\t\t\tCALL\t%s", get_name(fcall_idx));
        if($4 > 0)
          code("\n\t\t\tADDS\t%%15,$%d,%%15", $4 * 4);
        set_type(FUN_REG, get_type(fcall_idx));
				for(int i=broj_iskoristenih_reg-1;i>=0;i--){
					code("\n\t\t\tPOP\t");
     	  	gen_sym_name(i);
				}
        $$ = FUN_REG;
				argument_function_cnt=0;
      }
  ;



argument
  : 
    { $$ = 0; }

  |  num_exp
    { 
      if(get_atr2_parameter(fcall_idx,argument_function_cnt++) != get_type($1))
        	err("incompatible type for argument in '%s'",get_name(fcall_idx));
      free_if_reg($1);
     
			niz_arguments[brojac_arguments]=$1;
			brojac_arguments++;
      $$ = argument_function_cnt;
    }

		| argument _COMMA num_exp {
			if(get_atr2_parameter(fcall_idx,argument_function_cnt++) != get_type($3))
        err("incompatible type for argument in '%s'",
            get_name(fcall_idx));
			  free_if_reg($3);
     
				niz_arguments[brojac_arguments]=$3;
				brojac_arguments++;
				//printf("%d\n",brojac_arguments);
			
      $$ = argument_function_cnt;
		} 
  ;

if_statement
  : if_part %prec ONLY_IF
      { code("\n@exit%d:", $1); }

  | if_part _ELSE statement
      { code("\n@exit%d:", $1); }
  ;

if_part
  : _IF _LPAREN
      {
        $<i>$ = ++lab_num;
        code("\n@if%d:", lab_num);
      }
    rel_exp
      {
				//printf("VRIJEDNOST OPPJUMPS%d\n",$5);
        code("\n\t\t%s\t@false%d", opp_jumps[$4], $<i>3);
				
        code("\n@true%d:", $<i>3);
      }
    _RPAREN statement
      {
        code("\n\t\tJMP \t@exit%d", $<i>3);
        code("\n@false%d:", $<i>3);
        $$ = $<i>3;
      }
  ;

rel_exp
  : num_exp {dolazim_iz_if=1;} _RELOP num_exp
      {
        if(get_type($1) != get_type($4))
          err("invalid operands: relational operator");
        

				int tip=get_type($1);
    		
				gen_cmp($1,$4);
				//printf("TIP num_exp %d\n",get_type($1));
				$$ = $3 + (( tip- 1) * RELOP_NUMBER);
				}

  ;

increment_statement
	: _ID{
				int index=lookup_symbol($1,VAR|PAR|GVAR);
			if (!(index!=-1 &&  (get_kind(index)==VAR || get_kind(index)==PAR || get_kind(index)==GVAR))){
						err("wrong parameter %s for increment operation",$1);
						return 0;
				}
			   
        code("\n\t\t%s\t", ar_instructions[ADD + (get_type(lookup_symbol($1,VAR|PAR|GVAR)) - 1) * AROP_NUMBER]);
        gen_sym_name(index);
        code(",");
        code("$1");
        code(",");
				gen_sym_name(index);
        
				
			} _INCREMENT _SEMICOLON;

return_statement
  : _RETURN {num_of_return++;} ret_statement _SEMICOLON

  ;

	ret_statement
	: /*empty*/
	{
		if (get_type(fun_idx)!=VOID){
		warn("Non-void function must have return statement");
		}
	}
	| num_exp
		{
        if(get_type(fun_idx) != get_type($1))
        err("incompatible types in return");
				if (get_type(fun_idx)==VOID){
					err("Non void  function can not have 'return' statement ");
			}
			      gen_mov($1, FUN_REG);
        code("\n\t\tJMP \t@%s_exit", get_name(fun_idx));
    };

loop_statement
	: _LOOP _LPAREN _ID 
		{
			if (lookup_symbol($3,VAR|PAR|GVAR)==-1){
				err("Undefined variable %s",$3);
			}
			loop_id_type=get_type(lookup_symbol($3,VAR|PAR|GVAR));
			
		} 
		_COMMA literal{
		
			if (get_type(lookup_symbol($3,VAR|PAR|GVAR))!=get_type($6))
				err("Wrong data type of literal %s",get_name($6));

			reg=take_reg();
			gen_mov($6,reg);
			set_type(reg,get_type($6));
			$<i>$=reg;
				
		}
		 _COMMA literal{
			
			if (get_type(lookup_symbol($3,VAR|PAR|GVAR))!=get_type($9))
				err("Wrong data type of literal %s",get_name($9));
			int first=atoi(get_name($6));
			int second=atoi(get_name($9));
			if (first<second){
				err("Value of first literal %s must be greater than second literal %s",get_name($6),get_name($9));
			}

			
			//$<i>$ = ++lab_num;
      code("\n@if%d:",++lab_num);
			gen_cmp_loop($<i>7,$9);
			int tip=get_type($<i>7);
			if (tip==INT){
				code("\n\t\t%s\t@exit_loop%d", opp_jumps[1],lab_num);
			}else{
				code("\n\t\t%s\t@exit_loop%d", opp_jumps[7],lab_num);
			}
			$<i>$=lab_num;
			
		}
		opcioni_dio _RPAREN{code("\n@loop%d:", $<i>10);} statement{
			
			int tip=get_type($<i>7);
			if (tip==INT){
				code("\n\t\tSUBS\t");
			}else{
				code("\n\t\tSUBU\t");
			}
			gen_sym_name($<i>7);
			code(",");
			printf("%d\n",$11);
			code("$%d",$11);
			code(",");
			gen_sym_name($<i>7);
			code("\n\t\tJMP \t@if%d", $<i>10);
			{ code("\n@exit_loop%d:",$<i>10); }
		} 
	;

opcioni_dio
	: /**/{$$=1;}
	| _COMMA literal{
			if (loop_id_type!=get_type($2)){
				err("Wrong data type of literal %s",get_name($2));
			}
		$$=atoi(get_name($2));
		}

	;

branch_statement
	: _BRANCH _LSQRBRACKET _ID{
			if (lookup_symbol($3,VAR|PAR|GVAR)==NO_INDEX)
				err("Variable %s is not defined", $3);

			
		}
			
		 _SEMICOLON literal{
				if (get_type(lookup_symbol($3,VAR|PAR|GVAR))!=get_type($6)){
					err("Wrong data type of literal %s",get_name($6));
				}
				var_num++;
				gen_cmp(lookup_symbol($3,VAR|PAR|GVAR),$6);
				code("\n\t\tJEQ \t@one%d",var_num);
	
				
			}
		
		 _COMMA literal{
				if (get_type(lookup_symbol($3,VAR|PAR|GVAR))!=get_type($9)){
					err("Wrong data type of literal %s",get_name($9));
				}

				gen_cmp(lookup_symbol($3,VAR|PAR|GVAR),$9);
				code("\n\t\tJEQ \t@two%d",var_num);
			}
		 _COMMA literal{
				if (get_type(lookup_symbol($3,VAR|PAR|GVAR))!=get_type($12)){
					err("Wrong data type of literal %s",get_name($12));
				}
				gen_cmp(lookup_symbol($3,VAR|PAR|GVAR),$12);
				code("\n\t\tJEQ \t@three%d",var_num);
				code("\n\t\tJMP \t@other%d",var_num);
			}
		_RSQRBRACKET branches 
	;

branches
	: b1 b2 b3 bo {code("\n@exit_branch%d:",var_num);}
	;
b1
	:_ONE{code("\n@one%d:",var_num);} _ARROW statement {code("\n\t\tJMP \t@exit_branch%d",var_num);}
	;
b2
	:_TWO{code("\n@two%d:",var_num);} _ARROW statement {code("\n\t\tJMP \t@exit_branch%d",var_num);}
	;
b3
	:_THREE{code("\n@three%d:",var_num);} _ARROW statement {code("\n\t\tJMP \t@exit_branch%d",var_num);}
	;
bo
	:_OTHER{code("\n@other%d:",var_num);} _ARROW statement {code("\n\t\tJMP \t@exit_branch%d",var_num);}
	
	;

while_statement

	:_WHILE{
			lab_num++;
			code("\n@while%d:\t",lab_num);
			$<i>$=lab_num;
		} 
		_LPAREN rel_exp {
					code("\n\t\t%s\t@while_exit%d", opp_jumps[$4],$<i>2);
			 } 
			_RPAREN _LBRACKET statement_list _RBRACKET{
					code("\n\t\tJMP @while%d\t",$<i>2);
					code("\n@while_exit%d:",$<i>2);
			}
	;

switch_statement
	:_SWITCH _LPAREN _ID{
				if (lookup_symbol($3,VAR|PAR|GVAR)==NO_INDEX){
						err("Variable %s is not defined",$3);
				}
				tip_promjenljive_switch=get_type(lookup_symbol($3,VAR|PAR|GVAR));
				++switch_lab_num;
				code("\n\t\tJMP @SWITCH%d",switch_lab_num);
				
		}
	 _RPAREN _LBRACKET case_dijelovi{
			code("\n@SWITCH%d:",switch_lab_num);
			for (int i=0;i<brojac_case;i++){
					if(get_type(lookup_symbol($3,VAR|PAR|GVAR))==INT){
							code("\n\t\tCMPS\t");
							gen_sym_name(lookup_symbol($3,VAR|PAR|GVAR));
							code(",");
							code("$%d",niz_case[i]);
					}else{
							code("\n\t\tCMPS\t");
							gen_sym_name(lookup_symbol($3,VAR|PAR|GVAR));
							code(",");
							code("$%d",niz_case[i]);
					}
					code("\n\t\tJEQ\t@CASE%d_%d",niz_case[i],switch_lab_num);
			}
			
			
		} opcioni_default _RBRACKET {code("\n@SWITCH_EXIT%d:",switch_lab_num); brojac_case=0;}
	;

case_dijelovi
	: _CASE literal{
			if (get_type($2)!=tip_promjenljive_switch){
				err("incompatible data types in case");
			}
			code("\n@CASE%d_%d:",atoi(get_name($2)),switch_lab_num);
			niz_case[brojac_case++]=atoi(get_name($2));
		} _DVOTACKA statement_list 
	| case_dijelovi _CASE literal{
				if (get_type($3)!=tip_promjenljive_switch){
				err("incompatible data types in case");
			}
			code("\n@CASE%d_%d:",atoi(get_name($3)),switch_lab_num);
				niz_case[brojac_case++]=atoi(get_name($3));
				
		} _DVOTACKA statement_list 
	;


opcioni_default
	: /*empty*/ {code("\n\t\tJMP @SWITCH_EXIT%d",switch_lab_num);}
	| _DEFAULT {code("\n@DEFAULT%d:",switch_lab_num);} _DVOTACKA statement_list
%%

int yyerror(char *s) {
  fprintf(stderr, "\nline %d: ERROR: %s", yylineno, s);
  error_count++;
  return 0;
}

void warning(char *s) {
  fprintf(stderr, "\nline %d: WARNING: %s", yylineno, s);
  warning_count++;
}

int main() {
  int synerr;
  init_symtab();
  output = fopen("output.asm", "w+");
	initStack(&st);
  synerr = yyparse();

  clear_symtab();
  fclose(output);
  
  if(warning_count)
    printf("\n%d warning(s).\n", warning_count);

  if(error_count) {
    remove("output.asm");
    printf("\n%d error(s).\n", error_count);
  }

  if(synerr)
    return -1;  //syntax error
  else if(error_count)
    return error_count & 127; //semantic errors
  else if(warning_count)
    return (warning_count & 127) + 127; //warnings
  else
    return 0; //OK
}

