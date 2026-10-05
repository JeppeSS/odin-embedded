package stm32f756

import "../../mmio"

// GPIOB_BASE is the base address of GPIO port B.
//
// See RM0385, General-purpose I/Os (GPIO).
GPIOB_BASE :: uintptr(0x40020400)

// GPIOB_MODER is the GPIO port B mode register.
//
// Each GPIO pin is controlled by a two-bit field in this register.
// Register offset: 0x00 from GPIOB_BASE.
//
// See RM0385, GPIO port mode register (GPIOx_MODER).
GPIOB_MODER :: GPIOB_BASE + 0x00

// GPIO_Mode specifies the operating mode of a GPIO pin.
//
// See RM0385, GPIOx_MODER.
GPIO_Mode :: enum u8 {
	Input     = 0b00,
	Output    = 0b01,
	Alternate = 0b10,
	Analog    = 0b11,
}

// GPIO_MODER_Register represents the fields of a GPIO port mode register.
//
// Each MODER field controls the operating mode of the corresponding GPIO pin.
// For example, MODER0 controls pin 0 and MODER15 controls pin 15.
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

// read_gpio_b_moder reads the current value of GPIOB_MODER.
read_gpio_b_moder :: proc "contextless" () -> GPIO_MODER_Register {
	raw := mmio.read_u32(GPIOB_MODER)
	return transmute(GPIO_MODER_Register)raw
}

// write_gpio_b_moder writes value to GPIOB_MODER.
write_gpio_b_moder :: proc "contextless" (reg: GPIO_MODER_Register) {
	mmio.write_u32(GPIOB_MODER, transmute(u32)reg)
}

// GPIOB_BSRR is the GPIO port B bit set/reset register.
//
// Writing a 1 to BS0-BS15 sets the corresponding output bit.
// Writing a 1 to BR0-BR15 resets the corresponding output bit.
// Writing a 0 has no effect.
//
// Register offset: 0x18 from GPIOB_BASE.
//
// See RM0385, GPIO port bit set/reset register (GPIOx_BSRR).
GPIOB_BSRR :: GPIOB_BASE + 0x18

// GPIO_BSRR_Register represents the fields of a GPIO port bit set/reset
// register.
//
// BS0-BS15 set the corresponding GPIO output.
// BR0-BR15 reset the corresponding GPIO output.
//
// This register is write-only.
//
// If both BSx and BRx are set for the same pin, BSx has priority.
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

// write_gpio_b_bsrr writes a set/reset command to GPIOB_BSRR.
//
// Bits set to 1 perform the corresponding operation.
// Bits set to 0 have no effect.
write_gpio_b_bsrr :: proc "contextless" (reg: GPIO_BSRR_Register) {
	mmio.write_u32(GPIOB_BSRR, transmute(u32)reg)
}
