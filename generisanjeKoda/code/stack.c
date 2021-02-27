#include "stack.h"


void initStack(incrementStack *st){
	st->top=-1;
}
void push(int id,incrementStack *st){
	if (st->top==99){
		return; //stack overflow
	}else{
		st->niz[++st->top]=id;
	}
}

int pop(incrementStack *st){
	if (st->top==-1){
		return -1;
	}else{
		return st->niz[st->top--];
	}
}

int isEmpty(incrementStack *st){
	if (st->top==-1){
		return 1;
	}else{
		return 0;
	}
}
