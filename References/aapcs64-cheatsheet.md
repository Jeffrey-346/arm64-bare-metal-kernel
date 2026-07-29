# AAPCS64 Cheat Sheet — ARM64 Calling Convention

Quick reference for reading/writing ARM64 assembly, boot code, exception handlers, and context switches. Built from AAPCS64 (ARM's "Procedure Call Standard for the Arm 64-bit Architecture").

---

## Register Map

| Register(s) | Role | Who preserves it? |
|---|---|---|
| `x0`–`x7` | First 8 integer/pointer args in; `x0` also holds return value out | **Caller** (callee may freely clobber) |
| `x8` | Indirect result register (rarely used directly by you) | Caller |
| `x9`–`x15` | Temporary / scratch registers | **Caller** (callee may freely clobber) |
| `x16`–`x17` | Intra-procedure-call scratch (`IP0`/`IP1`) — used by linkers/veneers | Caller |
| `x18` | Platform register — reserved on some platforms, don't assume it's free scratch | Platform-specific |
| `x19`–`x28` | General-purpose locals | **Callee** — must save/restore if used |
| `x29` (`FP`) | Frame pointer | **Callee** |
| `x30` (`LR`) | Link register (return address) | **Callee** |
| `SP` | Stack pointer | **Callee** — and must stay 16-byte aligned |
| `v0`–`v7` | Floating-point/SIMD args and return value | Caller |
| `v8`–`v15` (lower 64 bits only) | FP/SIMD locals | Callee |

**Rule of thumb:** *Caller-saved* = "callee may trash it, so caller must save it first if it needs the value back." *Callee-saved* = "callee must give it back unchanged, so caller can trust it survives the call for free."

---

## The Golden Rule of "Callee-Saved"

If a function wants to use `x19`–`x28`, `x29`, `x30`, or `SP` for its own purposes:
1. **Prologue** (function start): save the current value onto the stack.
2. **Epilogue** (before `ret`): restore it from the stack.

Classic pattern you'll see everywhere:
```asm
stp x29, x30, [sp, #-16]!   ; prologue: save FP+LR, move SP down 16 bytes
...
ldp x29, x30, [sp], #16    ; epilogue: restore FP+LR, move SP back up
ret
```
`stp`/`ldp` (store/load *pair*) move two 8-byte registers at once — hence 16 bytes — which is also why the stack alignment rule is 16 bytes (see below).

---

## Stack Alignment: SP must be 16-byte aligned at any public interface (function call boundary)

**Why it's a hard rule, not a style preference:**
- AArch64 can architecturally fault on misaligned SP at call boundaries — this isn't just convention, the hardware can catch it.
- `stp`/`ldp` naturally want 16-byte-aligned addresses for efficiency; keeping SP aligned keeps every prologue/epilogue on a clean boundary.

**Why it matters *especially* in bare-metal code:** in hosted C, the compiler guarantees this for you invisibly. The moment you hand-write `.S` for boot code, exception vectors, or a context switch, **you are the compiler** — nothing enforces alignment anymore. A misaligned SP typically manifests as a crash/hang *several instructions after* the actual mistake, making it a nasty bug to trace. If something inexplicably breaks in your boot/exception/switch code, check SP alignment first.

---

## Applying This to Your Capstone

**Reading compiler-generated assembly (Week 1):**
Compiler output follows AAPCS64 automatically — args in x0–x7, frame set up via x29/x30, callee-saved regs preserved. Once you know the convention, generated `.s` output reads as intentional, not arbitrary.

**Exception vector table (Week 3):**
Before your handler calls into C code, you must have (a) saved whatever register state the handler needs to not corrupt, and (b) kept SP 16-byte aligned at the call boundary into C. Getting either wrong = silent corruption or a crash with a confusing signature.

**Context switch / `swtch` (Weeks 4–5):**
- You only need to save/restore the **callee-saved set**: `x19`–`x28`, `x29`, `x30`, `SP` (plus PC/thread state tracked separately in your thread struct).
- You do **not** need to save `x0`–`x7`. Why: `swtch` is called as an ordinary function call. By AAPCS64, any function call is already allowed to clobber caller-saved registers — so whoever calls into your scheduler already assumed x0–x7 might not survive the call, same as calling any other function. The calling convention does that work for you upstream; don't duplicate it.
- This is exactly why xv6's `swtch.S` only touches the callee-saved set — not a shortcut, just the convention functioning as designed.

---

## Self-Check Questions (re-quiz yourself later without notes)

1. Which registers hold the first 4 integer args to a function?
2. What's the practical difference in obligation between a caller-saved and a callee-saved register?
3. What do x29 and x30 conventionally hold?
4. What must a function do in its prologue/epilogue if it wants to use x21 as scratch space?
5. What's the SP alignment requirement, and name one hardware-level and one practical reason it matters?
6. Why does this rule "bite people constantly" specifically in bare-metal code but almost never in hosted C?
7. Which register category does a context switch routine need to save/restore, and why not the others?
8. True/false: `swtch` needs to explicitly save x0–x7. Why or why not?

---

*Source: AAPCS64 — "Procedure Call Standard for the Arm® 64-bit Architecture (AArch64)," ARM-software/abi-aa (GitHub), quarterly releases.*
