
package fault_tests

import "core:testing"
import "embedded:arch/arm/cortex_m7"

// Verify that Exception_Frame matches the basic Cortex-M7
// hardware-defined exception stack frame.
@(test)
test_exception_frame_layout :: proc(t: ^testing.T) {
    testing.expect_value(
        t,
        size_of(cortex_m7.Exception_Frame),
        32,
    )

    testing.expect_value(
        t,
        offset_of(cortex_m7.Exception_Frame, lr),
        20,
    )

    testing.expect_value(
        t,
        offset_of(cortex_m7.Exception_Frame, pc),
        24,
    )

    testing.expect_value(
        t,
        offset_of(cortex_m7.Exception_Frame, xpsr),
        28,
    )
}

// Verify that Fault_Info has a stable memory layout for
// debugger inspection and future ode debugging tools.
@(test)
test_fault_info_layout :: proc(t: ^testing.T) {
    testing.expect_value(
        t,
        size_of(cortex_m7.Fault_Info),
        16,
    )

    testing.expect_value(
        t,
        offset_of(cortex_m7.Fault_Info, pc),
        0,
    )

    testing.expect_value(
        t,
        offset_of(cortex_m7.Fault_Info, lr),
        4,
    )

    testing.expect_value(
        t,
        offset_of(cortex_m7.Fault_Info, hfsr),
        8,
    )

    testing.expect_value(
        t,
        offset_of(cortex_m7.Fault_Info, cfsr),
        12,
    )
}
