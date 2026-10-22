
package firmware_validation

import "core:os"
import "core:strconv"
import "core:strings"
import "core:testing"

FIRMWARE_PATH :: "build/stm32f756_minimal/firmware.elf"

// get_symbol_address looks up a defined symbol in the firmware ELF.
get_symbol_address :: proc(name: string) -> (uintptr, bool) {
    command := []string{
        "arm-none-eabi-nm",
        "--defined-only",
        FIRMWARE_PATH,
    }

    state, stdout, stderr, err := os.process_exec(
        {
            command = command,
        },
        context.allocator,
    )
    defer delete(stdout)
    defer delete(stderr)

    if err != nil || !state.success {
        return 0, false
    }

    output := string(stdout)

    lines := strings.split_lines(output)
    defer delete(lines)

    for line in lines {
        fields := strings.fields(line)

        if len(fields) == 3 && fields[2] == name {
            address, ok := strconv.parse_uint(fields[0], 16)
            delete(fields)

            if !ok {
                return 0, false
            }

            return uintptr(address), true
        }

        delete(fields)
    }

    return 0, false
}

// Verify that the ELF contains no undefined symbols.
@(test)
no_undefined_symbols :: proc(t: ^testing.T) {
    command := []string{
        "arm-none-eabi-nm",
        "-u",
        FIRMWARE_PATH,
    }

    state, stdout, stderr, err := os.process_exec(
        {
            command = command,
        },
        context.allocator,
    )
    defer delete(stdout)
    defer delete(stderr)

    testing.expect(t, err == nil)

    if err != nil {
        return
    }

    testing.expect(t, state.success)

    if !state.success {
        return
    }

    testing.expect_value(t, len(stdout), 0)
}

// Verify that the vector table starts at the beginning of flash.
@(test)
vector_table_address :: proc(t: ^testing.T) {
    address, ok := get_symbol_address("vector_table")

    testing.expect(t, ok)

    if ok {
        testing.expect_value(t, address, uintptr(0x08000000))
    }
}

// Verify that the initial stack pointer points to the end of DTCM.
@(test)
stack_address :: proc(t: ^testing.T) {
    address, ok := get_symbol_address("_estack")

    testing.expect(t, ok)

    if ok {
        testing.expect_value(t, address, uintptr(0x20010000))
    }
}

// Verify that the reset handler is linked into the firmware.
@(test)
reset_handler_exists :: proc(t: ^testing.T) {
    _, ok := get_symbol_address("Reset_Handler")
    testing.expect(t, ok)
}

// Verify that the application entry point is linked into the firmware.
@(test)
embedded_main_exists :: proc(t: ^testing.T) {
    _, ok := get_symbol_address("embedded_main")
    testing.expect(t, ok)
}
