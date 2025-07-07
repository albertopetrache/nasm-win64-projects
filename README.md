# Win64 NASM Starter Project

This repository contains example code for programming in **x64 assembly on Windows** using **NASM** (Netwide Assembler) and linking with **GCC** / **MinGW**.

---

## Setup & Build Instructions

1. **Install NASM**

Download and install NASM from [https://www.nasm.us/](https://www.nasm.us/).

2. **Assemble your code**

```bash
nasm -f win64 yourfile.asm -o yourfile.obj
```

- `-f win64` tells NASM to generate 64-bit Windows object files.

3. **Link with GCC**

Using MinGW-w64 or similar environment:

```bash
gcc yourfile.obj -o yourprogram.exe -lkernel32
```

- Links your object file and the Windows kernel library.

4. **Run the program**

```bash
yourprogram.exe
```

---

## Tutorial: Win64 Assembly Basics with NASM

### Registers Overview

Windows 64-bit uses the **x86-64 architecture**. Key general-purpose registers include:

| Register | Description                 |
| -------- | ---------------------------|
| `RCX`    | 1st integer argument        |
| `RDX`    | 2nd integer argument        |
| `R8`     | 3rd integer argument        |
| `R9`     | 4th integer argument        |
| `RAX`    | Return value register       |
| `RSP`    | Stack pointer              |
| `RBP`    | Base pointer (optional)     |

For floating-point arguments, the registers `XMM0` to `XMM3` are used.

---

### Calling Convention (Microsoft x64)

- **First 4 integer or pointer arguments** are passed in: `RCX`, `RDX`, `R8`, `R9`.
- **First 4 floating-point arguments** are passed in: `XMM0` to `XMM3`.
- **Additional arguments** are passed on the stack (right to left).
- The caller **allocates 32 bytes of shadow space** on the stack before calling the function.
- The stack pointer (`RSP`) must be **aligned to 16 bytes** before the call instruction.

---

### Shadow Space and Stack Alignment

- The **shadow space** is 32 bytes reserved on the stack for callees.
- You must subtract at least 32 bytes from `RSP` before calling any Windows API or function.
- Additional stack space may be allocated to maintain 16-byte alignment.

---

### Example Function Call with NASM

Calling a function with 5 integer parameters (for example):

- 1st param in `RCX`
- 2nd param in `RDX`
- 3rd param in `R8`
- 4th param in `R9`
- 5th param on the stack (at `[RSP+32]`)

Before the call, allocate 40 bytes on the stack (32 for shadow space + 8 for alignment):

- Subtract 40 from `RSP`
- Place 5th param at `[RSP+32]`
- Call function
- Restore `RSP`

---

### Accessing Parameters in the Callee

- The first 4 integer parameters are in registers `RCX`, `RDX`, `R8`, and `R9`.
- Additional parameters are found on the stack at `[RSP + 32]`, `[RSP + 40]`, etc.
- Floating-point parameters are passed in `XMM0` to `XMM3`.

---

### Additional Notes

- Use `lea reg, [rel symbol]` in NASM for RIP-relative addressing of global variables.
- Use `mov reg, [rel symbol]` to read values from global memory.
- Use `mov reg, imm` or `mov reg, reg` for immediate or register values.

---

## Helpful Commands Summary

- **Assemble:**

```bash
nasm -f win64 file.asm -o file.obj
```

- **Link:**

```bash
gcc file.obj -o program.exe -lkernel32
```

- **Run:**

```bash
./program.exe
```


