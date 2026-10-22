
package stm32f756_minimal

import cortex_m7 "embedded:arch/arm/cortex_m7"

// Entry point used to validate Cortex-M7 startup and linking.
@(export)
embedded_main :: proc "c" () {
    // Keep the Cortex-M7 runtime linked into the firmware.
    _ = cortex_m7.read_systick_ticks()

    // Remain idle.
    for {}
}
