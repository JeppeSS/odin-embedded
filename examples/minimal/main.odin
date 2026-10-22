
package minimal

import "embedded:arch/arm/cortex_m7"
import nucleo "embedded:boards/nucleo_f756zg"

@(export)
embedded_main :: proc "c" () {
    // Initialize board peripherals.
    nucleo.init_ld1()

    if !nucleo.init_stlink_uart(16_000_000, 115_200) {
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

    message := []u8{
        'H', 'e', 'l', 'l', 'o', ' ',
        'f', 'r', 'o', 'm', ' ',
        'O', 'd', 'i', 'n', '!',
        '\r', '\n',
    }

    nucleo.stlink_uart_write_bytes(message)

    for {
        now := cortex_m7.read_systick_ticks()

        // Toggle LD1 every 500 milliseconds.
        if now - last_led_tick >= 500 {
            last_led_tick = now
            led_on = !led_on

            nucleo.set_ld1(led_on)
        }

        // Send a message every second.
        if now - last_uart_tick >= 1_000 {
            last_uart_tick = now

            nucleo.stlink_uart_write_bytes(message)
        }
    }
}
