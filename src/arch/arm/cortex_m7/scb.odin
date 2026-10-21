
package cortex_m7

import "embedded:mmio"

// System Control Block (SCB) fault status registers.
//
// The SCB provides information about processor exceptions and faults.
// These registers are part of the Cortex-M7 System Control Space.
//
// Fault status flags are sticky: once set, they remain set until
// explicitly cleared by software or reset.
//
// Most fault status flags use write-one-to-clear semantics.
// Writing 1 clears the corresponding flag, while writing 0 leaves it
// unchanged. Consequently, ordinary read-modify-write operations
// should not be used to clear these flags.
//
// Only read access is provided for now.
//
// Reference: ARM Cortex-M7 Generic User Guide, PM0253.

SCB_CFSR_ADDRESS  :: uintptr(0xE000_ED28)
SCB_HFSR_ADDRESS  :: uintptr(0xE000_ED2C)
SCB_MMFAR_ADDRESS :: uintptr(0xE000_ED34)
SCB_BFAR_ADDRESS  :: uintptr(0xE000_ED38)

// HardFault Status Register (HFSR).
//
// Reports conditions that caused or contributed to a HardFault.
//
// VECTTBL:
//   A bus fault occurred during a vector table read.
//
// FORCED:
//   A configurable fault escalated to HardFault.
//   The CFSR register should be inspected to determine the cause.
//
// DEBUGEVT:
//   A debug-related event caused a HardFault.
//
// Reserved bits are included to preserve the hardware-defined layout.
SCB_HFSR_Register :: bit_field u32 {
    _reserved0: u8  | 1,  // Bit 0
    VECTTBL:    u8  | 1,  // Bit 1
    _reserved1: u32 | 28, // Bits 2-29
    FORCED:     u8  | 1,  // Bit 30
    DEBUGEVT:   u8  | 1,  // Bit 31
}

// Configurable Fault Status Register (CFSR).
//
// Contains status flags for three configurable fault exceptions:
//
// MMFSR (bits 0-7):
//   Memory Management Fault Status Register.
//
// BFSR (bits 8-15):
//   BusFault Status Register.
//
// UFSR (bits 16-31):
//   UsageFault Status Register.
//
// Multiple flags may be set simultaneously. A HardFault caused by
// escalation can therefore require inspection of several CFSR bits.
//
// Some flags indicate that an associated fault address register
// contains a valid address:
//
// MMARVALID - MMFAR contains a valid memory management fault address.
// BFARVALID - BFAR contains a valid bus fault address.
//
// These flags must be checked before interpreting MMFAR or BFAR.
//
// Reserved fields preserve the hardware-defined bit positions.
SCB_CFSR_Register :: bit_field u32 {
    // Memory Management Fault Status Register (MMFSR).

    IACCVIOL:    u8 | 1, // Bit 0: Instruction access violation.
    DACCVIOL:    u8 | 1, // Bit 1: Data access violation.
    _reserved0:  u8 | 1, // Bit 2.
    MUNSTKERR:   u8 | 1, // Bit 3: Fault during exception unstacking.
    MSTKERR:     u8 | 1, // Bit 4: Fault during exception stacking.
    MLSPERR:     u8 | 1, // Bit 5: Fault during lazy FP state preservation.
    _reserved1:  u8 | 1, // Bit 6.
    MMARVALID:   u8 | 1, // Bit 7: MMFAR contains a valid fault address.

    // BusFault Status Register (BFSR).

    IBUSERR:     u8 | 1, // Bit 8: Instruction bus error.
    PRECISERR:   u8 | 1, // Bit 9: Precise data bus error.
    IMPRECISERR: u8 | 1, // Bit 10: Imprecise data bus error.
    UNSTKERR:    u8 | 1, // Bit 11: Bus fault during exception unstacking.
    STKERR:      u8 | 1, // Bit 12: Bus fault during exception stacking.
    LSPERR:      u8 | 1, // Bit 13: Fault during lazy FP state preservation.
    _reserved2:  u8 | 1, // Bit 14.
    BFARVALID:   u8 | 1, // Bit 15: BFAR contains a valid fault address.

    // UsageFault Status Register (UFSR).

    UNDEFINSTR:  u8 | 1, // Bit 16: Undefined instruction executed.
    INVSTATE:    u8 | 1, // Bit 17: Invalid processor state.
    INVPC:       u8 | 1, // Bit 18: Invalid exception return.
    NOCP:        u8 | 1, // Bit 19: Coprocessor access violation.
    _reserved3:  u8 | 4, // Bits 20-23.
    UNALIGNED:   u8 | 1, // Bit 24: Unaligned memory access.
    DIVBYZERO:   u8 | 1, // Bit 25: Division by zero.
    _reserved4:  u8 | 6, // Bits 26-31.
}

// read_scb_hfsr reads the current HardFault Status Register.
//
// The returned bitfield allows individual status flags to be inspected
// without manually applying bit masks.
//
// Reading HFSR does not clear any status flags.
read_scb_hfsr :: proc "contextless" () -> SCB_HFSR_Register {
    raw := mmio.read_u32(SCB_HFSR_ADDRESS)
    return transmute(SCB_HFSR_Register)raw
}

// read_scb_cfsr reads the current Configurable Fault Status Register.
//
// The returned bitfield exposes MemManage, BusFault, and UsageFault
// status flags through named fields.
//
// Reading CFSR does not clear any status flags.
read_scb_cfsr :: proc "contextless" () -> SCB_CFSR_Register {
    raw := mmio.read_u32(SCB_CFSR_ADDRESS)
    return transmute(SCB_CFSR_Register)raw
}

// read_scb_mmfar reads the MemManage Fault Address Register.
//
// The returned address is only meaningful when CFSR.MMARVALID
// is set. Not every memory management fault records an address.
read_scb_mmfar :: proc "contextless" () -> u32 {
    return mmio.read_u32(SCB_MMFAR_ADDRESS)
}

// read_scb_bfar reads the BusFault Address Register.
//
// The returned address is only meaningful when CFSR.BFARVALID
// is set. In particular, imprecise bus faults may not provide
// a valid fault address.
read_scb_bfar :: proc "contextless" () -> u32 {
    return mmio.read_u32(SCB_BFAR_ADDRESS)
}
