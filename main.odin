package flag

import "core:fmt"
import vmem "core:mem/virtual"
import "myflag"

main :: proc(){
	/*
	arena: vmem.Arena
	arena_err := vmem.arena_init_growing(&arena)
	ensure(arena_err == nil)
	arena_alloc := vmem.arena_allocator(&arena)
	defer vmem.arena_destroy(&arena) //clean

	myflag.init_custom_allocator(arena_alloc)
	*/

	defer myflag.destroy()
	isRunning: bool
	isNumber: int
	isString: string
	isFloat: f32

	myflag.BoolVar(&isRunning, "isRunning", true, "A select piece of code is running!")
	myflag.IntVar(&isNumber, "isNumber", 3434, "A number!")
	myflag.StringVar(&isString, "isString", "Hellope!", "A string!")
	myflag.Float32Var(&isFloat, "isFloat", 3.1415, "A float!")
	myflag.parse_flags()

	fmt.println("-------MAIN--------")
	fmt.println(isRunning)
	fmt.println(isNumber)
	fmt.println(isString)
	fmt.println(isFloat)
	fmt.println("-------MAIN--------")
}