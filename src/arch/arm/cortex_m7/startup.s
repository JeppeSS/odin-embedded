.syntax unified
.cpu cortex-m7
.thumb

.section .isr_vector, "a", %progbits
.global vector_table
.type vector_table, %object

vector_table:
    .word _estack
    .word Reset_Handler

.size vector_table, . - vector_table


.section .text.Reset_Handler, "ax", %progbits
.global Reset_Handler
.type Reset_Handler, %function
.thumb_func

Reset_Handler:
    bl embedded_main

1:
    b 1b

.size Reset_Handler, . - Reset_Handler

.section .note.GNU-stack, "", %progbits
