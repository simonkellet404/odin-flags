package main

import "core:fmt"
import "fleg"

main :: proc(){
	/*
	arena: vmem.Arena
	arena_err := vmem.arena_init_growing(&arena)
	ensure(arena_err == nil)
	arena_alloc := vmem.arena_allocator(&arena)
	defer vmem.arena_destroy(&arena) //clean

	fleg.init_custom_allocator(arena_alloc)
	*/

	fleg.FLAG_START_CHAR = ":"
	fleg.FLAG_SEP_CHAR = "="
	//fleg.FORCE_HELP_ON_EMPTY_ARGS = true

	defer fleg.destroy()
	isRunning: bool
	isNumber: int
	isString: string
	isFloat: f32

	fleg.BoolVar(&isRunning, "isRunning", true, "A select piece of code is running!")
	fleg.IntVar(&isNumber, "isNumber", 3434, "A number!")
	fleg.StringVar(&isString, "isString", "Hellope!", "A string!")
	fleg.Float32Var(&isFloat, "isFloat", 3.1415, "A float!")
	fleg.parse_flags()

	fmt.println("-------MAIN--------")
	fmt.println(isRunning)
	fmt.println(isNumber)
	fmt.println(isString)
	fmt.println(isFloat)
	fmt.println("-------MAIN--------")
}