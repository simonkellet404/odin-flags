/*
zlib License

(C) 2026 Simon Kellet

This software is provided 'as-is', without any express or implied
warranty. In no event will the authors be held liable for any damages
arising from the use of this software.

Permission is granted to anyone to use this software for any purpose,
including commercial applications, and to alter it and redistribute it
freely, subject to the following restrictions:

1. The origin of this software must not be misrepresented; you must not
   claim that you wrote the original software. If you use this software
   in a product, an acknowledgment in the product documentation would be
   appreciated but is not required.
2. Altered source versions must be plainly marked as such, and must not be
   misrepresented as being the original software.
3. This notice may not be removed or altered from any source distribution.
*/

#+vet explicit-allocators
package fleg

import "base:runtime"
import "core:fmt"
import "core:os"
import "core:strconv"
import "core:strings"

FORCE_HELP_ON_EMPTY_ARGS := false
FLAG_START_CHAR := "-"
FLAG_SEP_CHAR := "="

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
	parsed: bool,   // sck: flag to check if it has been parsed
	required: bool, // sck: required flag
}

// Global dynamic array of Flags
all_flags: [dynamic]Flag

// runtime allocator for the flags
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
		fmt.printfln("%s: %s (required=%v)", f.name, f.usage, f.required)
	}
}

print_flag_format :: proc(){
	fmt.printfln("Want %s<flag>%s<value>\n", FLAG_START_CHAR, FLAG_SEP_CHAR)
}

print_usage :: proc() {
	fmt.println("\tUsage: ")
	fmt.println("\n\tFlag format for this program:")
	fmt.printfln("\t%s<flag>%s<value>\n", FLAG_START_CHAR, FLAG_SEP_CHAR)

	for f in all_flags {
		req_msg: string
		if f.required { req_msg = " (required)"}
		switch v in f.value {

		case ^bool:
			fmt.printfln("\t%s%s:\n\t\t%s (default: %v)%s\n", FLAG_START_CHAR, f.name, f.usage, v^, req_msg)
		case ^int:
			fmt.printfln("\t%s%s:\n\t\t%s (default: %d)%s\n", FLAG_START_CHAR, f.name, f.usage, v^, req_msg)
		case ^string:
			fmt.printfln("\t%s%s:\n\t\t%s (default: %s)%s\n", FLAG_START_CHAR, f.name, f.usage, v^, req_msg)
		case ^f32:
			fmt.printfln("\t%s%s:\n\t\t%s (default: %f)%s\n", FLAG_START_CHAR, f.name, f.usage, v^, req_msg)
		case ^f64:
			fmt.printfln("\t%s%s:\n\t\t%s (default: %f)%s\n", FLAG_START_CHAR, f.name, f.usage, v^, req_msg)
		}
	}
}

BoolVar :: proc(ptr: ^bool, name: string, default: bool, usage: string, required := false) {
	ptr^ = default
	append(&all_flags, Flag{name = name, value = ptr, usage = usage, required = required})
}

IntVar :: proc(ptr: ^int, name: string, default: int, usage: string, required := false) {
	ptr^ = default
	append(&all_flags, Flag{name = name, value = ptr, usage = usage, required = required})
}

StringVar :: proc(ptr: ^string, name: string, default: string, usage: string, required := false) {
	ptr^ = default
	append(&all_flags, Flag{name = name, value = ptr, usage = usage, required = required})
}

Float32Var :: proc(ptr: ^f32, name: string, default: f32, usage: string, required := false) {
	ptr^ = default
	append(&all_flags, Flag{name = name, value = ptr, usage = usage, required = required})
}

Float64Var :: proc(ptr: ^f64, name: string, default: f64, usage: string, required := false) {
	ptr^ = default
	append(&all_flags, Flag{name = name, value = ptr, usage = usage, required = required})
}

parse_flags :: proc() {
	defer destroy()
	// sck: We cannot have the start and seperator formats being the same
	if FLAG_START_CHAR == FLAG_SEP_CHAR {
		fmt.println("[ERROR]: FLAG_START_CHAR and FLAG_SEP_CHAR cannot be the same!")
		fmt.printfln("\t FLAG_START_CHAR= \"%s\"\t FLAG_SEP_CHAR= \"%s\"", FLAG_START_CHAR, FLAG_SEP_CHAR)
		os.exit(1)
	}
	if len(os.args) < 2 && FORCE_HELP_ON_EMPTY_ARGS {print_usage()}

	// sck: skip the first arg
	for &a in os.args[1:] {
		if a == "-h" || a == "-help" || a == "--help" {print_usage(); os.exit(0)}
		// sck: if the user has a custom flag format, copy that to the help flag too.
		if a == fmt.aprintf("%s%s", FLAG_START_CHAR, "help", allocator = flag_allocator) {print_usage(); os.exit(0)}
		if a == fmt.aprintf("%s%s", FLAG_START_CHAR, "h", allocator = flag_allocator) {print_usage(); os.exit(0)}

		// Begin parsing flags...
		for &f in all_flags {
			if f.parsed {continue}

			a = strings.trim_prefix(a, FLAG_START_CHAR)
			name := a
			value: string

			split := strings.index_any(a, FLAG_SEP_CHAR)
			if split >= 0 {
				name = a[:split]
				value = a[split + 1:]
			} else {
				name = a
				fmt.printf("[INFO]: Could not read flag: %s. ", name)
				print_flag_format()
				break
			}

			// sck: We are going to parse all the flags
			if name == f.name && !f.parsed {
				f.parsed = true
				switch &v in f.value {
				case ^bool:
					if value == "" {break}
					parsed, ok := strconv.parse_bool(value)
					if !ok {
						fmt.fprintfln(os.stderr, "[ERROR] Failed to parse flag %s: got %T, wanted bool",
							f.name, value)
						os.exit(1)
					}
					v^ = parsed

				case ^int:
					if value == "" {break}
					parsed, ok := strconv.parse_int(value)
					if !ok {
						fmt.fprintfln(os.stderr, "[ERROR] Failed to parse flag %s: got %T, wanted int",
							f.name, value)
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
						fmt.fprintfln(os.stderr, "[ERROR] Failed to parse flag %s: got %T, wanted f32",
						 	f.name, value)
						os.exit(1)
					}
					v^ = parsed

				case ^f64:
					if value == "" {break}
					parsed, ok := strconv.parse_f64(value)
					if !ok {
						fmt.fprintfln(os.stderr, "[ERROR] Failed to parse flag %s: got %T, wanted f64",
							f.name, value)
						os.exit(1)
					}
					v^ = parsed
				}
			}
		}
	}

	for f in all_flags {
	   if f.required && !f.parsed {
	   	fmt.fprintfln(os.stderr, "[ERROR] Missing required flag: %s%s", FLAG_START_CHAR, f.name)
	   	fmt.fprintfln(os.stderr, "use -help or -h to view all flags")
	      //print_usage()
	      os.exit(1)
	    }
	 }
}
