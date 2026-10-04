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
	fmt.println("  help       Show this help")
	fmt.println("  version    Show version")
}
