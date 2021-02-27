
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
		SUBS	%15,$12,%15
@main_body:
		MOV 	$3,-4(%14)
		CMPS 	-4(%14),$1
		JEQ 	@one4
		JMP 	@other4
		CMPS 	-4(%14),$3
		JEQ 	@two4
		JMP 	@other4
		CMPS 	-4(%14),$5
		JEQ 	@three4
		JMP 	@other4
@one4:
		ADDS	-4(%14),$1,%0
		MOV 	%0,-4(%14)
		JMP 	@exit_branch4
@two4:
		ADDS	-4(%14),$3,%0
		MOV 	%0,-4(%14)
		JMP 	@exit_branch4
@three4:
		ADDS	-4(%14),$5,%0
		MOV 	%0,-4(%14)
		JMP 	@exit_branch4
@other4:
		SUBS	-4(%14),$3,%0
		MOV 	%0,-4(%14)
		JMP 	@exit_branch4
@exit_branch4:
		MOV 	-4(%14),%13
		JMP 	@main_exit
@main_exit:
		MOV 	%14,%15
		POP 	%14
		RET