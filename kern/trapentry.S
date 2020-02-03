/* See COPYRIGHT for copyright information. */

#include <inc/mmu.h>
#include <inc/memlayout.h>
#include <inc/trap.h>



###################################################################
# exceptions/interrupts
###################################################################

/* TRAPHANDLER defines a globally-visible function for handling a trap.
 * It pushes a trap number onto the stack, then jumps to _alltraps.
 * Use TRAPHANDLER for traps where the CPU automatically pushes an error code.
 *
 * You shouldn't call a TRAPHANDLER function from C, but you may
 * need to _declare_ one in C (for instance, to get a function pointer
 * during IDT setup).  You can declare the function with
 *   void NAME();
 * where NAME is the argument passed to TRAPHANDLER.
 */
#define TRAPHANDLER(name, num)						\
	.globl name;		/* define global symbol for 'name' */	\
	.type name, @function;	/* symbol type is function */		\
	.align 2;		/* align function definition */		\
	name:			/* function starts here */		\
	pushl $(num);							\
	jmp _alltraps

/* Use TRAPHANDLER_NOEC for traps where the CPU doesn't push an error code.
 * It pushes a 0 in place of the error code, so the trap frame has the same
 * format in either case.
 */
#define TRAPHANDLER_NOEC(name, num)					\
	.globl name;							\
	.type name, @function;						\
	.align 2;							\
	name:								\
	pushl $0;							\
	pushl $(num);							\
	jmp _alltraps


#define	NOEC(name, num) 		\
	.data 						;\
		.long name				;\
	.text						;\
		.global name			;\
		.type name, @function	;\
name:							\
		pushl $0;				\
		pushl $(num);			\
		jmp _alltraps

#define	EC(name, num) 		\
	.data 						;\
		.long name				;\
	.text						;\
		.global name			;\
		.type name, @function	;\
name:							\
		pushl $(num);			\
		jmp _alltraps

# this name dedicated to clann24
#define ZHANWEI()			\
	.data					;\
		.long 0				;

# check intel x86 manual to see whether have error code

.data
		.align 2				;
		.global funs			;
funs:
		NOEC(t0_entry, T_DIVIDE)
		NOEC(t1_entry, T_DEBUG)
		NOEC(t2_entry, T_NMI)
		NOEC(t3_entry, T_BRKPT)
		NOEC(t4_entry, T_OFLOW)
		NOEC(t5_entry, T_BOUND)
		NOEC(t6_entry, T_ILLOP)
		NOEC(t7_entry, T_DEVICE)
		EC(t8_entry, T_DBLFLT)
		ZHANWEI()
		# 9 skipped
		EC(t10_entry, T_TSS)
		EC(t11_entry, T_SEGNP)
		EC(t12_entry, T_STACK)
		EC(t13_entry, T_GPFLT)
		EC(t14_entry, T_PGFLT)
		# 15 skipped
		ZHANWEI()
		NOEC(t16_entry, T_FPERR)
		NOEC(t17_entry, T_ALIGN)
		NOEC(t18_entry, T_MCHK)
		NOEC(t19_entry, T_SIMDERR)

		NOEC(t48_entry, T_SYSCALL)

.text

/*
 * Lab 3: Your code here for generating entry points for the different traps.
 */

.set KD_SEG, 0x10        	# kernel data segment selector

/*
 * Lab 3: Your code here for _alltraps
 */
_alltraps:
		pushl %ds				;
		pushl %es				;
		pushal					;
		# ax corrupted?
		movw $KD_SEG, %ax		;
		movw %ax, %ds			;
		movw %ax, %es			;

		# parameter *Trapframe
		pushl %esp				;
		call trap				;
