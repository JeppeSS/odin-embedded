package main

import "core:fmt"
import "core:os"
import "core:strings"
import "core:path/filepath"

main :: proc() {
	args := os.args

	if len(args) < 2 {
		print_usage()
		return
	}

	command := args[1]

	switch command {
	case "build":
		build()
		break

	case "test":
		test()
		break

	case "flash":
		flash()
		break

	case "help":
		print_usage()
		break

	case "version":
		fmt.println("ode 0.1.0")
		break

	case:
		fmt.eprintf("Unknown command: %s\n\n", command)
		print_usage()
	}
}


print_usage :: proc() {
	fmt.println("ode - Odin embedded development tool")
	fmt.println()
	fmt.println("Usage:")
	fmt.println("  ode <command>")
	fmt.println()
	fmt.println("Commands:")
	fmt.println("  build      Build firmware")
	fmt.println("  flash      Flash firmware")
	fmt.println("  test       Test project")
	fmt.println("  help       Show this help")
	fmt.println("  version    Show version")
}

build :: proc() {
	fmt.println("Building minimal firmware...")

	err_create_dir := os.make_directory_all("build")
	if err_create_dir != nil {
		fmt.eprintf("Failed to create build directory: %v\n", err_create_dir)
		os.exit(1)
	}

	command := []string{
	    "odin",
	    "build",
	    "examples/minimal",
	    "-target:freestanding_arm32",
	    "-microarch:cortex-m7",
	    "-build-mode:object",
	    "-no-crt",
	    "-no-entry-point",
	    "-no-rtti",
	    "-disable-unwind",
		"-collection:embedded=src",
	    "-out:build/minimal.o",
	}

	state, stdout, stderr, err := os.process_exec(
		os.Process_Desc{
			command = command,
		},
		context.allocator,
	)

	defer delete(stdout)
	defer delete(stderr)

	if err != nil {
		fmt.eprintf("Failed to run Odin compiler: %v\n", err)
		os.exit(1)
	}

	if len(stdout) > 0 {
		fmt.printf("%s", stdout)
	}

	if len(stderr) > 0 {
		fmt.eprintf("%s", stderr)
	}

	if !state.success {
		fmt.eprintf("Build failed with exit code %d\n", state.exit_code)
		os.exit(state.exit_code)
	}


	fmt.println("Assembling Cortex-M7 startup...")

	assemble_command := []string{
		"arm-none-eabi-gcc",
		"-mcpu=cortex-m7",
		"-mthumb",
		"-c",
		"src/arch/arm/cortex_m7/startup.s",
		"-o",
		"build/startup.o",
	}


	assemble_state, assemble_stdout, assemble_stderr, assemble_err :=
		os.process_exec(
			os.Process_Desc{
				command = assemble_command,
			},
			context.allocator,
		)

	defer delete(assemble_stdout)
	defer delete(assemble_stderr)

	if assemble_err != nil {
		fmt.eprintf("Failed to run assembler: %v\n", assemble_err)
		os.exit(1)
	}

	if len(assemble_stdout) > 0 {
		fmt.printf("%s", assemble_stdout)
	}

	if len(assemble_stderr) > 0 {
		fmt.eprintf("%s", assemble_stderr)
	}

	if !assemble_state.success {
		fmt.eprintf(
			"Assembly failed with exit code %d\n",
			assemble_state.exit_code,
		)
		os.exit(assemble_state.exit_code)
	}

	entries, err_read_dir := os.read_directory_by_path("build", 0, context.allocator)
	if err_read_dir != nil {
	    fmt.eprintf("Failed to read build directory: %v\n", err_read_dir)
	    os.exit(1)
	}
	defer delete(entries)

	object_files := make([dynamic]string)
	defer delete(object_files)

	for entry in entries {
    	name := entry.name
	    if strings.has_prefix(name, "minimal-") &&
	       strings.has_suffix(name, ".o") {
			joined, err_join := filepath.join({"build", name})
			if err_join != nil {
    			fmt.eprintf("Failed to join file path: %v\n", err_join)
			}
	        append(&object_files, joined)
	    }
	}

	link_command := make([dynamic]string)
	defer delete(link_command)

	append(&link_command,
	    "arm-none-eabi-gcc",
	    "-mcpu=cortex-m7",
	    "-mthumb",
	    "-nostartfiles",
	    "-T",
	    "src/mcu/stm32f756/linker.ld",
	    "-Wl,--gc-sections",
	    "-Wl,-z,noexecstack",
	    "build/startup.o",
	)

	for object_file in object_files {
    	append(&link_command, object_file)
	}

	append(&link_command,
	    "-o",
	    "build/firmware.elf",
		"-Wl,-Map=build/firmware.map",
	    "-lgcc",
	)

	fmt.println("Linking firmware...")

	link_state, link_stdout, link_stderr, link_err :=
    os.process_exec(
        os.Process_Desc{
            command = link_command[:],
        },
        context.allocator,
    )

	defer delete(link_stdout)
	defer delete(link_stderr)

	if link_err != nil {
	    fmt.eprintf("Failed to run linker: %v\n", link_err)
	    os.exit(1)
	}

	if len(link_stdout) > 0 {
	    fmt.printf("%s", link_stdout)
	}

	if len(link_stderr) > 0 {
	    fmt.eprintf("%s", link_stderr)
	}

	if !link_state.success {
	    fmt.eprintf(
	        "Linking failed with exit code %d\n",
	        link_state.exit_code,
	    )
	    os.exit(link_state.exit_code)
	}

	fmt.println("Build completed")
}


test :: proc() {
	fmt.println("Testing firmware...")
}

flash :: proc() {
	fmt.println("Flashing firmware...")

	command := []string{
		"openocd",
		"-f",
		"interface/stlink.cfg",
		"-f",
		"target/stm32f7x.cfg",
		"-c",
		"program build/firmware.elf verify reset exit",
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
		fmt.eprintln("Failed to start OpenOCD:", err)
		os.exit(1)
	}

	if !state.success {
		fmt.eprintln("Failed to flash firmware:")
		fmt.eprintln(string(stderr))
		os.exit(1)
	}

	fmt.println("Firmware flashed successfully")
}
