#include "uart.h"
#include "mbox.h"

int main() {
    uart_init();

    uart_puts("Hello Jeffrey. I'm Kernel. Welcome to my space...\n");

    while(1) {
        // double echo forever
        char c = uart_getc();
        uart_send(c);
        uart_send(c);
    }
}