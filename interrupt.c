#include "uart.h"

#define TIMER_INTERVAL 0x1000000

void timer_init(void) {
    unsigned long freq;
    asm volatile("mrs %0, cntfrq_el0" : "=r"(freq));
    asm volatile ("msr cntp_tval_el0, %0" :: "r"((unsigned long)TIMER_INTERVAL));
    asm volatile ("mov x0, #1; msr cntp_ctl_el0, x0" ::: "x0");
}

#define CORE0_TIMER_IRQ_CTRL ((volatile unsigned int*)0x40000040)

void timer_route_core0(void) {
    *CORE0_TIMER_IRQ_CTRL = (1 << 1);  // nCNTPNSIRQ -> IRQ line, not FIQ
}

void irq_handler_c(void) {
    uart_puts("tick\n");

    // reset interrupt timer
    asm volatile ("msr cntp_tval_el0, %0" :: "r"((unsigned long)TIMER_INTERVAL));
}