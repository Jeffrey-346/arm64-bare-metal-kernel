#include "gpio.h"

/* mailbox message buffer */
volatile unsigned int  __attribute__((aligned(16))) mbox[36];

#define VIDEOCORE_MBOX  (MMIO_BASE+0x0000B880)
#define MBOX_READ       ((volatile unsigned int*)(VIDEOCORE_MBOX+0x0))
#define MBOX_POLL       ((volatile unsigned int*)(VIDEOCORE_MBOX+0x10))
#define MBOX_SENDER     ((volatile unsigned int*)(VIDEOCORE_MBOX+0x14))
#define MBOX_STATUS     ((volatile unsigned int*)(VIDEOCORE_MBOX+0x18))
#define MBOX_CONFIG     ((volatile unsigned int*)(VIDEOCORE_MBOX+0x1C))
#define MBOX_WRITE      ((volatile unsigned int*)(VIDEOCORE_MBOX+0x20))
#define MBOX_RESPONSE_SUCCESS   0x80000000
#define MBOX_FULL       0x80000000
#define MBOX_EMPTY      0x40000000

int mbox_call(unsigned char channel) {
    unsigned int r = (((unsigned int)((unsigned long)&mbox)&~0xF) | (channel&0xF));;

    // wait while mailbox register is full
    while(*MBOX_STATUS & MBOX_FULL) {
        asm volatile("nop");
    }
    // send request
    *MBOX_WRITE = r;
    // wait for response
    while(1) {
        // do nothing when there is no message
        while(*MBOX_STATUS & MBOX_EMPTY) {
         asm volatile("nop");
        }   
        // if there is a message, check if it is for our request
        if (r == *MBOX_READ) {
            return mbox[1] == MBOX_RESPONSE_SUCCESS;
        }
    }
    return 0;
}