MEMORY
{
    FLASH (rx)  : ORIGIN = 0x08000000, LENGTH = 1M
    DTCM  (rwx) : ORIGIN = 0x20000000, LENGTH = 64K
}

_estack = ORIGIN(DTCM) + LENGTH(DTCM);

SECTIONS
{
    .isr_vector :
    {
        KEEP(*(.isr_vector))
    } > FLASH

    .text :
    {
        *(.text*)
        *(.rodata*)
    } > FLASH

    .ARM.exidx :
    {
        __exidx_start = .;
        *(.ARM.exidx*)
        __exidx_end = .;
    } > FLASH

    .data :
    {
        . = ALIGN(4);
        _sdata = .;

        *(.data*)

        . = ALIGN(4);
        _edata = .;
    } > DTCM AT > FLASH

    _sidata = LOADADDR(.data);

    .bss (NOLOAD) :
    {
        . = ALIGN(4);
        _sbss = .;

        *(.bss*)
        *(COMMON)

        . = ALIGN(4);
        _ebss = .;
    } > DTCM
}
