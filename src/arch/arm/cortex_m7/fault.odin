
package cortex_m7

import "base:intrinsics"
import "embedded:mmio"

// System Control Block (SCB) fault status registers.
// See ARM Cortex-M7 Generic User Guide (PM0253).
//
// HFSR reports HardFault-specific conditions.
// CFSR contains the MemManage, BusFault, and UsageFault status bits.
SCB_HFSR :: uintptr(0xE000_ED2C)
SCB_CFSR :: uintptr(0xE000_ED28)

// Exception_Frame represents the basic Cortex-M7 exception stack frame.
//
// On exception entry, the processor automatically saves these registers
// on the active stack. The saved PC identifies the interrupted instruction
// location and can help locate the cause of a fault.
//
// The field order must match the hardware-defined stack layout.
//
// This structure assumes a valid basic exception frame. Extended FPU
// frames and faults occurring during exception stacking require
// additional handling.
Exception_Frame :: struct {
    r0:   u32,
    r1:   u32,
    r2:   u32,
    r3:   u32,
    r12:  u32,
    lr:   u32,
    pc:   u32,
    xpsr: u32,
}

// Fault_Info contains diagnostic information captured during a HardFault.
//
// pc   - Program counter saved on exception entry.
// lr   - Link register saved on exception entry.
// hfsr - HardFault Status Register.
// cfsr - Configurable Fault Status Register.
//
// HFSR and CFSR can be used together to identify the fault category,
// while PC can be used to locate the relevant instruction in the firmware.
Fault_Info :: struct {
    pc:   u32,
    lr:   u32,
    hfsr: u32,
    cfsr: u32,
}

// Last captured HardFault information.
//
// Stored in RAM so a debugger can inspect the values after a fault.
// The structure is zero-initialized during startup as part of .bss.
fault_info: Fault_Info

// hardfault_capture records diagnostic information from a HardFault.
//
// Called by the assembly HardFault_Handler, which selects the stack
// used before exception entry (MSP or PSP) using EXC_RETURN bit 2.
//
// The selected stack pointer is passed in R0 according to the ARM
// procedure calling convention.
//
// The handler copies the saved PC and LR, reads the SCB fault status
// registers, and stores the resulting Fault_Info in RAM.
//
//
// Limitations:
// - Assumes a valid basic exception stack frame.
// - Does not handle extended FPU exception frames.
// - Does not recover from stack corruption or stacking faults.
// - Does not attempt to clear fault status or resume execution.
@(export)
hardfault_capture :: proc "c" (frame: ^Exception_Frame) {
    info := Fault_Info{
        pc   = frame.pc,
        lr   = frame.lr,
        hfsr = mmio.read_u32(SCB_HFSR),
        cfsr = mmio.read_u32(SCB_CFSR),
    }

    intrinsics.volatile_store(&fault_info, info)

    // Remain in the fault handler until the processor is reset.
    for {}
}
