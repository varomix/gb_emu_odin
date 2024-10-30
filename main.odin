package mix_gbemu

import "core:fmt"
import "core:os"

main :: proc() {
	emu_run(os.args)
}
