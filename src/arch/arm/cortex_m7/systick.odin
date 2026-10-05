package cortex_m7

import "embedded:mmio"

// SYST_CSR is the SysTick control and status register.
//
// It controls the SysTick counter, clock source, and exception generation,
// and provides the COUNTFLAG status bit.
//
// See PM0253, SysTick control and status register (SYST_CSR).
SYST_CSR :: uintptr(0xE000E010)

// SYST_RVR is the SysTick reload value register.
//
// The 24-bit RELOAD field specifies the value loaded into the SysTick
// counter when it starts and whenever the counter reaches zero.
//
// See PM0253, SysTick reload value register (SYST_RVR).
SYST_RVR :: uintptr(0xE000E014)

// SYST_CVR is the SysTick current value register.
//
// Reading returns the current 24-bit counter value.
// Writing any value clears the current value and COUNTFLAG.
//
// See PM0253, SysTick current value register (SYST_CVR).
SYST_CVR :: uintptr(0xE000E018)


// SysTick_Clock_Source specifies the clock used by the SysTick counter.
//
// See PM0253, SYST_CSR.CLKSOURCE.
SysTick_Clock_Source :: enum u8 {
	External  = 0,
	Processor = 1,
}

// SYST_CSR_Register represents the SysTick control and status register.
//
// ENABLE starts and stops the counter.
// TICKINT controls whether reaching zero generates a SysTick exception.
// CLKSOURCE selects the clock used by the counter.
// COUNTFLAG indicates whether the counter has reached zero since the flag
// was last read.
//
// See PM0253, SYST_CSR.
SYST_CSR_Register :: bit_field u32 {
	ENABLE:    bool                 | 1,
	TICKINT:   bool                 | 1,
	CLKSOURCE: SysTick_Clock_Source | 1,
	_:         u16                  | 13,
	COUNTFLAG: bool                 | 1,
	_:         u16                  | 15,
}

// SYST_RVR_Register represents the SysTick reload value register.
//
// RELOAD is a 24-bit value loaded into the counter when SysTick starts
// and whenever the counter reaches zero.
//
// See PM0253, SYST_RVR.
SYST_RVR_Register :: bit_field u32 {
	RELOAD: u32 | 24,
	_:      u8  | 8,
}

// SYST_CVR_Register represents the SysTick current value register.
//
// CURRENT contains the current 24-bit counter value.
//
// Writing any value to SYST_CVR clears CURRENT and also clears COUNTFLAG.
//
// See PM0253, SYST_CVR.
SYST_CVR_Register :: bit_field u32 {
	CURRENT: u32 | 24,
	_:       u8  | 8,
}


// read_syst_csr reads the current value of SYST_CSR.
read_syst_csr :: proc "contextless" () -> SYST_CSR_Register {
	raw := mmio.read_u32(SYST_CSR)
	return transmute(SYST_CSR_Register)raw
}

// write_syst_csr writes value to SYST_CSR.
write_syst_csr :: proc "contextless" (reg: SYST_CSR_Register) {
	mmio.write_u32(SYST_CSR, transmute(u32)reg)
}

// read_syst_rvr reads the current value of SYST_RVR.
read_syst_rvr :: proc "contextless" () -> SYST_RVR_Register {
	raw := mmio.read_u32(SYST_RVR)
	return transmute(SYST_RVR_Register)raw
}

// write_syst_rvr writes value to SYST_RVR.
write_syst_rvr :: proc "contextless" (reg: SYST_RVR_Register) {
	mmio.write_u32(SYST_RVR, transmute(u32)reg)
}

// read_syst_cvr reads the current SysTick counter value.
read_syst_cvr :: proc "contextless" () -> SYST_CVR_Register {
	raw := mmio.read_u32(SYST_CVR)
	return transmute(SYST_CVR_Register)raw
}

// clear_syst_cvr clears the current SysTick counter value.
//
// Writing any value to SYST_CVR clears CURRENT to zero and also clears
// SYST_CSR.COUNTFLAG.
clear_syst_cvr :: proc "contextless" () {
	mmio.write_u32(SYST_CVR, 0)
}
