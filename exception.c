#include "uart.h"
#include "mbox.h"

struct trapframe {
    long x0;
    long x1;
    long x2;
    long x3;
    long x4;
    long x5;
    long x6;
    long x7;
    long x8;
    long x9;
    long x10;
    long x11;
    long x12;
    long x13;
    long x14;
    long x15;
    long x16;
    long x17;
    long x18;
    long x19;
    long x20;
    long x21;
    long x22;
    long x23;
    long x24;
    long x25;
    long x26;
    long x27;
    long x28;
    long x29;
    long x30;
    
    long ELR_EL1;
    long SPSR_EL1;
    long ESR_EL1;
};


void exception_handler(struct trapframe* trapframe_p) {
    long elr_el1 = trapframe_p->ELR_EL1;
    long esr_el1 = trapframe_p->ESR_EL1;

    uart_puts("ELR_EL1 is: ");
    uart_puthex(elr_el1);
    uart_puts("\nESR_EL1 is: ");
    uart_puthex(esr_el1);
}