package myflag

import "core:strconv"
import "core:strings"
import "core:os"
import "core:fmt"
import "base:runtime"

Flag_Value_Ptr :: union{
	^bool,
	^int, 
	^string, 	
}	

Flag :: struct {
	name: string,
	value: Flag_Value_Ptr,
	usage: string,
	parsed: bool, // sck: flag to check if it has been parsed
}

all_flags: [dynamic]Flag


// sck: Used to create a customer allocator
init_custom_allocator :: proc(allocator: runtime.Allocator){
	// sck: make sure to destory the old allocations
	destroy()
	all_flags = make([dynamic]Flag, allocator = allocator)
}

destroy :: proc(){
	delete(all_flags)
	all_flags = {} // sck: needed?
}

print_flags :: proc(){
	for f in all_flags{
		fmt.printfln("%s: %v: %s", f.name, f.value, f.usage)
	}
}

print_usage :: proc(){
	fmt.println("\tUsage: ")
	for f in all_flags {
    switch v in f.value {
	    case ^bool:
	        fmt.printfln("\t-%s:\n\t\t%s (default: %v)\n",
	            f.name, f.usage, v^)

	    case ^int:
	        fmt.printfln("\t-%s:\n\t\t%s (default: %d)\n",
	            f.name, f.usage, v^)

	    case ^string:
	        fmt.printfln("\t-%s:\n\t\t%s (default: %s)\n",
	            f.name, f.usage, v^)
	    }
	}
	os.exit(0)
}

BoolVar :: proc(ptr: ^bool, name: string, default: bool, usage: string) {
    ptr^ = default

    append(&all_flags, Flag{
        name = name,
        value = ptr,
        usage = usage,
    })
}

IntVar :: proc(ptr: ^int, name: string, default: int, usage: string) {
    ptr^ = default

    append(&all_flags, Flag{
        name = name,
        value = ptr,
        usage = usage,
    })
}

StringVar :: proc(ptr: ^string, name: string, default: string, usage: string) {
    ptr^ = default

    append(&all_flags, Flag{
        name = name,
        value = ptr,
        usage = usage,
    })
}
parse_flags :: proc (){
	if len(os.args) < 2 { print_usage() }

	for &a in os.args {
		if a == "-help" || a == "--help"{ print_usage() } 	
		if a == os.args[0] { continue }

		for &f in all_flags {
			a = strings.trim_prefix(a, "-") 

			name := a
			value: string

			split := strings.index_any(a, "=")
			if split >= 0 {
				name = a[:split]
				value = a[split+1:]
			}

			if name == f.name && !f.parsed{
				f.parsed = true
				switch &v in f.value {
					case ^bool: 
					parsed, ok := strconv.parse_bool(value)	
					if !ok {
						//error
					}
					v^ = parsed

					case ^int:
					parsed, ok := strconv.parse_int(value)
					if !ok {
						fmt.fprintfln(os.stderr, "[ERROR] Failed to parsed flag %s:%s", f.name, ok)
					}
					v^ = parsed

					case ^string:
					// TODO: validate string
					v^ = value
				}
			}
		}
	}

	/*
	fmt.println("[INFO] parsed flags: ")
	for f in all_flags{
		if f.parsed == true{
			fmt.println(f.name)
			fmt.println(f.value)
		}
	}
	*/
}
