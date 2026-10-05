package mmio

import "base:intrinsics"


read_u32 :: proc "contextless" (address: uintptr) -> u32 {
	return intrinsics.volatile_load(cast(^u32)address)
}

write_u32 :: proc "contextless" (address: uintptr, value: u32) {
	intrinsics.volatile_store(cast(^u32)address, value)
}
