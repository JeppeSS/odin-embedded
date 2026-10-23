
package systick

import cortex_m7 "embedded:arch/arm/cortex_m7"
import nucleo "embedded:boards/nucleo_f756zg"

@(export)
embedded_main :: proc "c" () {
    // Initialize the ST-LINK Virtual COM Port.
    if !nucleo.init_stlink_uart(16_000_000, 115_200) {
        for {}
    }

    // Configure SysTick for 1 ms ticks using the 16 MHz processor clock.
    if !cortex_m7.configure_systick_processor_clock(
        16_000_000,
        1_000,
        .Polling,
    ) {
        for {}
    }

    nucleo.stlink_uart_write_string("SysTick started\r\n")

    for {
        // Wait for 1000 ticks (approximately one second).
        cortex_m7.wait_for_systick_ticks(1_000)

        nucleo.stlink_uart_write_string("One second elapsed\r\n")
    }
}
