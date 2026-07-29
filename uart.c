#include "gpio.h"
#include "mbox.h"

/* PL011 UART registers */
#define UART0_DR        ((volatile unsigned int*)(MMIO_BASE+0x00201000))
#define UART0_FR        ((volatile unsigned int*)(MMIO_BASE+0x00201018))
#define UART0_IBRD      ((volatile unsigned int*)(MMIO_BASE+0x00201024))
#define UART0_FBRD      ((volatile unsigned int*)(MMIO_BASE+0x00201028))
#define UART0_LCRH      ((volatile unsigned int*)(MMIO_BASE+0x0020102C))
#define UART0_CR        ((volatile unsigned int*)(MMIO_BASE+0x00201030))
#define UART0_IMSC      ((volatile unsigned int*)(MMIO_BASE+0x00201038))
#define UART0_ICR       ((volatile unsigned int*)(MMIO_BASE+0x00201044))

/**
 * Set baud rate and characteristics (115200 8N1) and map to GPIO
 */
void uart_init()
{
    // turn of UART0 while we initialize it
    *UART0_CR = 0;
    // setting up mailbox message to configure clock which determines UART0's buad rate
    mbox[0] = 9*4; // message size (in bytes)
    mbox[1] = MBOX_REQUEST; // is this a message request or response?
    mbox[2] = MBOX_TAG_SETCLKRATE; // plz configure clock
    mbox[3] = 3*4; // size of relevent information (indices 5-7)
    mbox[4] = 0; // is this tag a request or response?
    mbox[5] = 2; // clock ID
    mbox[6] = 4000000; // desired frequency (this is what we wanted to set!!)
    mbox[7] = 0; // Turbo mode 
    mbox[8] = MBOX_TAG_LAST; // end marker

    // send request
    mbox_call(MBOX_CH_PROP);

    // set up pins 14, 15 for uart transmitting/recieving 
    register unsigned int r;
    r = *GPFSEL1; // GPFSEL1 controls pins 10-17
    // clear previous assignment for 14, 15 (assignments are 3 bits)
    r&=(~((7<<12)|(7<<15)));
    //make new assignment
    r|=(4<<12 | 4<<15);
    *GPFSEL1 = r;

    // set pull to none (mannn random hardware junk)
    *GPPUD = 0;
    r = 150; while(r--){asm volatile("nop");}
    *GPPUDCLK0 = (1<<14)|(1<<15);
    r = 150; while(r--){asm volatile("nop");}
    *GPPUDCLK0 = 0;

    // configure uart regs
    *UART0_ICR = 0x7FF; // clear old/stale interupts
    *UART0_IBRD = 2; // baud rate divisor
    *UART0_FBRD = 12; // fractional baud rate divisor
    *UART0_LCRH = 0x7CC4; // send 8 bits per character, enable FIFO buffers
    *UART0_CR = 0x301; // ENABLE UART0!!!
}

void uart_send(unsigned int c) {
    // wait while transmitter FIFO is full
    while(*UART0_FR&0x20) {
        asm volatile("wfe");
    }
    // send character through data register
    *UART0_DR = c;
}

char uart_getc() {
    while(*UART0_FR&0x10) {
        asm volatile("wfe");
    }
    char c = (char)*UART0_DR;
    return c=='\r'?'\n':c;
}

void uart_puts(char* s) {
    while(*s){
        if (*s == '\n') {
            uart_send('\r');
        }
        uart_send(*s++);
    }
}