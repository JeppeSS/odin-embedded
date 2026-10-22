
package stm32f756_tests

import "core:testing"
import "embedded:mcu/stm32f756"

// Verify USART enable and transmitter enable bit positions.
@(test)
test_usart_cr1_layout :: proc(t: ^testing.T) {
    reg := stm32f756.USART_CR1_Register{}
    reg.UE = true
    reg.TE = true

    testing.expect_value(t, transmute(u32)reg, u32(0x0000_0009))
}

// Verify TXE occupies bit 7 in the status register.
@(test)
test_usart_isr_txe_layout :: proc(t: ^testing.T) {
    reg := stm32f756.USART_ISR_Register{}
    reg.TXE = true

    testing.expect_value(t, transmute(u32)reg, u32(0x0000_0080))
}

// Verify baud-rate calculation at a 16 MHz peripheral clock.
@(test)
test_usart_brr_115200 :: proc(t: ^testing.T) {
    brr := stm32f756.usart_brr_value(16_000_000, 115_200)

    testing.expect_value(t, brr, u32(139))
}

// Reject an invalid baud rate.
@(test)
test_usart_brr_zero_baud :: proc(t: ^testing.T) {
    brr := stm32f756.usart_brr_value(16_000_000, 0)

    testing.expect_value(t, brr, u32(0))
}

// Verify USART3 clock enable bit position.
@(test)
test_usart3_clock_enable_bit :: proc(t: ^testing.T) {
    reg := stm32f756.RCC_APB1ENR_Register{}
    reg.USART3EN = true

    testing.expect_value(t, transmute(u32)reg, u32(0x0004_0000))
}
