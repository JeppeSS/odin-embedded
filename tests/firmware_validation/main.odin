package main

import "core:fmt"
import "core:os"
import "core:strconv"
import "core:strings"

get_symbol_address :: proc(name: string) -> (uintptr, bool) {
	command := []string{
		"arm-none-eabi-nm",
		"--defined-only",
		"build/firmware.elf",
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

	for line in strings.split_lines(output) {
		fields := strings.fields(line)

		if len(fields) != 3 {
			continue
		}

		if fields[2] != name {
			continue
		}

		address, ok := strconv.parse_uint(fields[0], 16)
		if !ok {
			return 0, false
		}

		return uintptr(address), true
	}

	return 0, false
}

require_symbol :: proc(name: string) -> uintptr {
	address, ok := get_symbol_address(name)

	if !ok {
		fmt.eprintf("Could not find symbol: %s\n", name)
		os.exit(1)
	}

	return address
}

main :: proc() {
	fmt.println("Validating firmware...")

	command := []string{
		"arm-none-eabi-nm",
		"-u",
		"build/firmware.elf",
	}

	state, stdout, stderr, err := os.process_exec(
		{
			command = command,
		},
		context.allocator,
	)
	defer delete(stdout)
	defer delete(stderr)

	if err != nil {
		fmt.eprintln("Failed to inspect firmware:", err)
		os.exit(1)
	}

	if !state.success {
		fmt.eprintln("arm-none-eabi-nm failed:")
		fmt.eprintln(string(stderr))
		os.exit(1)
	}

	if len(stdout) != 0 {
		fmt.eprintln("Firmware contains undefined symbols:")
		fmt.eprintln(string(stdout))
		os.exit(1)
	}

	fmt.println("No undefined symbols")

	vector_table := require_symbol("vector_table")

	if vector_table != 0x08000000 {
		fmt.eprintf(
			"vector_table has incorrect address: 0x%08x\n",
			vector_table,
		)
		os.exit(1)
	}

	fmt.println("vector_table address is correct")

	estack := require_symbol("_estack")

	if estack != 0x20010000 {
		fmt.eprintf(
			"_estack has incorrect address: 0x%08x\n",
			estack,
		)
		os.exit(1)
	}

	fmt.println("_estack address is correct")

	require_symbol("Reset_Handler")
	fmt.println("Reset_Handler exists")

	require_symbol("embedded_main")
	fmt.println("embedded_main exists")

	fmt.println("Firmware validation passed")
}
