---
name: Zed MSP430 assembly extension
description: Custom Zed editor extension for MSP430 assembly syntax highlighting lives at ~/Documents/zed-msp430-asm
type: reference
---

MSP430 Assembly Zed extension: `/Users/scott/Documents/zed-msp430-asm/`

Symlinked as dev extension into Zed. Uses a forked tree-sitter-asm grammar with MSP430-specific fixes:
- `#` is immediate prefix (not comment) — comments use `;` only
- `word` supports `.b`/`.w` instruction suffixes
- `&` address prefix for absolute addressing
- `immediate` node type for `#expr` patterns

Grammar source: `grammars/asm/grammar.js` → regenerate with `tree-sitter generate` then `tree-sitter build --wasm -o ../asm.wasm`
Highlights: `languages/MSP430 Assembly/highlights.scm`

Known minor parse issues: `#include` (preprocessor) and `@progbits` (section attribute) produce ERROR nodes — doesn't affect code highlighting.
