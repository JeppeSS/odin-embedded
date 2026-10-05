package gpio_tests

import "core:testing"
import stm32f756 "../../src/mcu/stm32f756"

@(test)
test_moder_output_pin_0 :: proc(t: ^testing.T) {
	reg := stm32f756.GPIO_MODER_Register{}
	reg.MODER0 = .Output

	raw := transmute(u32)reg

	testing.expect_value(t, raw, u32(0x00000001))
}

@(test)
test_moder_alternate_pin_3 :: proc(t: ^testing.T) {
	reg := stm32f756.GPIO_MODER_Register{}
	reg.MODER3 = .Alternate

	raw := transmute(u32)reg

	testing.expect_value(t, raw, u32(0x00000080))
}

@(test)
test_bsrr_set_pin_0 :: proc(t: ^testing.T) {
	reg := stm32f756.GPIO_BSRR_Register{}
	reg.BS0 = true

	raw := transmute(u32)reg

	testing.expect_value(t, raw, u32(0x00000001))
}

@(test)
test_bsrr_reset_pin_0 :: proc(t: ^testing.T) {
	reg := stm32f756.GPIO_BSRR_Register{}
	reg.BR0 = true

	raw := transmute(u32)reg

	testing.expect_value(t, raw, u32(0x00010000))
}
