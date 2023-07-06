	.file	"main.c"
	.text
	.globl	main
	.type	main, @function
main:
	pushl	%ebp
	movl	%esp, %ebp
.L2:
	jmp	.L2
	.size	main, .-main
	.ident	"GCC: (GNU) 13.1.0"
