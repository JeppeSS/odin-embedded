
package minimal

import "embedded:arch/arm/cortex_m7"
import "embedded:mcu/stm32f756"

@(export)
embedded_main :: proc "c" () {
    // Enable peripheral clocks.
    stm32f756.enable_gpio_b_clock()
    stm32f756.enable_gpio_d_clock()
    stm32f756.enable_usart3_clock()

    // Configure PB0 as a general-purpose output.
    led_moder := stm32f756.read_gpio_moder(stm32f756.GPIOB_BASE)
    led_moder.MODER0 = .Output
    stm32f756.write_gpio_moder(stm32f756.GPIOB_BASE, led_moder)

    // Configure PD8 as USART3_TX using alternate function 7.
    afrh := stm32f756.read_gpio_afrh(stm32f756.GPIOD_BASE)
    afrh.AFR8 = .AF7
    stm32f756.write_gpio_afrh(stm32f756.GPIOD_BASE, afrh)

    // Configure USART3_TX as push-pull.
    otyper := stm32f756.read_gpio_otyper(stm32f756.GPIOD_BASE)
    otyper.OT8 = .Push_Pull
    stm32f756.write_gpio_otyper(stm32f756.GPIOD_BASE, otyper)

    // Configure medium output speed for PD8.
    ospeedr := stm32f756.read_gpio_ospeedr(stm32f756.GPIOD_BASE)
    ospeedr.OSPEEDR8 = .Medium
    stm32f756.write_gpio_ospeedr(stm32f756.GPIOD_BASE, ospeedr)

    // Disable internal pull resistors on PD8.
    pupdr := stm32f756.read_gpio_pupdr(stm32f756.GPIOD_BASE)
    pupdr.PUPDR8 = .None
    stm32f756.write_gpio_pupdr(stm32f756.GPIOD_BASE, pupdr)

    // Activate alternate function mode for PD8.
    uart_moder := stm32f756.read_gpio_moder(stm32f756.GPIOD_BASE)
    uart_moder.MODER8 = .Alternate
    stm32f756.write_gpio_moder(stm32f756.GPIOD_BASE, uart_moder)

    // Initialize USART3 at 115200 baud.
    //
    // Assumes the USART3 peripheral clock is 16 MHz.
    if !stm32f756.usart_init_tx(
        stm32f756.USART3_BASE,
        16_000_000,
        115_200,
    ) {
        for {}
    }

    // Configure SysTick to generate 1000 interrupts per second.
    if !cortex_m7.configure_systick_processor_clock(
        16_000_000,
        1_000,
        .Interrupt,
    ) {
        for {}
    }

    last_led_tick := cortex_m7.read_systick_ticks()
    last_uart_tick := last_led_tick
    led_on := false

    // Send an initial startup message.
    message := []u8{
        'H', 'e', 'l', 'l', 'o', ' ',
        'f', 'r', 'o', 'm', ' ',
        'O', 'd', 'i', 'n', '!',
        '\r', '\n',
    }

    stm32f756.usart_write_bytes(
        stm32f756.USART3_BASE,
        message,
    )

    for {
        now := cortex_m7.read_systick_ticks()

        // Toggle the LED every 500 milliseconds.
        if now - last_led_tick >= 500 {
            last_led_tick = now
            led_on = !led_on

            bsrr := stm32f756.GPIO_BSRR_Register{}

            if led_on {
                bsrr.BS0 = true
            } else {
                bsrr.BR0 = true
            }

            stm32f756.write_gpio_bsrr(
                stm32f756.GPIOB_BASE,
                bsrr,
            )
        }

        // Send a message every second.
        if now - last_uart_tick >= 1_000 {
            last_uart_tick = now

            stm32f756.usart_write_bytes(
                stm32f756.USART3_BASE,
                message,
            )
        }
    }
}
