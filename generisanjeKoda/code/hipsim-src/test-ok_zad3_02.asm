
f:
		PUSH	%14
		MOV 	%15,%14
@f_body:
		CMPS 	8(%14),$1
		JEQ 	@one1
		CMPS 	8(%14),$3
		JEQ 	@two1
		CMPS 	8(%14),$5
		JEQ 	@three1
		JMP 	@other1
@one1:
		ADDS	8(%14),$1,%0
		MOV 	%0,8(%14)
		JMP 	@exit_branch1
@two1:
		ADDS	8(%14),$3,%0
		MOV 	%0,8(%14)
		JMP 	@exit_branch1
@three1:
		ADDS	12(%14),$5,%0
		MOV 	%0,8(%14)
		JMP 	@exit_branch1
@other1:
		SUBS	12(%14),$3,%0
		MOV 	%0,8(%14)
		JMP 	@exit_branch1
@exit_branch1:
		MOV 	8(%14),%13
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
		MOV 	$5,-4(%14)
		MOV 	$6,-8(%14)
		CMPS 	-4(%14),$1
		JEQ 	@one4
		CMPS 	-4(%14),$3
		JEQ 	@two4
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
			PUSH	-8(%14)
			PUSH	-4(%14)
			CALL	f
			ADDS	%15,$8,%15
		MOV 	%13,%0
		MOV 	%0,-12(%14)
		MOV 	-12(%14),%13
		JMP 	@main_exit
@main_exit:
		MOV 	%14,%15
		POP 	%14
		RET