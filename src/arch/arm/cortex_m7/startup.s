
.syntax unified
.cpu cortex-m7
.thumb

.section .isr_vector, "a", %progbits
.global vector_table
.type vector_table, %object

vector_table:
    .word _estack
    .word Reset_Handler
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word SysTick_Handler

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

.section .note.GNU-stack, "", %progbits
