
main:
		PUSH	%14
		MOV 	%15,%14
		SUBS	%15,$4,%15
@main_body:
		MOV 	$5,-4(%14)
		MOV 	$10,%0
@if0:
		CMPS 	%0,$8
		JLES	@exit_loop0
@loop0:
		MOV 	$10,%1
@if1:
		CMPS 	%1,$8
		JLES	@exit_loop1
@loop1:
		MOV 	$1,-4(%14)
		SUBS	%1,$1,%1
		JMP 	@if1
@exit_loop1:
		SUBS	%1,$1,%1
		JMP 	@if0
@exit_loop0:
		MOV 	-4(%14),%13
		JMP 	@main_exit
@main_exit:
		MOV 	%14,%15
		POP 	%14
		RET
