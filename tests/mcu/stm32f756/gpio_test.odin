
package stm32f756_tests

import "core:testing"
import "embedded:mcu/stm32f756"

// Verify that GPIO pin 0 uses bits 0-1 in MODER.
@(test)
test_moder_output_pin_0 :: proc(t: ^testing.T) {
    reg := stm32f756.GPIO_MODER_Register{}
    reg.MODER0 = .Output

    testing.expect_value(t, transmute(u32)reg, u32(0x0000_0001))
}

// Verify that GPIO pin 3 uses bits 6-7 in MODER.
@(test)
test_moder_alternate_pin_3 :: proc(t: ^testing.T) {
    reg := stm32f756.GPIO_MODER_Register{}
    reg.MODER3 = .Alternate

    testing.expect_value(t, transmute(u32)reg, u32(0x0000_0080))
}

// Verify that setting GPIO pin 0 uses bit 0 in BSRR.
@(test)
test_bsrr_set_pin_0 :: proc(t: ^testing.T) {
    reg := stm32f756.GPIO_BSRR_Register{}
    reg.BS0 = true

    testing.expect_value(t, transmute(u32)reg, u32(0x0000_0001))
}

// Verify that resetting GPIO pin 0 uses bit 16 in BSRR.
@(test)
test_bsrr_reset_pin_0 :: proc(t: ^testing.T) {
    reg := stm32f756.GPIO_BSRR_Register{}
    reg.BR0 = true

    testing.expect_value(t, transmute(u32)reg, u32(0x0001_0000))
}

// Verify GPIOB and GPIOD clock enable bit positions in RCC_AHB1ENR.
@(test)
test_gpio_clock_enable_bits :: proc(t: ^testing.T) {
    reg := stm32f756.RCC_AHB1ENR_Register{}

    reg.GPIOBEN = true
    testing.expect_value(t, transmute(u32)reg, u32(0x0000_0002))

    reg.GPIOBEN = false
    reg.GPIODEN = true
    testing.expect_value(t, transmute(u32)reg, u32(0x0000_0008))
}

// Verify alternate function field positions for GPIO pins 0 and 1.
@(test)
test_gpio_afrl_layout :: proc(t: ^testing.T) {
    reg := stm32f756.GPIO_AFRL_Register{}

    // Pin 0 occupies bits 0-3.
    reg.AFR0 = .AF7
    testing.expect_value(t, transmute(u32)reg, u32(0x0000_0007))

    // Pin 1 occupies bits 4-7.
    reg.AFR1 = .AF7
    testing.expect_value(t, transmute(u32)reg, u32(0x0000_0077))
}

// Verify alternate function field positions for GPIO pins 8 and 9.
@(test)
test_gpio_afrh_layout :: proc(t: ^testing.T) {
    reg := stm32f756.GPIO_AFRH_Register{}

    // Pin 8 occupies bits 0-3.
    reg.AFR8 = .AF7
    testing.expect_value(t, transmute(u32)reg, u32(0x0000_0007))

    // Pin 9 occupies bits 4-7.
    reg.AFR9 = .AF7
    testing.expect_value(t, transmute(u32)reg, u32(0x0000_0077))
}

// Verify that GPIO pin 8 uses bit 8 in OTYPER.
@(test)
test_gpio_otyper_layout :: proc(t: ^testing.T) {
    reg := stm32f756.GPIO_OTYPER_Register{}
    reg.OT8 = .Open_Drain

    testing.expect_value(t, transmute(u32)reg, u32(0x0000_0100))
}

// Verify that pin 8 occupies bits 16-17 in OSPEEDR.
@(test)
test_gpio_ospeedr_layout :: proc(t: ^testing.T) {
    reg := stm32f756.GPIO_OSPEEDR_Register{}

    reg.OSPEEDR8 = .Medium

    testing.expect_value(
        t,
        transmute(u32)reg,
        u32(0x0001_0000),
    )
}

// Verify that pin 9 occupies bits 18-19 in PUPDR.
@(test)
test_gpio_pupdr_layout :: proc(t: ^testing.T) {
    reg := stm32f756.GPIO_PUPDR_Register{}

    reg.PUPDR9 = .Pull_Up

    testing.expect_value(
        t,
        transmute(u32)reg,
        u32(0x0004_0000),
    )
}
