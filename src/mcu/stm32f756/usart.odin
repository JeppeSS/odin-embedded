
package stm32f756

import "embedded:mmio"

// USART3_BASE is the base address of USART3.
//
// See RM0385, Universal synchronous asynchronous receiver
// transmitter (USART).
USART3_BASE :: uintptr(0x40004800)

// USART register offsets.
USART_CR1_OFFSET :: uintptr(0x00)
USART_CR2_OFFSET :: uintptr(0x04)
USART_CR3_OFFSET :: uintptr(0x08)
USART_BRR_OFFSET :: uintptr(0x0C)
USART_ISR_OFFSET :: uintptr(0x1C)
USART_TDR_OFFSET :: uintptr(0x28)

// USART_CR1_Register represents USART control register 1.
//
// Only fields required for basic asynchronous transmission
// are modeled individually.
USART_CR1_Register :: bit_field u32 {
    UE:        bool | 1, // Bit 0: USART enable.
    _bit1:     bool | 1,
    RE:        bool | 1, // Bit 2: Receiver enable.
    TE:        bool | 1, // Bit 3: Transmitter enable.
    _bits4_14: u16  | 11,
    OVER8:     bool | 1, // Bit 15: Oversampling by 8.
    _upper:    u16  | 16,
}

// USART_ISR_Register represents USART interrupt and status register.
//
// TXE indicates that the transmit data register is empty.
// TC indicates that the entire transmission has completed.
USART_ISR_Register :: bit_field u32 {
    _lower: bool | 7,
    TXE:    bool | 1, // Bit 7.
    _upper: u32  | 24,
}

// read_usart_cr1 reads USART control register 1.
read_usart_cr1 :: proc "contextless" (base: uintptr) -> USART_CR1_Register {
    raw := mmio.read_u32(base + USART_CR1_OFFSET)
    return transmute(USART_CR1_Register)raw
}

// write_usart_cr1 writes USART control register 1.
write_usart_cr1 :: proc "contextless" (base: uintptr, reg: USART_CR1_Register) {
    mmio.write_u32(base + USART_CR1_OFFSET, transmute(u32)reg)
}

// read_usart_isr reads the USART status register.
read_usart_isr :: proc "contextless" (base: uintptr) -> USART_ISR_Register {
    raw := mmio.read_u32(base + USART_ISR_OFFSET)
    return transmute(USART_ISR_Register)raw
}

// usart_brr_value calculates BRR for oversampling by 16.
//
// peripheral_clock_hz must be the actual USART kernel clock.
// Returns zero for invalid or unsupported divisors.
usart_brr_value :: proc "contextless" (
    peripheral_clock_hz: u32,
    baud_rate: u32,
) -> u32 {
    if baud_rate == 0 {
        return 0
    }

    // Round the clock divider to the nearest integer.
    divider := (u64(peripheral_clock_hz) + u64(baud_rate) / 2) / u64(baud_rate)

    if divider < 16 || divider > 0xFFFF {
        return 0
    }

    return u32(divider)
}

// usart_init_tx initializes a USART for basic asynchronous TX.
//
// Configuration:
// - 8 data bits
// - No parity
// - 1 stop bit
// - Oversampling by 16
// - Polling-based transmission
//
// The peripheral clock and GPIO alternate function must
// already be configured.
usart_init_tx :: proc "contextless" (
    base: uintptr,
    peripheral_clock_hz: u32,
    baud_rate: u32,
) -> bool {
    brr := usart_brr_value(peripheral_clock_hz, baud_rate)
    if brr == 0 {
        return false
    }

    // Disable USART before configuring it.
    mmio.write_u32(base + USART_CR1_OFFSET, 0)

    // Default asynchronous mode and one stop bit.
    mmio.write_u32(base + USART_CR2_OFFSET, 0)
    mmio.write_u32(base + USART_CR3_OFFSET, 0)

    // Configure baud rate.
    mmio.write_u32(base + USART_BRR_OFFSET, brr)

    // Enable USART and transmitter.
    cr1 := USART_CR1_Register{}
    cr1.TE = true
    cr1.UE = true
    write_usart_cr1(base, cr1)

    return true
}

// usart_write_byte transmits one byte using polling.
//
// The function blocks until the transmit data register
// is ready to accept another byte.
usart_write_byte :: proc "contextless" (base: uintptr, value: u8) {
    for !read_usart_isr(base).TXE {}

    mmio.write_u32(base + USART_TDR_OFFSET, u32(value))
}

// usart_write_bytes transmits a byte slice.
usart_write_bytes :: proc "contextless" (base: uintptr, data: []u8) {
    for value in data {
        usart_write_byte(base, value)
    }
}
