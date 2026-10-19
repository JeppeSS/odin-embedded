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
    ldr r0, =_sbss
    ldr r1, =_ebss
    movs r2, #0

1:
    cmp r0, r1
    bhs 2f

    str r2, [r0], #4
    b 1b

2:
    bl embedded_main

3:
    b 3b

.size Reset_Handler, . - Reset_Handler

.section .note.GNU-stack, "", %progbits
