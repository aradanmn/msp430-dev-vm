---
name: Zed IDE setup for MSP430
description: Zed configured with build/flash/debug tasks and GDB terminal debugging (graphical debugger incompatible due to GDB 9.1 < 14.1 requirement)
type: reference
---

Zed is set up as the MSP430 IDE with:
- `.zed/tasks.json` — Build, Flash, Build+Flash, Disassemble, Clean, GDB Server, Debug (GDB) tasks
- `.gdbinit` at project root — auto-connects to mspdebug on :2000, prints registers after every step
- `Makefile.template` has `gdb-server` and `debug` targets
- MSP430 Assembly extension installed at ~/Documents/zed-msp430-asm/ and active in Zed

**Limitation:** Zed's graphical debugger (DAP) requires GDB 14.1+. The MSP430 toolchain ships GDB 9.1, so debugging uses terminal tabs instead of the GUI panel.

**Debug workflow:** Run "MSP430: GDB Server" task first (opens mspdebug on port 2000), then "MSP430: Debug (GDB)" in a second terminal tab.
