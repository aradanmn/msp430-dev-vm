---
name: Sections directive not taught
description: .text and .section directives used in every skeleton but never explained — caused a real bug when student placed #include in wrong location
type: feedback
---

The `.text` directive and section concept are used in every skeleton file but were never explicitly taught. Student hit a real bug: `#include "hal/led.s"` placed before `.text`/`_start` caused `leds_init` to land at 0xC000 instead of `_start`, breaking debugger stepping and program flow.

**Why:** Students can't reason about code placement without understanding sections. This isn't an advanced topic — it's fundamental to every file they write.

**How to apply:** Add a section to Lesson 01 explaining what `.text`, `.section ".vectors"`, and `.global _start` do. Cover: sections map to memory regions, `.text` = flash, instructions go where they're placed, `#include` is textual paste so order matters.
