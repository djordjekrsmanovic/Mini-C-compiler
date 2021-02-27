
fun:
		PUSH	%14
		MOV 	%15,%14
@fun_body:
		ADDS	12(%14),12(%14),%0
		ADDS	%0,16(%14),%0
		MOV 	%0,8(%14)
		MOV 	8(%14),%13
		JMP 	@fun_exit
@fun_exit:
		MOV 	%14,%15
		POP 	%14
		RET
fun1:
		PUSH	%14
		MOV 	%15,%14
@fun1_body:
			PUSH	$0
			PUSH	$0
			PUSH	$0
			CALL	fun
			ADDS	%15,$12,%15
		MOV 	%13,%0
		ADDS	%0,8(%14),%0
		ADDS	%0,12(%14),%0
		MOV 	%0,8(%14)
		MOV 	8(%14),%13
		JMP 	@fun1_exit
@fun1_exit:
		MOV 	%14,%15
		POP 	%14
		RET
main:
		PUSH	%14
		MOV 	%15,%14
		SUBS	%15,$12,%15
@main_body:
			PUSH	$3
			PUSH	$3
			CALL	fun1
			ADDS	%15,$8,%15
		MOV 	%13,%0
			PUSH	$8
			PUSH	$3
			PUSH	$0
			CALL	fun
			ADDS	%15,$12,%15
		MOV 	%13,%1
		ADDS	%0,%1,%0
			PUSH	$5
			PUSH	$4
			CALL	fun1
			ADDS	%15,$8,%15
		MOV 	%13,%1
		ADDS	%0,%1,%0
		MOV 	%0,-4(%14)
		MOV 	-4(%14),%13
		JMP 	@main_exit
@main_exit:
		MOV 	%14,%15
		POP 	%14
		RET