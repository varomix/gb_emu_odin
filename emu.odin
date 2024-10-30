package mix_gbemu

import "core:fmt"
import sdl "vendor:sdl2"
import ttf "vendor:sdl2/ttf"

/*
  Emu components:

  |Cart|
  |CPU|
  |Address Bus|
  |PPU|
  |Timer|

*/

emu_context :: struct {
	paused:  bool,
	running: bool,
	ticks:   u64,
}


emu_ctx: emu_context

emu_get_context :: proc() -> ^emu_context {
	return &emu_ctx
}

delay :: proc(ms: u32) {
	sdl.Delay(ms)
}

emu_run :: proc(args: []string) -> int {
	if len(args) < 2 {
		fmt.printf("Usage: emu <rom_file>\n")
		return -1
	}

	if !cart_load(args[1]) {
		fmt.printf("Failed to load ROM file: %s\n", args[1])
		return -2
	}

	fmt.printf("Cart loaded..\n")

	sdl.Init(sdl.INIT_VIDEO)
	fmt.printf("SDL INIT\n")
	ttf.Init()
	fmt.printf("TTF INIT\n")

	cpu_init()

	emu_ctx.running = true
	emu_ctx.paused = false
	emu_ctx.ticks = 0

	for emu_ctx.running {
		if emu_ctx.paused {
			delay(10)
			continue
		}

		if !cpu_step() {
			fmt.printf("CPU Stopped\n")
			return -3
		}

		emu_ctx.ticks += 1
	}

	return 0
}
