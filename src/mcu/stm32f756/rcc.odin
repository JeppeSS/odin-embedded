
package stm32f756

import "embedded:mmio"

// RCC_BASE is the base address of the Reset and Clock Control peripheral.
//
// RCC manages the clocks and reset signals for the STM32F756
// peripherals.
//
// See RM0385, Reset and clock control (RCC).
RCC_BASE :: uintptr(0x40023800)

// RCC_AHB1ENR is the AHB1 peripheral clock enable register.
//
// Each enable bit controls the clock supplied to an AHB1 peripheral.
//
// Register offset: 0x30 from RCC_BASE.
//
// See RM0385, RCC AHB1 peripheral clock enable register (RCC_AHB1ENR).
RCC_AHB1ENR :: RCC_BASE + 0x30

// RCC_APB1ENR is the APB1 peripheral clock enable register.
//
// Each enable bit controls the clock supplied to an APB1 peripheral.
//
// Register offset: 0x40 from RCC_BASE.
//
// See RM0385, RCC APB1 peripheral clock enable register (RCC_APB1ENR).
RCC_APB1ENR :: RCC_BASE + 0x40

// RCC_AHB1ENR_Register represents the AHB1 peripheral clock
// enable register.
//
// GPIOAEN through GPIOKEN control the clocks for GPIO ports A-K.
//
// The remaining bits are not yet modeled individually. They are
// retained in _other to preserve their values during register
// read-modify-write operations.
//
// See RM0385, RCC_AHB1ENR.
RCC_AHB1ENR_Register :: bit_field u32 {
    GPIOAEN: bool | 1, // Bit 0: GPIOA clock enable.
    GPIOBEN: bool | 1, // Bit 1: GPIOB clock enable.
    GPIOCEN: bool | 1, // Bit 2: GPIOC clock enable.
    GPIODEN: bool | 1, // Bit 3: GPIOD clock enable.
    GPIOEEN: bool | 1, // Bit 4: GPIOE clock enable.
    GPIOFEN: bool | 1, // Bit 5: GPIOF clock enable.
    GPIOGEN: bool | 1, // Bit 6: GPIOG clock enable.
    GPIOHEN: bool | 1, // Bit 7: GPIOH clock enable.
    GPIOIEN: bool | 1, // Bit 8: GPIOI clock enable.
    GPIOJEN: bool | 1, // Bit 9: GPIOJ clock enable.
    GPIOKEN: bool | 1, // Bit 10: GPIOK clock enable.

    _other: u32 | 21, // Bits 11-31: Other AHB1 fields.
}

// RCC_APB1ENR_Register represents the APB1 peripheral clock
// enable register.
//
// USART3EN controls the peripheral clock for USART3.
//
// Other fields are not yet modeled individually. Their values
// are preserved during register read-modify-write operations.
//
// See RM0385, RCC_APB1ENR.
RCC_APB1ENR_Register :: bit_field u32 {
    _lower:   u32  | 18, // Bits 0-17: Other APB1 fields.
    USART3EN: bool | 1,  // Bit 18: USART3 clock enable.
    _upper:   u32  | 13, // Bits 19-31: Other APB1 fields.
}

// read_ahb1enr reads the current AHB1 peripheral clock
// enable register.
read_ahb1enr :: proc "contextless" () -> RCC_AHB1ENR_Register {
    raw := mmio.read_u32(RCC_AHB1ENR)
    return transmute(RCC_AHB1ENR_Register)raw
}

// write_ahb1enr writes a complete value to RCC_AHB1ENR.
//
// Callers should normally read the existing register value,
// modify the required fields, and write the updated value back
// to preserve unrelated peripheral clock settings.
write_ahb1enr :: proc "contextless" (reg: RCC_AHB1ENR_Register) {
    mmio.write_u32(RCC_AHB1ENR, transmute(u32)reg)
}

// read_apb1enr reads the current APB1 peripheral clock
// enable register.
read_apb1enr :: proc "contextless" () -> RCC_APB1ENR_Register {
    raw := mmio.read_u32(RCC_APB1ENR)
    return transmute(RCC_APB1ENR_Register)raw
}

// write_apb1enr writes a complete value to RCC_APB1ENR.
//
// Callers should normally read the existing register value,
// modify the required fields, and write the updated value back
// to preserve unrelated peripheral clock settings.
write_apb1enr :: proc "contextless" (reg: RCC_APB1ENR_Register) {
    mmio.write_u32(RCC_APB1ENR, transmute(u32)reg)
}

// enable_gpio_b_clock enables the peripheral clock for GPIO port B.
//
// The existing RCC_AHB1ENR value is preserved.
//
// See RM0385, RCC_AHB1ENR.
enable_gpio_b_clock :: proc "contextless" () {
    reg := read_ahb1enr()
    reg.GPIOBEN = true
    write_ahb1enr(reg)
}

// enable_gpio_d_clock enables the peripheral clock for GPIO port D.
//
// The existing RCC_AHB1ENR value is preserved.
//
// See RM0385, RCC_AHB1ENR.
enable_gpio_d_clock :: proc "contextless" () {
    reg := read_ahb1enr()
    reg.GPIODEN = true
    write_ahb1enr(reg)
}

// enable_usart3_clock enables the peripheral clock for USART3.
//
// The existing RCC_APB1ENR value is preserved.
//
// This enables register access to USART3. The USART peripheral
// must still be configured and enabled separately.
//
// See RM0385, RCC_APB1ENR.
enable_usart3_clock :: proc "contextless" () {
    reg := read_apb1enr()
    reg.USART3EN = true
    write_apb1enr(reg)
}
