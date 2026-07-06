# Go-like flags in Odin

This a very simple implementation of Go-like flags in Odin

## How to use

```odin
	import "myflag"

	isRunning: bool
	isNumber: int
	isString: string
	isFloat: f32

	myflag.BoolVar(&isRunning, "isRunning", true, "A select piece of code is running!")
	myflag.IntVar(&isNumber, "isNumber", 3434, "A number!")
	myflag.StringVar(&isString, "isString", "Hellope!", "A string!")
	myflag.Float32Var(&isFloat, "isFloat", 3.1415, "A float!")

	myflag.parse_flags()
```

***Supports: bool, int, string, f32***

And on the command line, you pass flags like so:

```bash
./<program name> -isNumber=45 -isRunning=false ......
```

## Usage flag: -help

The package also contains a help context menu. This comes default and can be called like so

```txt
./<program name> -help

	Usage:
	-isRunning:
		A select piece of code is running! (default: true)

	-isNumber:
		A number! (default: 3434)

	-isString:
		A string! (default: Hellope!)

	-isFloat:
		A float! (default: 3.141)

```

**Note:** You can set the boolean *FORCE_HELP_ON_EMPTY_ARGS* to allow for the help context menu to be displayed when no arguments are passed

## Custom Allocator

If needed, you are able to setup a custom allocator like so:

```odin 
	arena: vmem.Arena
	arena_err := vmem.arena_init_growing(&arena)
	ensure(arena_err == nil)
	arena_alloc := vmem.arena_allocator(&arena)
	defer vmem.arena_destroy(&arena)

	myflag.init_custom_allocator(arena_alloc)
	defer myflag.destroy() //clean up flags
```