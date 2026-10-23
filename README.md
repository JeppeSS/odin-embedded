# odin-embedded

A lightweight, bare-metal embedded framework for the [Odin programming language](https://odin-lang.org/).

`odin-embedded` provides low-level hardware access, microcontroller-specific drivers, board support, and a simple build workflow for developing firmware in Odin without relying on a vendor HAL.

The project focuses on simplicity, explicit hardware control, and introducing abstractions only when they solve real problems.

> **Early development:** The framework currently supports a limited hardware configuration. APIs and tooling may change as the project evolves.

## Supported hardware

| Component | Current support |
|---|---|
| Architecture | ARM Cortex-M7 |
| Microcontroller | STM32F756 |
| Development board | NUCLEO-F756ZG |
| Debugging and flashing | ST-LINK / OpenOCD |
| Toolchain | Odin + GNU Arm Embedded Toolchain |

Additional architectures, microcontrollers, and development boards may be supported in the future.

## Features

The framework currently provides:

- **Bare-metal startup** — vector table, reset handler, memory initialization, and default exception handlers.
- **Memory-mapped I/O** — low-level register access without a vendor HAL.
- **GPIO** — pin configuration and digital output.
- **RCC** — peripheral clock enabling.
- **SysTick** — processor-clock configuration and polling-based delays.
- **USART** — basic blocking UART transmission.
- **Board support** — convenience functions for the NUCLEO-F756ZG LED and ST-LINK Virtual COM Port.
- **ode** — a command-line tool for building and flashing firmware.

Not yet implemented: UART reception, DMA, I2C, SPI, and general-purpose timer drivers.

## Getting started

### Prerequisites

The current workflow targets Linux and requires:

- Odin compiler
- GNU Arm Embedded Toolchain (`arm-none-eabi-gcc`)
- OpenOCD
- ST-LINK-compatible hardware for flashing

Make sure the required tools are available in your `PATH`.

### Build ode

`ode` is the project's command-line build and flashing tool, written in Odin.

From the repository root:

```sh
mkdir -p bin
odin build tools/ode -out:bin/ode
```

### Build your first firmware

Build the LED blink example:

```sh
./bin/ode build examples/blink
```

The resulting ELF file is written to:

```text
build/blink/firmware.elf
```

### Flash the board

Connect your NUCLEO-F756ZG through its ST-LINK USB interface.

```sh
./bin/ode flash examples/blink
```

The green LD1 LED should blink approximately once per second.

## Example: Blinking an LED

The following example uses the board support package and Cortex-M7 SysTick timer.

```odin
package blink

import cortex_m7 "embedded:arch/arm/cortex_m7"
import nucleo "embedded:boards/nucleo_f756zg"

@(export)
embedded_main :: proc "c" () {
    nucleo.init_ld1()

    // Configure SysTick for 1 ms ticks at 16 MHz.
    if !cortex_m7.configure_systick_processor_clock(
        16_000_000,
        1_000,
        .Polling,
    ) {
        for {}
    }

    led_on := false
    nucleo.set_ld1(led_on)

    for {
        cortex_m7.wait_for_systick_ticks(500)

        led_on = !led_on
        nucleo.set_ld1(led_on)
    }
}
```

The board support package handles the hardware-specific GPIO configuration for LD1.

For more direct control, applications can use the STM32F756 peripheral drivers.

## Examples

The `examples/` directory contains small, independent firmware projects.

| Example | Description |
|---|---|
| `minimal` | Basic integration example using LED, SysTick, and UART |
| `blink` | Blink the onboard LED using SysTick |
| `uart` | Transmit a message through the ST-LINK Virtual COM Port |
| `systick` | Demonstrate periodic timing using SysTick and UART |

Each example can be built independently:

```sh
./bin/ode build examples/uart
./bin/ode flash examples/uart
```

For UART examples, connect to the ST-LINK Virtual COM Port at 115200 baud. On Linux, the device may appear as `/dev/ttyACM0`.

## Project structure

```text
odin-embedded/
├── src/
│   ├── arch/
│   │   └── arm/
│   │       └── cortex_m7/
│   ├── mcu/
│   │   └── stm32f756/
│   ├── boards/
│   │   └── nucleo_f756zg/
│   └── mmio/
├── examples/
│   ├── minimal/
│   ├── blink/
│   ├── uart/
│   └── systick/
├── tests/
│   ├── arch/
│   ├── mcu/
│   ├── fixtures/
│   └── firmware_validation/
├── tools/
│   └── ode/
└── .github/
    └── workflows/
```

### Architecture

The framework separates hardware support into several layers.

**Architecture (`arch/`)**

CPU-specific functionality such as SysTick, exception handling, and startup code.

**Microcontroller (`mcu/`)**

Peripheral register definitions and drivers for a particular microcontroller.

**Board (`boards/`)**

Board-specific functionality that combines MCU peripherals with known hardware connections, such as LEDs and serial interfaces.

**MMIO (`mmio/`)**

Low-level memory-mapped register access.

This separation keeps hardware-specific details explicit while allowing reusable functionality to be introduced when needed.

## Building and flashing with ode

The `ode` tool orchestrates the existing embedded toolchain.

```sh
./bin/ode build <project-path>
./bin/ode flash <project-path>
```

For example:

```sh
./bin/ode build examples/minimal
./bin/ode flash examples/minimal
```

Build artifacts are stored under:

```text
build/<project-name>/
```

The current implementation is specific to the STM32F756/Cortex-M7 toolchain and uses OpenOCD with ST-LINK for flashing.

`ode` does not replace the Odin compiler, GNU Arm Embedded Toolchain, or OpenOCD.

## Roadmap

Planned areas of development include:

- UART reception
- GPIO input and external interrupts
- General-purpose timers
- I2C and SPI
- Improved build configuration and project support
- Additional microcontrollers and development boards

The roadmap is intentionally flexible and driven by practical applications.

## Status

`odin-embedded` is an experimental project in active development.

The current goal is to establish a small, reliable foundation for writing bare-metal firmware in Odin.

Contributions, suggestions, and experiments are welcome.

## License

Licensed under the MIT License. See [LICENSE](LICENSE) for details.
