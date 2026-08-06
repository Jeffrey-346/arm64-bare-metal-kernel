SRCS = $(wildcard *.c)
ASMS = $(wildcard *.S)
OBJS = $(SRCS:.c=.o) $(ASMS:.S=.o)
CFLAGS = -Wall -O2 -g -ffreestanding -nostdinc -nostdlib
GDBPORT = $(shell expr `id -u` % 5000 + 25000)

all: clean kernel8.img

%.o: %.S
	aarch64-elf-gcc $(CFLAGS) -c $< -o $@


%.o: %.c
	aarch64-elf-gcc $(CFLAGS) -c $< -o $@

kernel8.img: $(OBJS)
	aarch64-elf-ld -nostdlib $(OBJS) -T link.ld -o kernel8.elf
	aarch64-elf-objcopy -O binary kernel8.elf kernel8.img

clean:
	rm -f *.o *.elf *.img *.bin *.map

run:
	qemu-system-aarch64 -M raspi3b -kernel kernel8.img -serial stdio

qemu-gdb:
	qemu-system-aarch64 -M raspi3b -kernel kernel8.img -serial stdio -S -gdb tcp::$(GDBPORT)

debug:
	qemu-system-aarch64 -M raspi3b -kernel kernel8.img -serial stdio -d int -D qemu.log -S -gdb tcp::$(GDBPORT) & \
	sleep 1; \
	aarch64-elf-gdb kernel8.elf -ex "target remote localhost:$(GDBPORT)"