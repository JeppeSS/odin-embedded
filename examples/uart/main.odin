
package uart

import cortex_m7 "embedded:arch/arm/cortex_m7"
import nucleo "embedded:boards/nucleo_f756zg"

@(export)
embedded_main :: proc "c" () {
    // Keep the Cortex-M7 runtime linked.
    _ = cortex_m7.read_systick_ticks()

    // Initialize USART3 at 115200 baud using the 16 MHz PCLK1.
    ok := nucleo.init_stlink_uart(16_000_000, 115_200)

    if !ok {
        for {}
    }

    // Send a message through the ST-LINK Virtual COM Port.
    nucleo.stlink_uart_write_string("Hello from Odin UART!\r\n")

    for {}
}
