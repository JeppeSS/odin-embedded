
.syntax unified
.cpu cortex-m7
.thumb

.section .isr_vector, "a", %progbits
.global vector_table
.type vector_table, %object

vector_table:
    .word _estack
    .word Reset_Handler
    .word Default_Handler    /* 2  NMI */
    .word HardFault_Handler  /* 3  HardFault */
    .word Default_Handler    /* 4  MemManage */
    .word Default_Handler    /* 5  BusFault */
    .word Default_Handler    /* 6  UsageFault */
    .word 0                  /* 7  Reserved */
    .word 0                  /* 8  Reserved */
    .word 0                  /* 9  Reserved */
    .word 0                  /* 10 Reserved */
    .word Default_Handler    /* 11 SVCall */
    .word Default_Handler    /* 12 DebugMonitor */
    .word 0                  /* 13 Reserved */
    .word Default_Handler    /* 14 PendSV */
    .word SysTick_Handler    /* 15 SysTick */

.size vector_table, . - vector_table


.section .text.Reset_Handler, "ax", %progbits
.global Reset_Handler
.type Reset_Handler, %function
.thumb_func

Reset_Handler:
    /* Copy .data from Flash to DTCM */
    ldr r0, =_sidata
    ldr r1, =_sdata
    ldr r2, =_edata

1:
    cmp r1, r2
    bhs 2f

    ldr r3, [r0], #4
    str r3, [r1], #4
    b 1b

2:
    /* Zero-initialize .bss */
    ldr r0, =_sbss
    ldr r1, =_ebss
    movs r2, #0

3:
    cmp r0, r1
    bhs 4f

    str r2, [r0], #4
    b 3b

4:
    bl embedded_main

5:
    b 5b

.size Reset_Handler, . - Reset_Handler


.section .text.Default_Handler, "ax", %progbits
.global Default_Handler
.type Default_Handler, %function
.thumb_func

Default_Handler:
1:
    b 1b

.size Default_Handler, . - Default_Handler


/* Default SysTick handler.
 * Applications may provide their own implementation.
 */
.weak SysTick_Handler
.thumb_set SysTick_Handler, Default_Handler


/* Default HardFault handler.
 * Applications may override HardFault_Handler directly.
 */
.section .text.HardFault_Handler, "ax", %progbits
.weak HardFault_Handler
.type HardFault_Handler, %function
.thumb_func

HardFault_Handler:
    /* Select the stack used before the exception. */
    tst lr, #4
    ite eq
    mrseq r0, msp
    mrsne r0, psp

    /* Pass the exception stack pointer. */
    b hardfault_capture

.size HardFault_Handler, . - HardFault_Handler


/* Default hardfault_capture implementation.
 * Can be replaced by a strong implementation in Odin.
 */
.weak hardfault_capture
.thumb_set hardfault_capture, Default_Handler


.section .note.GNU-stack, "", %progbits
