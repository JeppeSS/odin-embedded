package systick_tests

import "core:testing"
import "embedded:arch/arm/cortex_m7"

@(test)
test_processor_clock_source :: proc(t: ^testing.T) {
	reg := cortex_m7.SYST_CSR_Register{}
	reg.CLKSOURCE = .Processor

	raw := transmute(u32)reg

	testing.expect_value(t, raw, u32(0x00000004))
}

@(test)
test_enabled_with_processor_clock :: proc(t: ^testing.T) {
	reg := cortex_m7.SYST_CSR_Register{}
	reg.CLKSOURCE = .Processor
	reg.ENABLE = true

	raw := transmute(u32)reg

	testing.expect_value(t, raw, u32(0x00000005))
}

@(test)
test_reload_value :: proc(t: ^testing.T) {
	reg := cortex_m7.SYST_RVR_Register{}
	reg.RELOAD = 99999

	raw := transmute(u32)reg

	testing.expect_value(t, raw, u32(99999))
}

@(test)
test_reload_for_16_mhz_1_khz :: proc(t: ^testing.T) {
	reload, ok := cortex_m7.calculate_systick_reload(16_000_000, 1_000)

	testing.expect_value(t, ok, true)
	testing.expect_value(t, reload, u32(15_999))
}

@(test)
test_reload_for_100_mhz_1_khz :: proc(t: ^testing.T) {
	reload, ok := cortex_m7.calculate_systick_reload(100_000_000, 1_000)

	testing.expect_value(t, ok, true)
	testing.expect_value(t, reload, u32(99_999))
}

@(test)
test_zero_tick_frequency_is_invalid :: proc(t: ^testing.T) {
	_, ok := cortex_m7.calculate_systick_reload(16_000_000, 0)

	testing.expect_value(t, ok, false)
}

@(test)
test_tick_frequency_above_processor_frequency_is_invalid :: proc(t: ^testing.T) {
	_, ok := cortex_m7.calculate_systick_reload(1_000, 2_000)

	testing.expect_value(t, ok, false)
}

@(test)
test_reload_larger_than_24_bits_is_invalid :: proc(t: ^testing.T) {
	_, ok := cortex_m7.calculate_systick_reload(200_000_000, 1)

	testing.expect_value(t, ok, false)
}
