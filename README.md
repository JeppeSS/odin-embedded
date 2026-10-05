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

## Building

`ode` is the command-line tool used to build and flash firmware.

Build `ode` using Odin:

```sh
mkdir -p bin
odin build tools/ode -out:bin/ode
```

Build the example firmware:

```sh
./bin/ode build
```

The resulting firmware ELF is written to:

```text
build/firmware.elf
```

## Flashing

Firmware can be flashed to the target using:

```sh
./bin/ode flash
```

The current flashing implementation uses OpenOCD and ST-LINK.

## Tooling

`ode` is a small build tool for `odin-embedded`.

It currently provides:

```text
ode build
ode flash
```

Additional commands and functionality will be added as they become necessary.

`ode` does not replace the Odin compiler, linker, OpenOCD, or debugger. It
orchestrates the existing embedded toolchain and provides a consistent workflow
for projects using `odin-embedded`.

## Status

`odin-embedded` is in early development.

APIs, project structure, and tooling may change as the framework evolves.

## License

`odin-embedded` is licensed under the MIT License.

See [LICENSE](LICENSE) for details.
