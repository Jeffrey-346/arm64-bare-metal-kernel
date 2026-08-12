.section ".text"

.global vectors

.balign 2048
vectors:
    // Exception from Current EL while using SP_EL0
    .align 7                      
    b unhandled                 
    .align 7
    b unhandled                    
    .align 7
    b unhandled           
    .align 7
    b unhandled 

    // Exception from Current EL while using SP_ELx     
    .align 7                      
    b sync_handler                 
    .align 7
    b irq_handler                    
    .align 7
    b unhandled           
    .align 7
    b unhandled

    // Exception from Lower EL with at least one lower EL using AArch64
    .align 7                      
    b unhandled                 
    .align 7
    b unhandled                    
    .align 7
    b unhandled           
    .align 7
    b unhandled 

    // UNUSED: Exception from Lower EL with all lower ELs using AArch32  
    .align 7                      
    b unhandled                 
    .align 7
    b unhandled                    
    .align 7
    b unhandled           
    .align 7
    b unhandled

unhandled:
    b .

sync_handler:
    // Save x0-x30
    sub sp, sp, #272
    stp x0, x1, [sp, #0]
    stp x2, x3, [sp, #16]
    stp x4, x5, [sp, #32]
    stp x6, x7, [sp, #48]
    stp x8, x9, [sp, #64]
    stp x10, x11, [sp, #80]
    stp x12, x13, [sp, #96]
    stp x14, x15, [sp, #112]
    stp x16, x17, [sp, #128]
    stp x18, x19, [sp, #144]
    stp x20, x21, [sp, #160]
    stp x22, x23, [sp, #176]
    stp x24, x25, [sp, #192]
    stp x26, x27, [sp, #208]
    stp x28, x29, [sp, #224]

    mrs x0, ELR_EL1
    mrs x1, SPSR_EL1
    mrs x2, ESR_EL1

    stp x30, x0, [sp, #240]
    stp x1, x2, [sp, #256]

    // Put pointer to frame in x0
    mov x0, sp

    // branch to exception_handler
    bl syscall_handler_c

    // 5. Restore everything
    ldp x30, x0, [sp, #240]
    ldp x1, x2, [sp, #256]

    msr ELR_EL1, x0
    msr SPSR_EL1, x1
    msr ESR_EL1, x2

    ldp x0, x1, [sp, #0]
    ldp x2, x3, [sp, #16]
    ldp x4, x5, [sp, #32]
    ldp x6, x7, [sp, #48]
    ldp x8, x9, [sp, #64]
    ldp x10, x11, [sp, #80]
    ldp x12, x13, [sp, #96]
    ldp x14, x15, [sp, #112]
    ldp x16, x17, [sp, #128]
    ldp x18, x19, [sp, #144]
    ldp x20, x21, [sp, #160]
    ldp x22, x23, [sp, #176]
    ldp x24, x25, [sp, #192]
    ldp x26, x27, [sp, #208]
    ldp x28, x29, [sp, #224]

    eret


irq_handler:
    // Save x0-x30
    sub sp, sp, #272
    stp x0, x1, [sp, #0]
    stp x2, x3, [sp, #16]
    stp x4, x5, [sp, #32]
    stp x6, x7, [sp, #48]
    stp x8, x9, [sp, #64]
    stp x10, x11, [sp, #80]
    stp x12, x13, [sp, #96]
    stp x14, x15, [sp, #112]
    stp x16, x17, [sp, #128]
    stp x18, x19, [sp, #144]
    stp x20, x21, [sp, #160]
    stp x22, x23, [sp, #176]
    stp x24, x25, [sp, #192]
    stp x26, x27, [sp, #208]
    stp x28, x29, [sp, #224]

    mrs x0, ELR_EL1
    mrs x1, SPSR_EL1
    mrs x2, ESR_EL1

    stp x30, x0, [sp, #240]
    stp x1, x2, [sp, #256]

    // Put pointer to frame in x0
    mov x0, sp

    // bl exception_handler
    bl irq_handler_c

    // Restore everything
    ldp x30, x0, [sp, #240]
    ldp x1, x2, [sp, #256]

    msr ELR_EL1, x0
    msr SPSR_EL1, x1
    msr ESR_EL1, x2

    ldp x0, x1, [sp, #0]
    ldp x2, x3, [sp, #16]
    ldp x4, x5, [sp, #32]
    ldp x6, x7, [sp, #48]
    ldp x8, x9, [sp, #64]
    ldp x10, x11, [sp, #80]
    ldp x12, x13, [sp, #96]
    ldp x14, x15, [sp, #112]
    ldp x16, x17, [sp, #128]
    ldp x18, x19, [sp, #144]
    ldp x20, x21, [sp, #160]
    ldp x22, x23, [sp, #176]
    ldp x24, x25, [sp, #192]
    ldp x26, x27, [sp, #208]
    ldp x28, x29, [sp, #224]

    eret

