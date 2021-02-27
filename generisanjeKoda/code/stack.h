typedef struct incStack{
	int niz[100];
	int top;
}incrementStack;

void initStack(incrementStack *st);
void push(int id,incrementStack *st);
int pop(incrementStack *st);
int isEmpty(incrementStack *st);

