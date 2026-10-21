
package cortex_m7

import "base:intrinsics"

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
// pc    - Program counter saved on exception entry.
// lr    - Link register saved on exception entry.
// hfsr  - HardFault Status Register.
// cfsr  - Configurable Fault Status Register.
// mmfar - MemManage fault address, valid only if CFSR.MMARVALID is set.
// bfar  - BusFault address, valid only if CFSR.BFARVALID is set.
//
// Raw register values are preserved for debugger inspection.
Fault_Info :: struct {
    pc:    u32,
    lr:    u32,
    hfsr:  u32,
    cfsr:  u32,
    mmfar: u32,
    bfar:  u32,
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
    hfsr := read_scb_hfsr()
    cfsr := read_scb_cfsr()

    info := Fault_Info{
        pc   = frame.pc,
        lr   = frame.lr,
        hfsr = transmute(u32)hfsr,
        cfsr = transmute(u32)cfsr,
    }

    // Only capture fault addresses when the corresponding
    // validity flags indicate that they are meaningful.
    if cfsr.MMARVALID != 0 {
        info.mmfar = read_scb_mmfar()
    }

    if cfsr.BFARVALID != 0 {
        info.bfar = read_scb_bfar()
    }

    intrinsics.volatile_store(&fault_info, info)

    for {}
}
