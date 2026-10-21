
package fault_tests

import "core:testing"
import "embedded:arch/arm/cortex_m7"

// Verify that Exception_Frame matches the basic Cortex-M7
// hardware-defined exception stack frame.
@(test)
test_exception_frame_layout :: proc(t: ^testing.T) {
    testing.expect_value(t, size_of(cortex_m7.Exception_Frame), 32)

    testing.expect_value(t, offset_of(cortex_m7.Exception_Frame, lr), 20)
    testing.expect_value(t, offset_of(cortex_m7.Exception_Frame, pc), 24)
    testing.expect_value(t, offset_of(cortex_m7.Exception_Frame, xpsr), 28)
}

// Verify that Fault_Info has a stable memory layout for
// debugger inspection and future ode debugging tools.
@(test)
test_fault_info_layout :: proc(t: ^testing.T) {
    testing.expect_value(t, size_of(cortex_m7.Fault_Info), 24)

    testing.expect_value(t, offset_of(cortex_m7.Fault_Info, pc), 0)
    testing.expect_value(t, offset_of(cortex_m7.Fault_Info, lr), 4)
    testing.expect_value(t, offset_of(cortex_m7.Fault_Info, hfsr), 8)
    testing.expect_value(t, offset_of(cortex_m7.Fault_Info, cfsr), 12)
    testing.expect_value(t, offset_of(cortex_m7.Fault_Info, mmfar), 16)
    testing.expect_value(t, offset_of(cortex_m7.Fault_Info, bfar), 20)
}

// Verify the size and bit positions of the HardFault Status Register.
@(test)
test_hfsr_layout :: proc(t: ^testing.T) {
    testing.expect_value(t, size_of(cortex_m7.SCB_HFSR_Register), 4)

    // Test each defined status flag independently.
    vecttbl := transmute(cortex_m7.SCB_HFSR_Register)u32(0x0000_0002)
    testing.expect_value(t, vecttbl.VECTTBL, u8(1))
    testing.expect_value(t, vecttbl.FORCED, u8(0))
    testing.expect_value(t, vecttbl.DEBUGEVT, u8(0))

    forced := transmute(cortex_m7.SCB_HFSR_Register)u32(0x4000_0000)
    testing.expect_value(t, forced.VECTTBL, u8(0))
    testing.expect_value(t, forced.FORCED, u8(1))
    testing.expect_value(t, forced.DEBUGEVT, u8(0))

    debugevt := transmute(cortex_m7.SCB_HFSR_Register)u32(0x8000_0000)
    testing.expect_value(t, debugevt.VECTTBL, u8(0))
    testing.expect_value(t, debugevt.FORCED, u8(0))
    testing.expect_value(t, debugevt.DEBUGEVT, u8(1))
}

// Verify the CFSR register size and the UsageFault
// status captured during our undefined-instruction test.
@(test)
test_cfsr_undefined_instruction :: proc(t: ^testing.T) {
    testing.expect_value(t, size_of(cortex_m7.SCB_CFSR_Register), 4)

    // CFSR.UNDEFINSTR is bit 16.
    cfsr := transmute(cortex_m7.SCB_CFSR_Register)u32(0x0001_0000)

    testing.expect_value(t, cfsr.UNDEFINSTR, u8(1))
    testing.expect_value(t, cfsr.INVSTATE, u8(0))
    testing.expect_value(t, cfsr.DIVBYZERO, u8(0))
}

// Verify that MMFSR, BFSR, and UFSR occupy
// their documented bit positions.
@(test)
test_cfsr_fault_groups :: proc(t: ^testing.T) {
    // IACCVIOL (bit 0), PRECISERR (bit 9),
    // and DIVBYZERO (bit 25).
    cfsr := transmute(cortex_m7.SCB_CFSR_Register)u32(0x0200_0201)

    testing.expect_value(t, cfsr.IACCVIOL, u8(1))
    testing.expect_value(t, cfsr.PRECISERR, u8(1))
    testing.expect_value(t, cfsr.DIVBYZERO, u8(1))

    testing.expect_value(t, cfsr.DACCVIOL, u8(0))
    testing.expect_value(t, cfsr.IBUSERR, u8(0))
    testing.expect_value(t, cfsr.UNDEFINSTR, u8(0))
}

// Verify the fault address validity flags at the
// boundaries of the MMFSR and BFSR status groups.
@(test)
test_cfsr_address_validity_flags :: proc(t: ^testing.T) {
    // MMARVALID (bit 7) and BFARVALID (bit 15).
    cfsr := transmute(cortex_m7.SCB_CFSR_Register)u32(0x0000_8080)

    testing.expect_value(t, cfsr.MMARVALID, u8(1))
    testing.expect_value(t, cfsr.BFARVALID, u8(1))

    testing.expect_value(t, cfsr.IACCVIOL, u8(0))
    testing.expect_value(t, cfsr.IBUSERR, u8(0))
}
