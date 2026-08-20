# arm64-baremetal-kernel

> A from-scratch operating system kernel for ARM64, built as prep for Brown's 
Operating Systems, Fall 2026 course. Boots on real/emulated hardware, handles 
its own interrupts, context-switches between tasks, and ships with a small 
interactive shell over UART.

**Status:** 🚧 In progress — see [Milestones](#milestones) below.

**Demo:** It's in the works people.

---

## What it does

This kernel boots directly on ARM64 hardware with no underlying OS, initializes 
its own interrupt controller and exception handlers — validated by 
deliberately triggering and catching a synchronous fault to confirm correct trap 
entry and exit — and prints over a serial (UART) connection. Currently 
implementing a preemprtive context-switch between multiple independent tasks. 

## Why I built this

I decided to build this project because of my interest in systems. As a sophmore
I took a foundations of systems course (Brown's csci0300) that I adored so
much I became a TA for the course the next semester. Now I am planning to 
take the next systems course at Brown (csci 1690 - Operating Systems). This
project is first founded from personal interest and has the bonus additional
motivation as preparation for the OS course. 

## Architecture

Power on

  → boot.S (set up stack, drop to EL1, initialize UART and interrupts, jump to C)
  → kernel_main() (transmit message over UART, echo inputs)
  → Exception/interrupt handling (sync + IRQ paths)
  → TODO: Scheduler (context switch between N tasks via swtch-style routine)
  → TODO: UART shell (read command line, dispatch to handler, print result)

## Features

- [X] Boots on QEMU (`-M raspi3b` or similar) and prints to UART
- [X] Exception vector table with synchronous exception handling
- [X] ARM generic timer interrupt
- [ ] Context switching between multiple tasks (round-robin or similar)
- [ ] Interactive shell over UART with a small command set
- [ ] _(stretch)_ additional shell commands / basic memory inspection / etc.

## Milestones

Wed. July 29th: First Commit:
It's been a long time in the works, but, after pages and pages of notes and
hours of studying, I finally was able to boot the kernel and print to the
terminal with UART0! The most challenging hurtle so far has been shaping an
accurate mental model of the pi. This is the first time the idea of memory 
mapped IO concretized itself in my mind. To be honest, this territory is
uncormfortably close to the hardware for my background, but that's why it's so
important to learn. Next up: Exceptions!

Thur. August 6th: Second Commit:
Guys I didn't know what a vector table was before this. Since my last commit
I've learned alot, mostly through xv6, so it's been a bit difficult converting
everything in my brain from RISC-V to ARM but probably good for reinforcing
concepts. I read chapters 2 and 4 of the xv6 manaul and then completed the 
syscalls lab from 2021: tracing getpid() from start to finish (wow PERL files
are nice) and then implementing two of my own syscalls. Then I started learning
about ARM trap handling with the vector tables. This commit marks a successful
skeleton vector table: svc #0 correct sends us to an entry of the vector table,
which currently only redirects us to an infinite loop, but will soon actually
save states and address the excpetions. Oh I also had a nasty bug having to do
with the 31st but of the HCR_EL2 register, which was saying to execute instructions
as AArch32. Took about an hour and a half to debug that.

Tue. August 11: Third Commit:
We've fallen a bit behind here ladies and gentlemen. I took a trip to Lousiana
to see my grandparents. I will put it here because I think the world should know:
my grandmother placed second in the Women's World Archery championship, only
losing to some Edith Bane (what a villian name) in an overtime shoot out. Alas
the CS show must go on. I've implemented an exception vector table that handles
synchronous excpetions from EL1 to EL1. I started with a skeleton that redirected
from the vector table to an infinite loop (previous commit) but now it prints
the cause of the exception and the return address through UART0. Next up is
handling interrupts.

Wed. August 12: Fourth Commit:
Timer IRQ via QA7 CNTP routing, ack via TVAL re-arm.
To be honest in my academic journey, this commit was heavily aided by AI. There
is just a lot of hardware jargon going on with the timer, especially since it
needs to be routed through QA7, which—since I'm only working with one core for now—is
overcomplicated. This is a learning moment though. I gained more intution for
peripherals (although this timer is within the core), learned how the timer 
actaully goes off (there's a register counting upwards forever, which will take 
~30,000 years to wrap around!!), and successfully handled another type of 
exception using my vector table! Next up is Concurrency and the locking lab
from xv6!

| Week | Milestone | Status |
|------|-----------|--------|
| 1 | Toolchain + QEMU set up, ARM64 assembly basics | ✅ |
| 2 | Kernel boots, UART "hello world" | ✅ |
| 3 | Exception vector table, timer interrupt firing | ✅ |
| 4 | Context switching between 2+ tasks | ⬜ |
| 5–6 | Interactive UART shell with command dispatch | ⬜ |
| 7 | Polish, demo recording, README finalized | ⬜ |

## Build & run

### Prerequisites
- `aarch64-none-elf` cross-compiler toolchain
- QEMU (`qemu-system-aarch64`)

### Build
```
make
```

### Run (QEMU)
```
qemu-system-aarch64 -M raspi3b -kernel kernel8.img -serial stdio
```

Additionally, the makefile includes commands to run QEMU with GDB for debugging
purposes.


## What I learned



The thing I've found most interesting in implementing my OS so far is exception
handling. It's very narratively rich. An emergency happens. A deus (the kernel)
swoops in and handles the issue, and resumes the previous thread, restoring 
its memory so it seems as if nothing has happened. Reminds me of Apple TV's 
Severance. These moments of intricate, quiet machinery—whose entire 
purpose is to go unnoticed, to make our computers run seemlingly magically—are 
what draw me to systems. This project lets me be a witness to all of that
silent work. All that being said: the technical implementation of 
exception handling is a great takeaway from the project so far.

## Acknowledgments

- [ ] Tutorial(s) followed: 
    bztsrc's raspi3-tutorial (github.com/bztsrc/raspi3-tutorial)
    rlepigre's bare-metal-aarch64 repo (github.com/rlepigre/bare-metal-aarch64)
- [ ] Reference material:
    xv6: a simple, Unix-like teaching operating system
    MIT 6.S081 Labs: Syscalls, Lock
    Many ARM documents...

---

_Built by Jeffrey Haile · Summer 2026 · in preparation for Operating Systems, Fall 2026_
