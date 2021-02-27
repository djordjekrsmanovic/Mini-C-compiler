
main:
		PUSH	%14
		MOV 	%15,%14
		SUBS	%15,$8,%15
@main_body:
		MOV 	$1,-4(%14)
		MOV 	$0,-8(%14)
		JMP @SWITCH0
@CASE1:
		MOV 	$5,-4(%14)
		JMP @SWITCH_EXIT0
@CASE2:
		MOV 	$4,-8(%14)
		JMP @SWITCH_EXIT0
@CASE3:
		MOV 	$7,-4(%14)
		JMP @SWITCH_EXIT0
@SWITCH0:
		CMPS	-4(%14),%1
		JEQ	@CASE1
		CMPS	-4(%14),%2
		JEQ	@CASE2
		CMPS	-4(%14),%3
		JEQ	@CASE3
		JMP @DEFAULT0
@DEFAULT0:
		MOV 	$1,-4(%14)
		ADDS	-8(%14),$5,%0
		MOV 	%0,-8(%14)
@SWITCH_EXIT0:
		MOV 	-4(%14),%13
		JMP 	@main_exit
@main_exit:
		MOV 	%14,%15
		POP 	%14
		RET