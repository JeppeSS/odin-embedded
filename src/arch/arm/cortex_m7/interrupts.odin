package cortex_m7

import "base:intrinsics"


ticks: u32

@(export)
SysTick_Handler :: proc "c" () {
	ticks += 1
}

// read_systick_ticks returns the number of SysTick interrupts handled
// since startup.
read_systick_ticks :: proc "contextless" () -> u32 {
    return intrinsics.volatile_load(&ticks)
}
