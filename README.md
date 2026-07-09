# Go-like flags in Odin

This a very simple implementation of Go-like flags in Odin

## How to use

```odin
	import "fleg"

	isRunning: bool
	isNumber: int
	isString: string
	isFloat: f32

	fleg.BoolVar(&isRunning, "isRunning", true, "A select piece of code is running!")
	fleg.IntVar(&isNumber, "isNumber", 3434, "A number!")
	fleg.StringVar(&isString, "isString", "Hellope!", "A string!")
	fleg.Float32Var(&isFloat, "isFloat", 3.1415, "A float!")

	fleg.parse_flags()
```

You can also marks flags as **required"**. These will still be parsed, however will hault the application until they are passed:

```odin
	import "fleg"
	isRunning: bool
	fleg.BoolVar(&isRunning, "isRunning", true, "A select piece of code is running!", required = true)
	fleg.parse_flags()
```

***Supports: bool, int, string, f32***

And on the command line, you pass flags like so:

```bash
./<program name> -isNumber=45 -isRunning=false ......
```

## Help flag:

The package also contains a help context menu. This comes default and can be called like so (**Note:** You can also use "-h" or "--help"):

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

## Custom Flag Format

A custom flag format can be created by overwriting the strings *FLAG_START_CHAR* and *FLAG_SEP_CHAR*. (These *cannot* be the same however!)

```odin
	fleg.FLAG_START_CHAR = "--"
	fleg.FLAG_SEP_CHAR = ":"
```

Flags will now be in the format:

```txt
	--isString:"......"
```

**Note:** Any change to the format of the flags is also relfected upon the "help" flag.

## Custom Allocator

If needed, you are able to setup a custom allocator like so:

```odin 
	arena: vmem.Arena
	arena_err := vmem.arena_init_growing(&arena)
	ensure(arena_err == nil)
	arena_alloc := vmem.arena_allocator(&arena)
	defer vmem.arena_destroy(&arena)

	fleg.init_custom_allocator(arena_alloc)
	defer fleg.destroy() //clean up flags
```

## TODO

* More type support
* Better logging of INFO and ERROR's
* String validation (perhaps not needed?)
* Array support (e.g. **--isArray:{4,5,6,7}**)