# Go-like flags in Odin

This a very simple implementation of Go-like flags in Odin

## Usage

```odin
	defer myflag.destroy()
	isRunning: bool
	isNumber: int
	isString: string

	myflag.BoolVar(&isRunning, "isRunning", true, "A select piece of code is running!")
	myflag.IntVar(&isNumber, "isNumber", 3434, "A number!")
	myflag.StringVar(&isString, "isString", "Hellope!", "A string!")

	myflag.parse_flags()
```