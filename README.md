# odin-embedded
A small, bare-metal embedded framework for Odin.

The framework currently targets ARM Cortex-M7 and STM32F756, with development
and testing performed on the NUCLEO-F756ZG development board.

## Current target

Development currently targets:

- ARM Cortex-M7
- STM32F756
- NUCLEO-F756ZG development board

Hardware support is intentionally limited and will grow as new functionality is
required by real applications.

## Getting started

Applications import framework packages through the `embedded` Odin collection.

For example:

```odin
import "embedded:mcu/stm32f756"
```

The `ode` build tool configures this collection automatically when building
the included examples.

### GPIO example

The following example enables GPIO port B, configures PB0 as a general-purpose
output, and sets the output high:

```odin
package minimal

import "embedded:mcu/stm32f756"

@(export)
embedded_main :: proc "c" () {
	stm32f756.enable_gpio_b_clock()

	moder := stm32f756.read_gpio_b_moder()
	moder.MODER0 = .Output
	stm32f756.write_gpio_b_moder(moder)

	bsrr := stm32f756.GPIO_BSRR_Register{}
	bsrr.BS0 = true
	stm32f756.write_gpio_b_bsrr(bsrr)

	for {}
}
```

This example demonstrates the current low-level API directly. Higher-level
abstractions will only be introduced when concrete use cases justify them.
