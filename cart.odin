package mix_gbemu

import "core:fmt"
import "core:os"


rom_header :: struct {
	entry:           [4]u8,
	logo:            [0x30]u8,
	title:           [16]u8,
	new_lic_code:    u16,
	sgb_flag:        u8,
	type:            u8,
	rom_size:        u8,
	ram_size:        u8,
	dest_code:       u8,
	lic_code:        u8,
	version:         u8,
	checksum:        u8,
	global_checksum: u16,
}

cart_ctx: cart_context

cart_context :: struct {
	filename: string,
	rom_size: int,
	rom_data: []u8,
	header:   rom_header,
}

ROM_TYPES := []string {
	"ROM ONLY",
	"MBC1",
	"MBC1+RAM",
	"MBC1+RAM+BATTERY",
	"0x04 ???",
	"MBC2",
	"MBC2+BATTERY",
	"0x07 ???",
	"ROM+RAM 1",
	"ROM+RAM+BATTERY 1",
	"0x0A ???",
	"MMM01",
	"MMM01+RAM",
	"MMM01+RAM+BATTERY",
	"0x0E ???",
	"MBC3+TIMER+BATTERY",
	"MBC3+TIMER+RAM+BATTERY 2",
	"MBC3",
	"MBC3+RAM 2",
	"MBC3+RAM+BATTERY 2",
	"0x14 ???",
	"0x15 ???",
	"0x16 ???",
	"0x17 ???",
	"0x18 ???",
	"MBC5",
	"MBC5+RAM",
	"MBC5+RAM+BATTERY",
	"MBC5+RUMBLE",
	"MBC5+RUMBLE+RAM",
	"MBC5+RUMBLE+RAM+BATTERY",
	"0x1F ???",
	"MBC6",
	"0x21 ???",
	"MBC7+SENSOR+RUMBLE+RAM+BATTERY",
}

LIC_CODE := [0xA5]string {
	0x00 = "None",
	0x01 = "Nintendo R&D1",
	0x08 = "Capcom",
	0x13 = "Electronic Arts",
	0x18 = "Hudson Soft",
	0x19 = "b-ai",
	0x20 = "kss",
	0x22 = "pow",
	0x24 = "PCM Complete",
	0x25 = "san-x",
	0x28 = "Kemco Japan",
	0x29 = "seta",
	0x30 = "Viacom",
	0x31 = "Nintendo",
	0x32 = "Bandai",
	0x33 = "Ocean/Acclaim",
	0x34 = "Konami",
	0x35 = "Hector",
	0x37 = "Taito",
	0x38 = "Hudson",
	0x39 = "Banpresto",
	0x41 = "Ubi Soft",
	0x42 = "Atlus",
	0x44 = "Malibu",
	0x46 = "angel",
	0x47 = "Bullet-Proof",
	0x49 = "irem",
	0x50 = "Absolute",
	0x51 = "Acclaim",
	0x52 = "Activision",
	0x53 = "American sammy",
	0x54 = "Konami",
	0x55 = "Hi tech entertainment",
	0x56 = "LJN",
	0x57 = "Matchbox",
	0x58 = "Mattel",
	0x59 = "Milton Bradley",
	0x60 = "Titus",
	0x61 = "Virgin",
	0x64 = "LucasArts",
	0x67 = "Ocean",
	0x69 = "Electronic Arts",
	0x70 = "Infogrames",
	0x71 = "Interplay",
	0x72 = "Broderbund",
	0x73 = "sculptured",
	0x75 = "sci",
	0x78 = "THQ",
	0x79 = "Accolade",
	0x80 = "misawa",
	0x83 = "lozc",
	0x86 = "Tokuma Shoten Intermedia",
	0x87 = "Tsukuda Original",
	0x91 = "Chunsoft",
	0x92 = "Video system",
	0x93 = "Ocean/Acclaim",
	0x95 = "Varie",
	0x96 = "Yonezawa/s'pal",
	0x97 = "Kaneko",
	0x99 = "Pack in soft",
	0xA4 = "Konami (Yu-Gi-Oh!)",
}

cart_lic_name :: proc() -> string {
	if (cart_ctx.header.lic_code <= 0xA4) {
		return LIC_CODE[cart_ctx.header.lic_code]
	}
	return "UNKNOWN"
}

cart_type_name :: proc() -> string {
	if cart_ctx.header.type < u8(len(ROM_TYPES)) {
		return ROM_TYPES[cart_ctx.header.type]
	}

	return "UNKNOWN"
}


cart_load :: proc(cart: string) -> bool {
	cart_ctx.filename = cart

	data, ok := os.read_entire_file(cart)
	if !ok {
		fmt.printf("Failed to open: %s\n", cart)
		return false
	}

	fmt.printf("Opened: %s\n", cart_ctx.filename)

	cart_ctx.rom_size = len(data)
	cart_ctx.rom_data = data

	header_ptr := transmute(^rom_header)&cart_ctx.rom_data[0x100]
	cart_ctx.header = header_ptr^
	cart_ctx.header.title[15] = 0

	fmt.printf("Cartridge Loaded:\n")
	fmt.printf("\t Title    : %s\n", string(cart_ctx.header.title[:]))
	fmt.printf("\t Type     : %2.2X (%s)\n", cart_ctx.header.type, cart_type_name())
	fmt.printf("\t ROM Size : %d KB\n", i32(32) << cart_ctx.header.rom_size)
	fmt.printf("\t RAM Size : %2.2X\n", cart_ctx.header.ram_size)
	fmt.printf("\t LIC Code : %2.2X (%s)\n", cart_ctx.header.lic_code, cart_lic_name())
	fmt.printf("\t ROM Vers : %2.2X\n", cart_ctx.header.version)

	// Header checksum
	checksum: u8 = 0
	for address: u16 = 0x0134; address <= 0x014C; address += 1 {
		checksum = checksum - u8(cart_ctx.rom_data[address]) - 1
	}

	fmt.printf(
		"\t Checksum : %2.2X (%s)\n",
		cart_ctx.header.checksum,
		checksum == cart_ctx.header.checksum ? "PASSED" : "FAILED",
	)


	return true
}
