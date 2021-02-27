
f:
		PUSH	%14
		MOV 	%15,%14
@f_body:
		MOV 	$1,%13
		JMP 	@f_exit
@f_exit:
		MOV 	%14,%15
		POP 	%14
		RET
main:
		PUSH	%14
		MOV 	%15,%14
		SUBS	%15,$8,%15
@main_body:
		MOV 	$1,-4(%14)
		MOV 	$1,-8(%14)
		MOV 	$30,%0
@if0:
		CMPS 	%0,$20
		JLES	@exit_loop0
@loop0:
		ADDS	-8(%14),-4(%14),%1
		MOV 	%1,-8(%14)
		SUBS	%0,$1,%0
		JMP 	@if0
@exit_loop0:
		MOV 	$10,%1
@if1:
		CMPS 	%1,$5
		JLES	@exit_loop1
@loop1:
		ADDS	-8(%14),$1,-8(%14)
		SUBS	%1,$23,%1
		JMP 	@if1
@exit_loop1:
		MOV 	-8(%14),%13
		JMP 	@main_exit
@main_exit:
		MOV 	%14,%15
		POP 	%14
		RET