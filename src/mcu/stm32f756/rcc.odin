package stm32f756

import "embedded:mmio"

// RCC_BASE is the base address of the Reset and Clock Control peripheral.
//
// See RM0385, Reset and clock control (RCC).
RCC_BASE :: uintptr(0x40023800)

// RCC_AHB1ENR is the AHB1 peripheral clock enable register.
//
// Register offset: 0x30 from RCC_BASE.
//
// See RM0385, RCC AHB1 peripheral clock enable register (RCC_AHB1ENR).
RCC_AHB1ENR :: RCC_BASE + 0x30

// RCC_AHB1ENR_Register represents the fields of the RCC AHB1 peripheral
// clock enable register.
//
// Setting a field enables the corresponding peripheral clock.
// Clearing a field disables the corresponding peripheral clock.
//
// See RM0385, RCC_AHB1ENR.
RCC_AHB1ENR_Register :: bit_field u32 {
	GPIOAEN: bool | 1,
	GPIOBEN: bool | 1,
}

// read_ahb1enr reads the current value of RCC_AHB1ENR.
read_ahb1enr :: proc "contextless" () -> RCC_AHB1ENR_Register {
	raw := mmio.read_u32(RCC_AHB1ENR)
	return transmute(RCC_AHB1ENR_Register)raw
}

// write_ahb1enr writes value to RCC_AHB1ENR.
write_ahb1enr :: proc "contextless" (reg: RCC_AHB1ENR_Register) {
	mmio.write_u32(RCC_AHB1ENR, transmute(u32)reg)
}


// enable_gpio_b_clock enables the peripheral clock for GPIO port B.
//
// The clock is enabled by setting GPIOBEN in RCC_AHB1ENR.
// The existing register value is preserved.
//
// See RM0385, RCC_AHB1ENR.
enable_gpio_b_clock :: proc "contextless" () {
	reg := read_ahb1enr()
	reg.GPIOBEN = true
	write_ahb1enr(reg)
}
