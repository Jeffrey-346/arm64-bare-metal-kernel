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
2:  ldr     x1, =_start
    mov     sp, x1
    // clear bss because C demands it
    ldr     x2, =_bss_start
    ldr     x3, =_bss_end
3:  cmp     x2, x3
    beq     4f
    str     xzr, [x2], #8
    b       3b

4:  
    bl      main