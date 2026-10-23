
package nucleo_f756zg

import "embedded:mcu/stm32f756"

// init_stlink_uart configures the NUCLEO-F756ZG ST-LINK
// Virtual COM Port for transmission.
//
// USART3_TX is connected to PD8 using alternate function 7.
//
// peripheral_clock_hz must match the actual USART3 clock frequency.
//
// The function currently initializes transmission only.
init_stlink_uart :: proc "contextless" (
    peripheral_clock_hz: u32,
    baud_rate: u32,
) -> bool {
    stm32f756.enable_gpio_d_clock()
    stm32f756.enable_usart3_clock()

    // Select USART3 alternate function for PD8.
    afrh := stm32f756.read_gpio_afrh(stm32f756.GPIOD_BASE)
    afrh.AFR8 = .AF7
    stm32f756.write_gpio_afrh(stm32f756.GPIOD_BASE, afrh)

    // Configure PD8 as push-pull.
    otyper := stm32f756.read_gpio_otyper(stm32f756.GPIOD_BASE)
    otyper.OT8 = .Push_Pull
    stm32f756.write_gpio_otyper(stm32f756.GPIOD_BASE, otyper)

    // Configure medium output speed.
    ospeedr := stm32f756.read_gpio_ospeedr(stm32f756.GPIOD_BASE)
    ospeedr.OSPEEDR8 = .Medium
    stm32f756.write_gpio_ospeedr(stm32f756.GPIOD_BASE, ospeedr)

    // Disable internal pull resistors on TX.
    pupdr := stm32f756.read_gpio_pupdr(stm32f756.GPIOD_BASE)
    pupdr.PUPDR8 = .None
    stm32f756.write_gpio_pupdr(stm32f756.GPIOD_BASE, pupdr)

    // Enable alternate function mode on PD8.
    moder := stm32f756.read_gpio_moder(stm32f756.GPIOD_BASE)
    moder.MODER8 = .Alternate
    stm32f756.write_gpio_moder(stm32f756.GPIOD_BASE, moder)

    return stm32f756.usart_init_tx(
        stm32f756.USART3_BASE,
        peripheral_clock_hz,
        baud_rate,
    )
}

// stlink_uart_write_byte transmits one byte through
// the ST-LINK Virtual COM Port.
//
// init_stlink_uart must be called before using this function.
stlink_uart_write_byte :: proc "contextless" (value: u8) {
    stm32f756.usart_write_byte(stm32f756.USART3_BASE, value)
}

// stlink_uart_write_bytes transmits bytes through
// the ST-LINK Virtual COM Port.
//
// init_stlink_uart must be called before using this function.
stlink_uart_write_bytes :: proc "contextless" (data: []u8) {
    stm32f756.usart_write_bytes(stm32f756.USART3_BASE, data)
}

// stlink_uart_write_string transmits a string through
// the ST-LINK Virtual COM Port.
//
// The string is transmitted as raw UTF-8 bytes without
// a null terminator.
//
// This function does not allocate memory.
//
// init_stlink_uart must be called before using this function.
stlink_uart_write_string :: proc "contextless" (message: string) {
    stlink_uart_write_bytes(transmute([]u8)message)
}
