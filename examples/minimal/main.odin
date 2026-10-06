package minimal

import "embedded:arch/arm/cortex_m7"
import "embedded:mcu/stm32f756"

@(export)
embedded_main :: proc "c" () {
	stm32f756.enable_gpio_b_clock()

	moder := stm32f756.read_gpio_b_moder()
	moder.MODER0 = .Output
	stm32f756.write_gpio_b_moder(moder)

	cortex_m7.configure_systick_processor_clock(16_000_000, 1_000)

	for {
		bsrr := stm32f756.GPIO_BSRR_Register{}
		bsrr.BS0 = true
		stm32f756.write_gpio_b_bsrr(bsrr)

		cortex_m7.wait_for_systick_ticks(500)

		bsrr = stm32f756.GPIO_BSRR_Register{}
		bsrr.BR0 = true
		stm32f756.write_gpio_b_bsrr(bsrr)

		cortex_m7.wait_for_systick_ticks(500)
	}
}
