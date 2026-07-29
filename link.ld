ENTRY(_start)

SECTIONS
{
    . = 0x80000;

    .text : {
        *(.text.boot);
        *(.text*);
    }
    .rodata : {
        *(.rodata*);
    }
    .data : {
        *(.data*);
    }
    .bss : {
        _bss_start = .;
        *(.bss*);
        _bss_end = .;
    }
    _end = .;
}