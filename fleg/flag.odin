#+vet explicit-allocators
package fleg

import "base:runtime"
import "core:fmt"
import "core:os"
import "core:strconv"
import "core:strings"

FORCE_HELP_ON_EMPTY_ARGS := false

Flag_Value_Ptr :: union {
	^bool,
	^int,
	^string,
	^f32,
	^f64,
}

Flag :: struct {
	name:   string,
	value:  Flag_Value_Ptr,
	usage:  string,
	parsed: bool, // sck: flag to check if it has been parsed
}

all_flags: [dynamic]Flag
flag_allocator: runtime.Allocator

// sck: Used to create a customer allocator
init_custom_allocator :: proc(allocator: runtime.Allocator) {
	destroy() // sck: make sure to destory the old allocations

	flag_allocator = allocator
	all_flags = make([dynamic]Flag, flag_allocator)
}

destroy :: proc() {
	delete(all_flags)
	all_flags = {} // sck: needed?
}

print_flags :: proc() {
	for f in all_flags {
		fmt.printfln("%s: %v: %s", f.name, f.value, f.usage)
	}
}

print_usage :: proc() {
	fmt.println("\tUsage: ")
	for f in all_flags {
		switch v in f.value {
		case ^bool:
			fmt.printfln("\t-%s:\n\t\t%s (default: %v)\n", f.name, f.usage, v^)
		case ^int:
			fmt.printfln("\t-%s:\n\t\t%s (default: %d)\n", f.name, f.usage, v^)
		case ^string:
			fmt.printfln("\t-%s:\n\t\t%s (default: %s)\n", f.name, f.usage, v^)
		case ^f32:
			fmt.printfln("\t-%s:\n\t\t%s (default: %f)\n", f.name, f.usage, v^)
		case ^f64:
			fmt.printfln("\t-%s:\n\t\t%s (default: %f)\n", f.name, f.usage, v^)
		}
	}
	os.exit(0)
}

BoolVar :: proc(ptr: ^bool, name: string, default: bool, usage: string) {
	ptr^ = default
	append(&all_flags, Flag{name = name, value = ptr, usage = usage})
}

IntVar :: proc(ptr: ^int, name: string, default: int, usage: string) {
	ptr^ = default
	append(&all_flags, Flag{name = name, value = ptr, usage = usage})
}

StringVar :: proc(ptr: ^string, name: string, default: string, usage: string) {
	ptr^ = default
	append(&all_flags, Flag{name = name, value = ptr, usage = usage})
}

Float32Var :: proc(ptr: ^f32, name: string, default: f32, usage: string) {
	ptr^ = default
	append(&all_flags, Flag{name = name, value = ptr, usage = usage})
}

Float64Var :: proc(ptr: ^f64, name: string, default: f64, usage: string) {
	ptr^ = default
	append(&all_flags, Flag{name = name, value = ptr, usage = usage})
}

parse_flags :: proc() {
	if len(os.args) < 2 && FORCE_HELP_ON_EMPTY_ARGS {print_usage()}

	for &a in os.args {
		if a == "-help" || a == "--help" {print_usage()}
		if a == os.args[0] {continue}

		for &f in all_flags {
			if f.parsed {continue}
			a = strings.trim_prefix(a, "-")

			name := a
			value: string

			split := strings.index_any(a, "=")
			if split >= 0 {
				name = a[:split]
				value = a[split + 1:]
			} else {
				name = a
			}

			if name == f.name && !f.parsed {
				f.parsed = true
				switch &v in f.value {
				case ^bool:
					if value == "" {break}
					parsed, ok := strconv.parse_bool(value)
					if !ok {
						fmt.fprintfln(os.stderr, "[ERROR] Failed to parse flag %s: got %T, wanted bool", f.name, value)
						os.exit(1)
					}
					v^ = parsed

				case ^int:
					if value == "" {break}
					parsed, ok := strconv.parse_int(value)
					if !ok {
						fmt.fprintfln(os.stderr, "[ERROR] Failed to parse flag %s: got %T, wanted int", f.name, value)
						os.exit(1)
					}
					v^ = parsed

				case ^string:
					if value == "" {break}
					// TODO: validate string?
					v^ = value

				case ^f32:
					if value == "" {break}
					parsed, ok := strconv.parse_f32(value)
					if !ok {
						fmt.fprintfln(os.stderr, "[ERROR] Failed to parse flag %s: got %T, wanted f32", f.name, value)
						os.exit(1)
					}
					v^ = parsed

				case ^f64:
					if value == "" {break}
					parsed, ok := strconv.parse_f64(value)
					if !ok {
						fmt.fprintfln(os.stderr, "[ERROR] Failed to parse flag %s: got %T, wanted f64", f.name, value)
						os.exit(1)
					}
					v^ = parsed
				}
			}
		}
	}
}
