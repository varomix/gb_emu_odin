package mix_gbemu

import "core:fmt"
import "core:os"

main :: proc() {

	// // cart_load("roms/cpu_instrs.gb")
	// // cart_load("/Users/varomix/dev/roms/GB/Tetris (World) (Rev A).gb")
	// cart_load(
	// 	"/Users/varomix/dev/roms/GB/Legend of Zelda, The - Link's Awakening (USA, Europe).gb",
	// )

	emu_run(os.args)


}
