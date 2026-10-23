
package blink

import cortex_m7 "embedded:arch/arm/cortex_m7"
import nucleo "embedded:boards/nucleo_f756zg"

@(export)
embedded_main :: proc "c" () {
    nucleo.init_ld1()

    // Configure SysTick for 1 ms ticks using the 16 MHz processor clock.
    ok := cortex_m7.configure_systick_processor_clock(
        16_000_000,
        1_000,
        .Polling,
    )

    if !ok {
        for {}
    }

    led_on := false
    nucleo.set_ld1(led_on)

    for {
        // Wait 500 ms.
        cortex_m7.wait_for_systick_ticks(500)

        led_on = !led_on
        nucleo.set_ld1(led_on)
    }
}
