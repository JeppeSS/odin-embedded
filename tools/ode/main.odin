
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
        if len(args) != 3 {
            fmt.eprintln("Usage: ode build <project>")
            os.exit(1)
        }

        build(args[2])

    case "flash":
        if len(args) != 3 {
            fmt.eprintln("Usage: ode flash <project>")
            os.exit(1)
        }

        flash(args[2])

    case "test":
        test()

    case "help":
        print_usage()

    case "version":
        fmt.println("ode 0.2.0")

    case:
        fmt.eprintf("Unknown command: %s\n\n", command)
        print_usage()
        os.exit(1)
    }
}

// print_usage displays the available commands.
print_usage :: proc() {
    fmt.println("ode - Odin embedded development tool")
    fmt.println()
    fmt.println("Usage:")
    fmt.println("  ode <command> [project]")
    fmt.println()
    fmt.println("Commands:")
    fmt.println("  build <project>    Build firmware")
    fmt.println("  flash <project>    Flash firmware")
    fmt.println("  test               Test project")
    fmt.println("  help               Show this help")
    fmt.println("  version            Show version")
}

// project_name returns the final directory component.
//
// Examples:
//   examples/minimal -> minimal
//   examples/blink   -> blink
project_name :: proc(path: string) -> string {
    normalized := strings.trim_right(path, "/")
    _, name := filepath.split(normalized)
    return name
}

// join_path joins two path components.
//
// Exits if the path cannot be constructed.
join_path :: proc(a, b: string) -> string {
    result, err := filepath.join({a, b})

    if err != nil {
        fmt.eprintf("Failed to construct path: %v\n", err)
        os.exit(1)
    }

    return result
}

// project_build_dir returns the output directory for a project.
project_build_dir :: proc(project: string) -> string {
    return join_path("build", project_name(project))
}

// run_command executes a process and exits if it fails.
run_command :: proc(command: []string, description: string) {
    fmt.println(description)

    state, stdout, stderr, err := os.process_exec(
        os.Process_Desc{
            command = command,
        },
        context.allocator,
    )

    defer delete(stdout)
    defer delete(stderr)

    if err != nil {
        fmt.eprintf("Failed to start process: %v\n", err)
        os.exit(1)
    }

    if len(stdout) > 0 {
        fmt.printf("%s", stdout)
    }

    if len(stderr) > 0 {
        fmt.eprintf("%s", stderr)
    }

    if !state.success {
        fmt.eprintf(
            "Command failed with exit code %d\n",
            state.exit_code,
        )
        os.exit(1)
    }
}

// build compiles, assembles, and links a firmware project.
//
// Build artifacts are stored in build/<project-name>/.
build :: proc(project: string) {
    name := project_name(project)
    build_dir := project_build_dir(project)

    fmt.printf("Building project: %s\n", project)

    // Create the project-specific build directory.
    // An existing directory is not an error.
    err_create := os.make_directory_all(build_dir)

    if err_create != nil && err_create != .Exist {
        fmt.eprintf(
            "Failed to create build directory: %v\n",
            err_create,
        )
        os.exit(1)
    }

    // Remove previously generated Odin object files.
    //
    // Odin may generate multiple object files, so stale files
    // must not be included in subsequent builds.
    entries, err_read := os.read_directory_by_path(
        build_dir,
        0,
        context.allocator,
    )

    if err_read != nil {
        fmt.eprintf(
            "Failed to read build directory: %v\n",
            err_read,
        )
        os.exit(1)
    }
    defer delete(entries)

    object_prefix := fmt.tprintf("%s-", name)

    for entry in entries {
        if strings.has_prefix(entry.name, object_prefix) &&
           strings.has_suffix(entry.name, ".o") {
            object_path := join_path(build_dir, entry.name)

            err_remove := os.remove(object_path)

            if err_remove != nil {
                fmt.eprintf(
                    "Failed to remove stale object file %s: %v\n",
                    object_path,
                    err_remove,
                )
                os.exit(1)
            }
        }
    }

    // Compile the Odin project.
    object_path := join_path(
        build_dir,
        fmt.tprintf("%s.o", name),
    )

    compile_command := []string{
        "odin",
        "build",
        project,
        "-target:freestanding_arm32",
        "-microarch:cortex-m7",
        "-build-mode:object",
        "-no-crt",
        "-no-entry-point",
        "-no-rtti",
        "-disable-unwind",
        "-collection:embedded=src",
        fmt.tprintf("-out:%s", object_path),
    }

    run_command(
        compile_command,
        "Compiling Odin sources...",
    )

    // Assemble Cortex-M7 startup code.
    startup_path := join_path(build_dir, "startup.o")

    assemble_command := []string{
        "arm-none-eabi-gcc",
        "-mcpu=cortex-m7",
        "-mthumb",
        "-c",
        "src/arch/arm/cortex_m7/startup.s",
        "-o",
        startup_path,
    }

    run_command(
        assemble_command,
        "Assembling Cortex-M7 startup...",
    )

    // Find all generated Odin object files.
    generated_entries, err_generated := os.read_directory_by_path(
        build_dir,
        0,
        context.allocator,
    )

    if err_generated != nil {
        fmt.eprintf(
            "Failed to read generated object files: %v\n",
            err_generated,
        )
        os.exit(1)
    }
    defer delete(generated_entries)

    object_files := make([dynamic]string)
    defer delete(object_files)

    for entry in generated_entries {
        if strings.has_prefix(entry.name, object_prefix) &&
           strings.has_suffix(entry.name, ".o") {
            append(
                &object_files,
                join_path(build_dir, entry.name),
            )
        }
    }

    if len(object_files) == 0 {
        fmt.eprintln("No Odin object files were generated.")
        os.exit(1)
    }

    // Define firmware output paths.
    firmware_path := join_path(build_dir, "firmware.elf")
    map_path := join_path(build_dir, "firmware.map")

    // Link firmware.
    link_command := make([dynamic]string)
    defer delete(link_command)

    append(
        &link_command,
        "arm-none-eabi-gcc",
        "-mcpu=cortex-m7",
        "-mthumb",
        "-nostartfiles",
        "-T",
        "src/mcu/stm32f756/linker.ld",
        "-Wl,--gc-sections",
        "-Wl,-z,noexecstack",
        startup_path,
    )

    for object_file in object_files {
        append(&link_command, object_file)
    }

    append(
        &link_command,
        "-o",
        firmware_path,
        fmt.tprintf("-Wl,-Map=%s", map_path),
        "-lgcc",
    )

    run_command(
        link_command[:],
        "Linking firmware...",
    )

    fmt.printf("Build completed: %s\n", firmware_path)
}

// test runs the project's tests.
//
// Test execution will be implemented separately.
test :: proc() {
    fmt.println("Testing firmware...")
}

// flash programs a previously built firmware onto the MCU.
flash :: proc(project: string) {
    build_dir := project_build_dir(project)
    firmware_path := join_path(build_dir, "firmware.elf")

    fmt.printf("Flashing project: %s\n", project)

    // Verify that the firmware exists before invoking OpenOCD.
    _, stat_err := os.stat(firmware_path, context.allocator)

    if stat_err != nil {
        fmt.eprintf(
            "Firmware not found: %s\nBuild the project first.\n",
            firmware_path,
        )
        os.exit(1)
    }

    flash_command := []string{
        "openocd",
        "-f",
        "interface/stlink.cfg",
        "-f",
        "target/stm32f7x.cfg",
        "-c",
        fmt.tprintf(
            "program %s verify reset exit",
            firmware_path,
        ),
    }

    run_command(
        flash_command,
        "Flashing firmware...",
    )

    fmt.println("Firmware flashed successfully")
}
