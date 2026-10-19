
package minimal

import "embedded:arch/arm/cortex_m7"
import "embedded:mcu/stm32f756"

@(export)
embedded_main :: proc "c" () {
	stm32f756.enable_gpio_b_clock()

	moder := stm32f756.read_gpio_b_moder()
	moder.MODER0 = .Output
	stm32f756.write_gpio_b_moder(moder)

	// Configure SysTick to generate 1000 interrupts per second.
	if !cortex_m7.configure_systick_processor_clock(
		16_000_000,
		1_000,
		.Interrupt,
	) {
		for {}
	}

	last_tick := cortex_m7.read_systick_ticks()
	led_on := false

	for {
		now := cortex_m7.read_systick_ticks()

		if now - last_tick >= 500 {
			last_tick = now
			led_on = !led_on

			bsrr := stm32f756.GPIO_BSRR_Register{}

			if led_on {
				bsrr.BS0 = true
			} else {
				bsrr.BR0 = true
			}

			stm32f756.write_gpio_b_bsrr(bsrr)
		}
	}
}
