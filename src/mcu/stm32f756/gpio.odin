
package stm32f756

import "embedded:mmio"

// GPIO port base addresses.
//
// All GPIO ports share the same register layout.
//
// See RM0385, General-purpose I/Os (GPIO).
GPIOA_BASE :: uintptr(0x40020000)
GPIOB_BASE :: uintptr(0x40020400)
GPIOC_BASE :: uintptr(0x40020800)
GPIOD_BASE :: uintptr(0x40020C00)
GPIOE_BASE :: uintptr(0x40021000)
GPIOF_BASE :: uintptr(0x40021400)
GPIOG_BASE :: uintptr(0x40021800)
GPIOH_BASE :: uintptr(0x40021C00)
GPIOI_BASE :: uintptr(0x40022000)
GPIOJ_BASE :: uintptr(0x40022400)
GPIOK_BASE :: uintptr(0x40022800)

// GPIO register offsets relative to the port base address.
//
// See RM0385, GPIO register map.
GPIO_MODER_OFFSET   :: uintptr(0x00)
GPIO_OTYPER_OFFSET  :: uintptr(0x04)
GPIO_OSPEEDR_OFFSET :: uintptr(0x08)
GPIO_PUPDR_OFFSET   :: uintptr(0x0C)
GPIO_BSRR_OFFSET    :: uintptr(0x18)
GPIO_AFRL_OFFSET    :: uintptr(0x20)
GPIO_AFRH_OFFSET    :: uintptr(0x24)

// GPIO_Mode specifies the operating mode of a GPIO pin.
//
// See RM0385, GPIOx_MODER.
GPIO_Mode :: enum u8 {
    Input     = 0b00,
    Output    = 0b01,
    Alternate = 0b10,
    Analog    = 0b11,
}

// GPIO_Output_Type specifies the electrical output configuration.
//
// Push-pull can actively drive the pin high or low.
// Open-drain can pull the pin low but requires a pull-up
// to produce a high level.
//
// See RM0385, GPIOx_OTYPER.
GPIO_Output_Type :: enum u8 {
    Push_Pull  = 0,
    Open_Drain = 1,
}

// GPIO_MODER_Register represents a GPIO port mode register.
//
// Each MODER field controls the operating mode of one GPIO pin.
//
// See RM0385, GPIOx_MODER.
GPIO_MODER_Register :: bit_field u32 {
    MODER0:  GPIO_Mode | 2,
    MODER1:  GPIO_Mode | 2,
    MODER2:  GPIO_Mode | 2,
    MODER3:  GPIO_Mode | 2,
    MODER4:  GPIO_Mode | 2,
    MODER5:  GPIO_Mode | 2,
    MODER6:  GPIO_Mode | 2,
    MODER7:  GPIO_Mode | 2,
    MODER8:  GPIO_Mode | 2,
    MODER9:  GPIO_Mode | 2,
    MODER10: GPIO_Mode | 2,
    MODER11: GPIO_Mode | 2,
    MODER12: GPIO_Mode | 2,
    MODER13: GPIO_Mode | 2,
    MODER14: GPIO_Mode | 2,
    MODER15: GPIO_Mode | 2,
}

// GPIO_BSRR_Register represents a GPIO port bit set/reset register.
//
// Writing 1 to BS0-BS15 sets the corresponding output bit.
// Writing 1 to BR0-BR15 resets the corresponding output bit.
// Writing 0 has no effect.
//
// This register is write-only.
//
// See RM0385, GPIOx_BSRR.
GPIO_BSRR_Register :: bit_field u32 {
    BS0:  bool | 1,
    BS1:  bool | 1,
    BS2:  bool | 1,
    BS3:  bool | 1,
    BS4:  bool | 1,
    BS5:  bool | 1,
    BS6:  bool | 1,
    BS7:  bool | 1,
    BS8:  bool | 1,
    BS9:  bool | 1,
    BS10: bool | 1,
    BS11: bool | 1,
    BS12: bool | 1,
    BS13: bool | 1,
    BS14: bool | 1,
    BS15: bool | 1,

    BR0:  bool | 1,
    BR1:  bool | 1,
    BR2:  bool | 1,
    BR3:  bool | 1,
    BR4:  bool | 1,
    BR5:  bool | 1,
    BR6:  bool | 1,
    BR7:  bool | 1,
    BR8:  bool | 1,
    BR9:  bool | 1,
    BR10: bool | 1,
    BR11: bool | 1,
    BR12: bool | 1,
    BR13: bool | 1,
    BR14: bool | 1,
    BR15: bool | 1,
}

// GPIO_OTYPER_Register represents the GPIO output type register.
//
// Each field controls the output type of one GPIO pin.
//
// See RM0385, GPIOx_OTYPER.
GPIO_OTYPER_Register :: bit_field u32 {
    OT0:  GPIO_Output_Type | 1,
    OT1:  GPIO_Output_Type | 1,
    OT2:  GPIO_Output_Type | 1,
    OT3:  GPIO_Output_Type | 1,
    OT4:  GPIO_Output_Type | 1,
    OT5:  GPIO_Output_Type | 1,
    OT6:  GPIO_Output_Type | 1,
    OT7:  GPIO_Output_Type | 1,
    OT8:  GPIO_Output_Type | 1,
    OT9:  GPIO_Output_Type | 1,
    OT10: GPIO_Output_Type | 1,
    OT11: GPIO_Output_Type | 1,
    OT12: GPIO_Output_Type | 1,
    OT13: GPIO_Output_Type | 1,
    OT14: GPIO_Output_Type | 1,
    OT15: GPIO_Output_Type | 1,

    _reserved: u16 | 16,
}

// GPIO_Alternate_Function specifies an alternate function number.
//
// The peripheral associated with an alternate function depends
// on the selected pin and STM32 device.
//
// See the STM32F756 datasheet, alternate function mapping.
GPIO_Alternate_Function :: enum u8 {
    AF0  = 0,
    AF1  = 1,
    AF2  = 2,
    AF3  = 3,
    AF4  = 4,
    AF5  = 5,
    AF6  = 6,
    AF7  = 7,
    AF8  = 8,
    AF9  = 9,
    AF10 = 10,
    AF11 = 11,
    AF12 = 12,
    AF13 = 13,
    AF14 = 14,
    AF15 = 15,
}

// GPIO_AFRL_Register represents the alternate function register
// for pins 0-7.
//
// Each pin uses four bits to select an alternate function.
//
// See RM0385, GPIOx_AFRL.
GPIO_AFRL_Register :: bit_field u32 {
    AFR0: GPIO_Alternate_Function | 4,
    AFR1: GPIO_Alternate_Function | 4,
    AFR2: GPIO_Alternate_Function | 4,
    AFR3: GPIO_Alternate_Function | 4,
    AFR4: GPIO_Alternate_Function | 4,
    AFR5: GPIO_Alternate_Function | 4,
    AFR6: GPIO_Alternate_Function | 4,
    AFR7: GPIO_Alternate_Function | 4,
}

// GPIO_AFRH_Register represents the alternate function register
// for pins 8-15.
//
// Each pin uses four bits to select an alternate function.
//
// See RM0385, GPIOx_AFRH.
GPIO_AFRH_Register :: bit_field u32 {
    AFR8:  GPIO_Alternate_Function | 4,
    AFR9:  GPIO_Alternate_Function | 4,
    AFR10: GPIO_Alternate_Function | 4,
    AFR11: GPIO_Alternate_Function | 4,
    AFR12: GPIO_Alternate_Function | 4,
    AFR13: GPIO_Alternate_Function | 4,
    AFR14: GPIO_Alternate_Function | 4,
    AFR15: GPIO_Alternate_Function | 4,
}

// read_gpio_moder reads the mode register of a GPIO port.
read_gpio_moder :: proc "contextless" (base: uintptr) -> GPIO_MODER_Register {
    raw := mmio.read_u32(base + GPIO_MODER_OFFSET)
    return transmute(GPIO_MODER_Register)raw
}

// write_gpio_moder writes the mode register of a GPIO port.
//
// Callers should preserve unrelated pin configurations by
// modifying a previously read register value.
write_gpio_moder :: proc "contextless" (base: uintptr, reg: GPIO_MODER_Register) {
    mmio.write_u32(base + GPIO_MODER_OFFSET, transmute(u32)reg)
}

// write_gpio_bsrr writes a set/reset command to a GPIO port.
//
// BSRR is write-only and does not require read-modify-write.
write_gpio_bsrr :: proc "contextless" (base: uintptr, reg: GPIO_BSRR_Register) {
    mmio.write_u32(base + GPIO_BSRR_OFFSET, transmute(u32)reg)
}

// read_gpio_afrl reads the alternate function register
// for GPIO pins 0-7.
read_gpio_afrl :: proc "contextless" (base: uintptr) -> GPIO_AFRL_Register {
    raw := mmio.read_u32(base + GPIO_AFRL_OFFSET)
    return transmute(GPIO_AFRL_Register)raw
}

// write_gpio_afrl writes the alternate function register
// for GPIO pins 0-7.
write_gpio_afrl :: proc "contextless" (base: uintptr, reg: GPIO_AFRL_Register) {
    mmio.write_u32(base + GPIO_AFRL_OFFSET, transmute(u32)reg)
}

// read_gpio_afrh reads the alternate function register
// for GPIO pins 8-15.
read_gpio_afrh :: proc "contextless" (base: uintptr) -> GPIO_AFRH_Register {
    raw := mmio.read_u32(base + GPIO_AFRH_OFFSET)
    return transmute(GPIO_AFRH_Register)raw
}

// write_gpio_afrh writes the alternate function register
// for GPIO pins 8-15.
write_gpio_afrh :: proc "contextless" (base: uintptr, reg: GPIO_AFRH_Register) {
    mmio.write_u32(base + GPIO_AFRH_OFFSET, transmute(u32)reg)
}

// read_gpio_otyper reads the output type register of a GPIO port.
read_gpio_otyper :: proc "contextless" (base: uintptr) -> GPIO_OTYPER_Register {
    raw := mmio.read_u32(base + GPIO_OTYPER_OFFSET)
    return transmute(GPIO_OTYPER_Register)raw
}

// write_gpio_otyper writes the output type register of a GPIO port.
write_gpio_otyper :: proc "contextless" (base: uintptr, reg: GPIO_OTYPER_Register) {
    mmio.write_u32(base + GPIO_OTYPER_OFFSET, transmute(u32)reg)
}


// ========================================================================================

// GPIO_Output_Speed specifies the output slew-rate configuration.
//
// Higher speeds allow faster signal transitions but can increase
// electromagnetic interference and power consumption.
//
// See RM0385, GPIOx_OSPEEDR.
GPIO_Output_Speed :: enum u8 {
    Low       = 0b00,
    Medium    = 0b01,
    High      = 0b10,
    Very_High = 0b11,
}

// GPIO_OSPEEDR_Register represents the GPIO output speed register.
//
// Each field controls the output speed of one GPIO pin.
//
// See RM0385, GPIOx_OSPEEDR.
GPIO_OSPEEDR_Register :: bit_field u32 {
    OSPEEDR0:  GPIO_Output_Speed | 2,
    OSPEEDR1:  GPIO_Output_Speed | 2,
    OSPEEDR2:  GPIO_Output_Speed | 2,
    OSPEEDR3:  GPIO_Output_Speed | 2,
    OSPEEDR4:  GPIO_Output_Speed | 2,
    OSPEEDR5:  GPIO_Output_Speed | 2,
    OSPEEDR6:  GPIO_Output_Speed | 2,
    OSPEEDR7:  GPIO_Output_Speed | 2,
    OSPEEDR8:  GPIO_Output_Speed | 2,
    OSPEEDR9:  GPIO_Output_Speed | 2,
    OSPEEDR10: GPIO_Output_Speed | 2,
    OSPEEDR11: GPIO_Output_Speed | 2,
    OSPEEDR12: GPIO_Output_Speed | 2,
    OSPEEDR13: GPIO_Output_Speed | 2,
    OSPEEDR14: GPIO_Output_Speed | 2,
    OSPEEDR15: GPIO_Output_Speed | 2,
}

// read_gpio_ospeedr reads the output speed register of a GPIO port.
read_gpio_ospeedr :: proc "contextless" (base: uintptr) -> GPIO_OSPEEDR_Register {
    raw := mmio.read_u32(base + GPIO_OSPEEDR_OFFSET)
    return transmute(GPIO_OSPEEDR_Register)raw
}

// write_gpio_ospeedr writes the output speed register of a GPIO port.
//
// Callers should preserve unrelated pin configurations by
// modifying a previously read register value.
write_gpio_ospeedr :: proc "contextless" (base: uintptr, reg: GPIO_OSPEEDR_Register) {
    mmio.write_u32(base + GPIO_OSPEEDR_OFFSET, transmute(u32)reg)
}

// ========================================================================================


// GPIO_Pull specifies the internal pull resistor configuration.
//
// Pull-up biases an undriven pin toward the supply voltage.
// Pull-down biases an undriven pin toward ground.
//
// See RM0385, GPIOx_PUPDR.
GPIO_Pull :: enum u8 {
    None      = 0b00,
    Pull_Up   = 0b01,
    Pull_Down = 0b10,
    Reserved  = 0b11,
}

// GPIO_PUPDR_Register represents the GPIO pull-up/pull-down register.
//
// Each field controls the internal pull resistor of one GPIO pin.
//
// See RM0385, GPIOx_PUPDR.
GPIO_PUPDR_Register :: bit_field u32 {
    PUPDR0:  GPIO_Pull | 2,
    PUPDR1:  GPIO_Pull | 2,
    PUPDR2:  GPIO_Pull | 2,
    PUPDR3:  GPIO_Pull | 2,
    PUPDR4:  GPIO_Pull | 2,
    PUPDR5:  GPIO_Pull | 2,
    PUPDR6:  GPIO_Pull | 2,
    PUPDR7:  GPIO_Pull | 2,
    PUPDR8:  GPIO_Pull | 2,
    PUPDR9:  GPIO_Pull | 2,
    PUPDR10: GPIO_Pull | 2,
    PUPDR11: GPIO_Pull | 2,
    PUPDR12: GPIO_Pull | 2,
    PUPDR13: GPIO_Pull | 2,
    PUPDR14: GPIO_Pull | 2,
    PUPDR15: GPIO_Pull | 2,
}

// read_gpio_pupdr reads the pull-up/pull-down register of a GPIO port.
read_gpio_pupdr :: proc "contextless" (base: uintptr) -> GPIO_PUPDR_Register {
    raw := mmio.read_u32(base + GPIO_PUPDR_OFFSET)
    return transmute(GPIO_PUPDR_Register)raw
}

// write_gpio_pupdr writes the pull-up/pull-down register of a GPIO port.
//
// Callers should preserve unrelated pin configurations by
// modifying a previously read register value.
write_gpio_pupdr :: proc "contextless" (base: uintptr, reg: GPIO_PUPDR_Register) {
    mmio.write_u32(base + GPIO_PUPDR_OFFSET, transmute(u32)reg)
}

// ========================================================================================
