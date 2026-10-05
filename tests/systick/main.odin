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
