.section ".text.boot"

.global _start

_start:
    mrs     x1, mpidr_el1
    and     x1, x1, 3
    cbz     x1, 2f

// tell other cores to do nothing...
1:  wfi
    b       1b

// main core
// set EL to 1 if it's not yet
2:  mrs     x0, CurrentEL
    cmp     x0, #0x4
    b.eq     already_el1 // branch if we're already in EL1

    // set ELR_EL2 so eret jumps to ready
    mov     x0, #(1 << 31)      // HCR_EL2.RW = 1 → EL1 is AArch64
    msr     HCR_EL2, x0

    adr     x0, ready
    msr     ELR_EL2, x0

    // set SPSR_EL2
    mov x1, #(0b0101 | (0b1111 << 6))
    msr     SPSR_EL2, x1

    // set up stack pointer for EL1
    adr     x2, _start
    msr     SP_EL1, x2

    mrs     x3, SPSR_EL2
    mrs     x4, ELR_EL2

    eret

already_el1:
    adr     x0, _start
    msr     SP_EL1, x0

ready:
    // check current EL
    mrs     x0, CurrentEL
    // set VBAR_EL1 to the address of the table
    adr     x0, vectors
    msr     VBAR_EL1, x0

    // initialize uart communication
    bl uart_init

    // let's just test if everything is working with a syscall
    svc #0

    // clear bss because C demands it
    ldr     x2, =_bss_start
    ldr     x3, =_bss_end
3:  cmp     x2, x3
    beq     4f
    str     xzr, [x2], #8
    b       3b

4:  
    bl      main