# Tutorial 02 — Toolchain & Workflow

## Overview

Your workflow has two machines:

```
Mac (edit)  ──rsync──▶  Debian VM (build + flash)  ──USB──▶  LaunchPad
```

- **Edit** `.s` files on your Mac (VS Code or any editor)
- **Build** inside the Linux VM (`msp430-elf-gcc` assembles the code)
- **Flash** from the VM to the LaunchPad via USB (`mspdebug tilib`)

The VM runs inside UTM on your Mac. USB passthrough connects the LaunchPad to the VM.

---

## Step 1 — Sync Files to the VM

On your Mac, from the repo root:

```sh
rsync -av ~/Documents/msp430-dev-vm/course/ dev@<vm-ip>:~/course/
```

Replace `<vm-ip>` with the VM's IP address (run `ip addr` inside the VM to find it). You'll only need to update this path once; after that it syncs everything under `course/`.

To make this one command, add an alias to your Mac's `~/.zshrc`:
```sh
alias sync-msp='rsync -av ~/Documents/msp430-dev-vm/course/ dev@192.168.64.x:~/course/'
```

---

## Step 2 — Build

SSH into the VM, navigate to any lesson's `examples/` or exercise directory, and run `make`.

```sh
ssh dev@<vm-ip>
cd ~/course/lesson-01-architecture/examples
make
```

Successful output looks like:
```
msp430-elf-gcc -mmcu=msp430g2553 -g -Os -Wall -Wextra -o blink.elf blink.s
```

If you see errors, check:
- Is the `#include` path correct? Count the `../../` carefully.
- Did you use `.W` vs `.B` correctly?
- Are label names spelled consistently?

**Build artifacts** (`.elf` files) must be on the **VM's local disk** — not on the shared 9p/VirtFS folder. That's why we sync first and then build inside `~/course/`.

---

## Step 3 — Flash

With the LaunchPad connected via USB and passed through to the VM:

```sh
make flash
```

This runs:
```sh
mspdebug tilib "prog blink.elf"
```

Expected output:
```
MSPDebug version 0.25 - ...
Using Olimex MSP430-JTAG-TINY or MSP-FET430UIF driver.
Initializing FET...
...
Writing  264 bytes at c000 [section: .text]...
Writing    2 bytes at fffe [section: .vectors]...
Done, 266 bytes total
```

If `mspdebug` fails:
- Check USB passthrough in UTM settings
- Run `lsusb` to confirm the LaunchPad appears (VID:PID 2047:0013)
- Try unplugging and re-plugging the LaunchPad

---

## Step 4 — View a Disassembly (Optional)

To see what machine code the assembler generated:

```sh
make disasm
```

This runs `msp430-elf-objdump -d blink.elf`. Useful for understanding what each instruction compiles to and confirming your code structure.

---

## The Makefile

Every `examples/` and `exercises/exN/` directory has a Makefile. Here's what's in it:

```makefile
TARGET  = blink          # your .s filename without extension
MCU     = msp430g2553

GCC     := $(shell which msp430-elf-gcc 2>/dev/null || which msp430-gcc 2>/dev/null)

CFLAGS  = -mmcu=$(MCU) -g -Os -Wall -Wextra

all: $(TARGET).elf

$(TARGET).elf: $(TARGET).s
    $(GCC) $(CFLAGS) -o $@ $<

flash: $(TARGET).elf
    mspdebug tilib "prog $(TARGET).elf"

disasm: $(TARGET).elf
    $(OBJDUMP) -d $(TARGET).elf

clean:
    rm -f $(TARGET).elf
```

`make` = `make all`. `make flash` implies `make all` first. `make clean` removes the `.elf`.

---

## File Layout Reference

When writing a new `.s` file, adjust the `#include` path based on how deep you are:

| File location | Include path |
|--------------|-------------|
| `examples/*.s` | `#include "../../common/msp430g2553-defs.s"` |
| `exercises/exN/*.s` | `#include "../../../common/msp430g2553-defs.s"` |
| `exercises/exN/solution/*.s` | `#include "../../../../common/msp430g2553-defs.s"` |

Getting this path wrong is the most common beginner mistake. Count the directory levels:
- `examples/` is 2 levels below `lesson-01-architecture/`, and `common/` is one sibling of `lesson-01-architecture/`, so: go up 2 levels (`../../`) then down into `common/`.

---

## Editing on the Mac

Any text editor works. VS Code with the "MSP430 Assembly" or "ARM Assembly" syntax extension gives decent highlighting. The important thing is to save as plain text with `.s` extension.

**Tab vs spaces:** The GNU assembler doesn't care. Use whatever your editor inserts.

**Line endings:** Use Unix line endings (LF, not CRLF). VS Code handles this automatically on Mac.

---

## Next Step

You're ready to run the example. Open a terminal, sync, SSH in, and:

```sh
cd ~/course/lesson-01-architecture/examples
make flash
```

Watch the Red LED on the LaunchPad blink. Then attempt the exercises.
