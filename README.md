# arm64-baremetal-kernel

> A from-scratch operating system kernel for ARM64, built as prep for Brown's 
Operating Systems, Fall 2026 course. Boots on real/emulated hardware, handles 
its own interrupts, context-switches between tasks, and ships with a small 
interactive shell over UART.

**Status:** 🚧 In progress — see [Milestones](#milestones) below.

**Demo:** _[link to asciinema recording or video — add once you have your first working milestone]_

---

## What it does

<!--
One paragraph, written for someone non-technical or a recruiter skimming quickly.
Fill this in once the shell is working — something like:

"This kernel boots directly on ARM64 hardware with no underlying OS, initializes its
own interrupt controller and exception handlers, and can run and context-switch
between multiple independent tasks. It exposes a small interactive shell over a
serial (UART) connection, so you can type commands and get real-time responses
from code running with no operating system underneath it."
-->

TODO

## Why I built this

<!--
2-3 sentences. This is the part interviewers actually ask about — connect it to
your background (CSCI 0300 at Brown, TAing it, prepping for the ARM64 OS course)
and what gap it filled. E.g. "0300 covers OS concepts using x86 and an existing
kernel (WeensyOS) as scaffolding. I wanted to build the hardware/software boundary
myself, from power-on, on an architecture (ARM64) I hadn't worked with before."
-->

TODO

## Architecture

<!--
Bullet list or a simple diagram (even ASCII) is fine. Something like:

Power on
  → boot.S (set up stack, drop to EL1, jump to C)
  → kernel_main() (initialize UART, exception vector table, GIC/timer)
  → Exception/interrupt handling (sync + IRQ paths)
  → Scheduler (context switch between N tasks via swtch-style routine)
  → UART shell (read command line, dispatch to handler, print result)

Fill in the real flow once it stabilizes — this section is what a technical
reviewer reads first, so keep it accurate and specific rather than aspirational.
-->

TODO

## Features

- [X] Boots on QEMU (`-M raspi3b` or similar) and prints to UART
- [X] Exception vector table with synchronous exception handling
- [ ] GIC-based timer interrupt
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

| Week | Milestone | Status |
|------|-----------|--------|
| 1 | Toolchain + QEMU set up, ARM64 assembly basics | ✅ |
| 2 | Kernel boots, UART "hello world" | ✅ |
| 3 | Exception vector table, timer interrupt firing | ⬜ |
| 4 | Context switching between 2+ tasks | ⬜ |
| 5–6 | Interactive UART shell with command dispatch | ⬜ |
| 7 | Polish, demo recording, README finalized | ⬜ |

## Build & run

<!--
Fill in as your toolchain solidifies. Be exact — someone should be able to clone
and run this without asking you questions. Example shape:

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

### Shell commands
| Command | Description |
|---------|-------------|
| `help`  | List available commands |
| ...     | ... |
-->

TODO

## What I learned

<!--
This is the section interviewers respond to most — pick ONE specific, non-obvious
thing and explain it clearly in a few sentences. Candidates:
- How ARM64 exception levels (EL0-EL3) work and why they matter for privilege separation
- What actually happens between power-on and your first line of C code
- Why a context switch needs to save exactly the registers it saves, no more, no less

Write this like you're explaining it to a smart friend outside CS, not like
documentation. It should read as insight, not summary.
-->

TODO

## Acknowledgments

<!--
Cite the tutorials/resources you followed (e.g. Sergey Matyukevich's
raspberry-pi-os, OSDev wiki, the xv6 book) — being upfront about what you
followed vs. extended makes the extensions more credible, not less.
-->

- [ ] Tutorial(s) followed: 
    bztsrc's raspi3-tutorial (github.com/bztsrc/raspi3-tutorial)
    rlepigre's bare-metal-aarch64 repo (github.com/rlepigre/bare-metal-aarch64)
- [ ] Reference material:

---

_Built by Jeffrey Haile · Summer 2026 · in preparation for Operating Systems, Fall 2026_
