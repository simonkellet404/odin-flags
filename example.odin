package main

import "core:fmt"
import vmem "core:mem/virtual"
import "fleg"

main :: proc(){
	/*
	arena: vmem.Arena
	arena_err := vmem.arena_init_growing(&arena)
	ensure(arena_err == nil)
	arena_alloc := vmem.arena_allocator(&arena)
	defer vmem.arena_destroy(&arena) //clean

	fleg.init_custom_allocator(arena_alloc)
	defer fleg.destroy()
	*/

	fleg.FLAG_START_CHAR = ":"
	fleg.FLAG_SEP_CHAR = "="
	//fleg.FORCE_HELP_ON_EMPTY_ARGS = true

	defer fleg.destroy()
	isRunning: bool
	isNumber: int
	isString: string
	isFloat: f32

	fleg.BoolVar(&isRunning, "isRunning", false, "A select piece of code is running!", required = true)
	fleg.IntVar(&isNumber, "isNumber", 3434, "A number!", required = true)
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