SRCS = $(wildcard *.c)
OBJS = $(SRCS:.c=.o)
CFLAGS = -Wall -O2 -ffreestanding -nostdinc -nostdlib

all: clean kernel8.img

boot.o: boot.S
	aarch64-elf-gcc $(CFLAGS) -c boot.S -o boot.o

%.o: %.c
	aarch64-elf-gcc $(CFLAGS) -c $< -o $@

kernel8.img: boot.o $(OBJS)
	aarch64-elf-ld -nostdlib boot.o $(OBJS) -T link.ld -o kernel8.elf
	aarch64-elf-objcopy -O binary kernel8.elf kernel8.img

clean:
	rm -f *.o *.elf *.img *.bin *.map

run:
	qemu-system-aarch64 -M raspi3b -kernel kernel8.img -serial stdio