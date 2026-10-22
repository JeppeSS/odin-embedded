package nucleo_f756zg

import "embedded:mcu/stm32f756"

// init_ld1 configures the NUCLEO-F756ZG user LED LD1.
//
// LD1 is green, connected to PB0, and active-high.
//
// The LED is initially turned off.
init_ld1 :: proc "contextless" () {
    stm32f756.enable_gpio_b_clock()

    moder := stm32f756.read_gpio_moder(stm32f756.GPIOB_BASE)
    moder.MODER0 = .Output
    stm32f756.write_gpio_moder(stm32f756.GPIOB_BASE, moder)

    set_ld1(false)
}

// set_ld1 controls the NUCLEO-F756ZG user LED LD1.
//
// true turns LD1 on; false turns LD1 off.
//
// init_ld1 must be called before using this function.
set_ld1 :: proc "contextless" (enabled: bool) {
    bsrr := stm32f756.GPIO_BSRR_Register{}

    if enabled {
        bsrr.BS0 = true
    } else {
        bsrr.BR0 = true
    }

    stm32f756.write_gpio_bsrr(stm32f756.GPIOB_BASE, bsrr)
}
