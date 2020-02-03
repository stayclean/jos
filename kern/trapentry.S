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

.text

/*
 * Lab 3: Your code here for generating entry points for the different traps.
 */
		# check intel x86 manual to see whether have error code
		TRAPHANDLER_NOEC(t0_entry, T_DIVIDE) ;
		TRAPHANDLER_NOEC(t1_entry, T_DEBUG) ;
		TRAPHANDLER_NOEC(t2_entry, T_NMI) ;
		TRAPHANDLER_NOEC(t3_entry, T_BRKPT) ;
		TRAPHANDLER_NOEC(t4_entry, T_OFLOW) ;
		TRAPHANDLER_NOEC(t5_entry, T_BOUND) ;
		TRAPHANDLER_NOEC(t6_entry, T_ILLOP) ;
		TRAPHANDLER_NOEC(t7_entry, T_DEVICE) ;
		TRAPHANDLER(t8_entry, T_DBLFLT) ;
		# 9 skipped
		TRAPHANDLER(t10_entry, T_TSS) ;
		TRAPHANDLER(t11_entry, T_SEGNP) ;
		TRAPHANDLER(t12_entry, T_STACK) ;
		TRAPHANDLER(t13_entry, T_GPFLT) ;
		TRAPHANDLER(t14_entry, T_PGFLT) ;
		# 15 skipped
		TRAPHANDLER_NOEC(t16_entry, T_FPERR) ;
		TRAPHANDLER_NOEC(t17_entry, T_ALIGN) ;
		TRAPHANDLER_NOEC(t18_entry, T_MCHK) ;
		TRAPHANDLER_NOEC(t19_entry, T_SIMDERR) ;

		TRAPHANDLER_NOEC(t48_entry, T_SYSCALL) ;



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
