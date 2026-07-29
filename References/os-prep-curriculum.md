# OS Prep Curriculum — Summer 2026

**Context:** Preparing for CS 1670 (Operating Systems, Brown, Fall 2026) after taking and TAing CSCI 0300 (Foundations of Systems). CS 1670 builds an OS from scratch on real ARM64 Raspberry Pi hardware — no emulator — covering booting, I/O via interrupts, process isolation, virtualization, concurrency, and file systems, with case studies against Linux and Windows.

**Start date:** Sunday, July 19, 2026
**Last working day:** Monday, August 31, 2026
**Total window:** ~6.3 weeks
**Pace:** 2–3 hours, 5 days/week (~12–15 hrs/week, ~85 hours total)

**Background already in place:** Strong grounding in OS concepts from 0300 + TAing (processes, virtual memory, concurrency, syscalls as abstractions). Reinforced via ~6 lectures from MIT 6.S081. The gap this plan fills is **hardware/software interface mechanics on ARM64** — assembly, exception levels, interrupts, and building a kernel on real silicon — which 0300 doesn't cover.

**Capstone deliverable:** A small bare-metal ARM64 OS for Raspberry Pi, built incrementally across the plan: UART driver, exception vector table with EL1/EL0 separation, a timer-interrupt-driven context switch between kernel threads, and a basic memory allocator. Tracked as a public GitHub repo from Day 1, with a real README, architecture summary, and a short demo (terminal recording or video) by the end — a genuine, demoable systems project for internship applications.

**Two labs from MIT's xv6 coursework are folded in** — Lab syscall and Lab lock — chosen because they transfer well conceptually despite the RISC-V/ARM64 ISA difference. **Lab traps was deliberately cut**: Week 3 has you building a real ARM64 exception vector table from scratch, which teaches the same lesson (trap entry/exit, stack frames) without the cost of mentally re-translating RISC-V idioms into ARM64 ones. Don't add it back in unless you finish early with real time to spare.

**Guiding principle for the back half:** the context switch (Weeks 4–5) is the hardest thing in this entire plan — harder than a 2-week guided course project, because you're doing it solo, on real hardware, without a debugger that works the way a VM's would. Expect at least one silent hang or corrupted state before it works. That's normal, not a sign of falling behind. If it's still fighting you by the end of Week 5, **cut scope, not sleep** — a working 2-thread switch with no allocator is still an honest, presentable resume line. A broken 3-feature kernel with a rushed README is not.

---

## Week 1 — Jul 19 (Sun) to Jul 25 (Sat): ARM64 fundamentals

Compressed from the original 5-day plan to 4 sessions, since the MIT 6.S081 lectures already gave you real conceptual grounding — this should move faster than it would have cold. The 5th session is buffer; use it to catch up or start Session 5 of Week 2 early.

**Session 1 — Registers & the AAPCS64 calling convention**
- Read ARM's AAPCS64 (Procedure Call Standard for the Arm 64-bit Architecture) — short, and tells you exactly which registers hold arguments (x0–x7), which are callee-saved (x19–x28), and what x29/x30 (frame pointer/link register) do.
- Skim Azeria Labs' "ARM Data Types and Registers" post for visual intuition — written for ARMv7, so use it only for the conceptual on-ramp (register file, condition flags), not instruction-level specifics.
- Goal: read a function prologue/epilogue (`stp x29, x30, [sp, #-16]!` ... `ldp x29, x30, [sp], #16` ... `ret`) and explain every line.

**Session 2 — Core AArch64 instruction set**
- Work through ARM's "Learn the Architecture: AArch64 Instruction Set Architecture" guide (developer.arm.com) — load/store, arithmetic, branching, conditional execution, for the real 64-bit ISA (not 32-bit ARM material).
- Practice: install `aarch64-linux-gnu-gcc` (or `aarch64-none-elf-gcc`), compile small C functions with `-O0 -S`, and read the generated assembly — one with a loop, one with an if/else, one that calls another function.

**Session 3 — Exception levels (EL0–EL3)**
- This concept doesn't exist in 0300's material and it's central to Project 3/4 (privilege separation) this fall. Read the exception-level sections of ARM's Architecture Reference Manual for A-profile, or the friendlier "Learn the Architecture: Exception Model" guide — focus on what EL0/EL1/EL2/EL3 mean, how you move between levels (exceptions, `eret`), and where a kernel typically lives (EL1) vs. firmware (EL2/EL3).
- Cross-reference with rlepigre's `bare-metal-aarch64` repo (github.com/rlepigre/bare-metal-aarch64) — built specifically around exception levels on a Pi 3, step by step, with concrete runnable code.

**Session 4 — Toolchain + QEMU + first boot**
- Install cross-compiler and QEMU with `aarch64` system emulation (`qemu-system-aarch64`, `-M raspi3b`).
- Get a "Hello World" bare-metal kernel booting in QEMU, following bztsrc's `raspi3-tutorial` (github.com/bztsrc/raspi3-tutorial) — AArch64-only, heavily commented, C-first. `s-matyukevich/raspberry-pi-os` is a good parallel resource if you want a second explanation of the same territory.
- **Start the GitHub repo now** and commit this first boot. This is the seed of the capstone.

**Session 5 (buffer) — Consolidate**
- Trace one full example (bztsrc or rlepigre) line by line: boot → stack setup → drop to the right exception level → UART init → print. Write a short reference page for yourself — you'll want it once the semester's deadlines hit.
- Checkpoint: you can (1) read an ARM64 prologue and explain the calling convention, (2) explain EL0–EL3 and why they matter for isolation, (3) have a working toolchain + QEMU boot of your own minimal kernel, committed to the repo.

---

## Week 2 — Jul 26 (Sun) to Aug 1 (Sat): UART on real hardware + syscalls

**Sessions 1–2 — UART driver, solidified**
- If you didn't finish this in Week 1's buffer, get UART output fully working and understood (not just copied) — registers, baud rate setup, polling vs. interrupt-driven send.
- If you have physical hardware by now, get your Week 1 kernel running on it, not just QEMU. If not, continue on QEMU and plan to validate on hardware once it arrives.

**Sessions 3–4 — xv6: system calls**
- Read the xv6 book chapter on system calls.
- Complete **Lab syscall** (adding a new system call to xv6). Short, and a good low-cost way to get oriented in a real kernel codebase.
- Goal: understand the full path from user code → trap → kernel handler → return, in xv6/RISC-V terms. You'll rebuild this in ARM64 terms in Week 3.

**Session 5 — Write the comparison note**
- Short written note (half a page is fine): "here's how xv6/RISC-V handles a syscall trap; here's what I expect differs on ARM64 (vector table, `esr_el1`, `eret`)." This becomes a real reference in September — write it while it's fresh, not from memory later.

---

## Week 3 — Aug 2 (Sun) to Aug 8 (Sat): Exceptions, interrupts, and locking

**Sessions 1–3 — Your own ARM64 exception vector table**
- Build a real AArch64 exception vector table on the Pi (yours, not xv6's) and handle at least one synchronous exception deliberately (e.g., a fault) to confirm it's wired correctly.
- Bring in the GIC (Generic Interrupt Controller) and get a timer interrupt firing and handled.
- This is Project 1/2 territory directly — budget real time here, it's more finicky than it looks on paper.

**Sessions 4–5 — Concurrency: xv6 locking + Lab lock**
- Read the xv6 book chapter on locking (spinlocks, race conditions).
- Complete **Lab lock**. Your fall course has a real multicore component, and lock-contention bugs are far easier to reason about once you've debugged one yourself.
- Checkpoint for the week: UART output, a working exception vector table, a firing timer interrupt, and a completed locking lab — all committed to the repo.

---

## Week 4 — Aug 9 (Sun) to Aug 15 (Sat): Context switching, part 1

This is the hardest block in the whole plan — treat it as the priority for the week, not something to fit around other things.

**Sessions 1–2 — Design the thread structure**
- Define a minimal kernel thread/task struct (saved registers, stack pointer, state).
- Read/skim OSTEP's chapters on virtualizing the CPU for the conceptual model before writing ARM64-specific save/restore code.

**Sessions 3–5 — First context switch**
- Implement register save/restore (the ARM64 equivalent of xv6's `swtch.S`) and get a switch between exactly two threads working, triggered manually first (not yet off the timer interrupt).
- Expect this to fail quietly the first few times — a stack alignment bug or an incompletely saved register set is the most common cause. If you get stuck, that's expected; don't burn the whole week chasing one bug alone — write down where you're stuck and move to Week 5 with it in hand rather than losing the week.

---

## Week 5 — Aug 16 (Sun) to Aug 22 (Sat): Context switching, part 2 (buffer-heavy)

This week exists explicitly to absorb Week 4 overflow. If Week 4 finished clean, use the extra time to harden the scheduler rather than rushing ahead to Week 6.

**Sessions 1–3 — Finish the switch, then wire it to the timer interrupt**
- Get the manual 2-thread switch fully correct if it wasn't by end of Week 4.
- Once solid, trigger the switch from the timer interrupt instead of manually — this makes it a real preemptive scheduler rather than a cooperative one.

**Sessions 4–5 — Round-robin across 3+ threads**
- Extend from 2 to 3+ threads in round-robin order.
- Checkpoint: a preemptive round-robin scheduler, timer-driven, running 3+ threads, each doing something visibly distinct over UART (so a demo actually shows it working).

---

## Week 6 — Aug 23 (Sun) to Aug 29 (Sat): Allocator, demo, and README (start early)

**Sessions 1–2 — Memory allocator**
- Implement a simple bump allocator or basic free-list allocator for kernel memory. This is genuinely quick (a couple hours) compared to the scheduler — don't let it expand to fill time it doesn't need.

**Sessions 3–4 — Make it demoable**
- Polish the 3-thread UART output so it clearly shows the scheduler at work (e.g., each thread printing its own labeled output on an interval).
- Start the README now, not in Week 7: what it does, a short architecture summary (boot → exception vectors → scheduler → allocator), build/run instructions.

**Session 5 — Record the demo**
- Record a short terminal capture (asciinema) or video of it booting and running on real hardware if you have it, or QEMU if not.
- Optional, high-value if you have slack: a short write-up on one specific thing you learned (e.g., "how ARM64 exception levels work") — doubles as your own interview prep.

---

## Week 7 (buffer) — Aug 30 (Sun) to Aug 31 (Mon): Final polish

Only two days — this is intentionally a hard buffer, not new content.

**Day 1 — Absorb overflow**
- Finish whatever slipped from Weeks 4–6. If the scheduler is still the bottleneck, this is where it gets closed out — with reduced scope if needed.

**Day 2 — Ship it**
- Finalize the README, confirm the repo is clean and public, confirm the demo file/link works.
- Write the resume bullet now, while it's fresh: e.g., *"Built a bare-metal ARM64 kernel for Raspberry Pi from scratch: UART driver, exception-level-aware interrupt handling, preemptive scheduler, and memory allocator."*

---

## Standing rules for the whole plan

- **Cut scope before cutting sleep.** A smaller, working, well-documented project beats a larger broken one every time — for the fall course and for the resume.
- **Commit as you go**, not just at the end. The repo's history is part of what makes this look like real, incremental engineering work rather than a one-shot dump.
- **Don't add Lab traps back in** unless you finish everything else with genuine time to spare — Week 3's own exception vector table already covers that ground in the ISA you actually need.
- **If Week 4/5's context switch is still broken by Aug 29**, drop the allocator and the 3-thread extension without guilt. A clean 2-thread preemptive switch, well explained in the README, is a completely legitimate stopping point.
