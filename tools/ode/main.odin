package main

import "core:fmt"
import "core:os"


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

	fmt.println("Build completed")
}
