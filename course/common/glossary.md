# Glossary — MSP430 & Embedded Terminology

Quick reference for acronyms and terminology used throughout this course. Organized by category so you can scan what's relevant as new peripherals are introduced.

---

## CPU & Registers

| Term | Stands for | What it means |
|------|-----------|---------------|
| **MCU** | Microcontroller Unit | A computer on a chip: CPU + memory + peripherals in one package |
| **PC** | Program Counter | R0 — holds the address of the next instruction to execute |
| **SP** | Stack Pointer | R1 — points to the top of the stack (grows downward from 0x0400) |
| **SR** | Status Register | R2 — holds CPU flags (carry, zero, negative, GIE, CPUOFF, etc.) |
| **CG** | Constant Generator | R3 — hardware trick that encodes common constants (0, 1, 2, 4, 8, −1) without using an extra word |
| **ALU** | Arithmetic Logic Unit | The part of the CPU that performs math and bitwise operations |

## Flags & Control Bits

| Term | Stands for | What it means |
|------|-----------|---------------|
| **GIE** | General Interrupt Enable | Bit 3 of SR — must be set (1) for any interrupt to fire |
| **CPUOFF** | CPU Off | Bit 4 of SR — halts the CPU (enters low-power mode) |
| **LPM** | Low Power Mode | A sleep state where the CPU is halted; peripherals can still run and wake it via interrupt |
| **SCG0/SCG1** | System Clock Generator | SR bits that disable specific clock sources in deeper low-power modes |

## Interrupts

| Term | Stands for | What it means |
|------|-----------|---------------|
| **ISR** | Interrupt Service Routine | The function the CPU jumps to when an interrupt fires — not a register, a routine (a piece of code) |
| **IFG** | Interrupt Flag | A bit that hardware sets when an event occurs (e.g., timer overflow, button press) |
| **IE** | Interrupt Enable | A bit you set to allow a specific peripheral's IFG to trigger an ISR |
| **NMI** | Non-Maskable Interrupt | An interrupt that fires even when GIE = 0 (used for critical faults) |

## Clocks & Oscillators

| Term | Stands for | What it means |
|------|-----------|---------------|
| **DCO** | Digitally Controlled Oscillator | The MSP430's internal clock source — fast but imprecise without calibration |
| **MCLK** | Master Clock | Drives the CPU. Default source: DCO |
| **SMCLK** | Sub-Main Clock | Drives peripherals (timers, SPI, UART). Default source: DCO |
| **ACLK** | Auxiliary Clock | Low-frequency clock, typically from an external 32 kHz crystal |
| **BCS** | Basic Clock System | The peripheral that selects and divides clock sources (configured via BCSCTL1/2/3) |

## Timers

| Term | Stands for | What it means |
|------|-----------|---------------|
| **Timer_A** | Timer A | A 16-bit counter with capture/compare channels |
| **CC0, CC1, CC2** | Capture/Compare 0, 1, 2 | Timer channels — each can trigger an interrupt when the counter matches a set value |
| **CCR0** | Capture/Compare Register 0 | The value CC0 compares against (sets the timer period in Up mode) |
| **TAIV** | Timer_A Interrupt Vector | Register that tells you which CC channel (other than CC0) or overflow caused the interrupt |
| **PWM** | Pulse Width Modulation | A technique for controlling average power by rapidly switching a pin on and off at a set duty cycle |

## Communication

| Term | Stands for | What it means |
|------|-----------|---------------|
| **USCI** | Universal Serial Communication Interface | Hardware block that handles UART, SPI, and I2C |
| **UART** | Universal Asynchronous Receiver/Transmitter | Serial protocol for talking to a PC terminal (TX/RX lines, no clock) |
| **SPI** | Serial Peripheral Interface | Fast synchronous protocol (CLK + MOSI + MISO + CS) — used for displays and external memory |
| **I2C** | Inter-Integrated Circuit | Two-wire synchronous protocol (SDA + SCL) — used for sensors |
| **MOSI** | Master Out, Slave In | The data line from the MSP430 to the peripheral |
| **MISO** | Master In, Slave Out | The data line from the peripheral back to the MSP430 |
| **CLK** | Clock | The synchronization signal in SPI/I2C |
| **CS** | Chip Select | Active-low line that tells a specific SPI device "I'm talking to you" |
| **RX / TX** | Receive / Transmit | The two data lines in UART communication |

## GPIO & Ports

| Term | Stands for | What it means |
|------|-----------|---------------|
| **GPIO** | General Purpose Input/Output | Pins that can be individually configured as digital inputs or outputs |
| **P1DIR** | Port 1 Direction | Register that sets each P1 pin as input (0) or output (1) |
| **P1OUT** | Port 1 Output | Register that sets the output level of each P1 pin |
| **P1IN** | Port 1 Input | Register that reads the current state of each P1 pin |
| **P1REN** | Port 1 Resistor Enable | Enables internal pull-up/pull-down resistors (direction set by P1OUT) |
| **P1SEL** | Port 1 Select | Switches a pin from GPIO to a peripheral function (UART, SPI, etc.) |
| **BIS** | Bit Set | Instruction that sets specific bits without touching others (like `\|=` in C) |
| **BIC** | Bit Clear | Instruction that clears specific bits without touching others (like `&= ~` in C) |

## ADC

| Term | Stands for | What it means |
|------|-----------|---------------|
| **ADC** | Analog-to-Digital Converter | Converts an analog voltage to a digital number |
| **ADC10** | 10-bit ADC | The MSP430G2553's ADC — produces values 0–1023 |

## Toolchain

| Term | Stands for | What it means |
|------|-----------|---------------|
| **GAS** | GNU Assembler | The assembler (`as`) bundled with GCC — processes your `.s` files into machine code |
| **GCC** | GNU Compiler Collection | The compiler toolchain; we use `msp430-elf-gcc` which invokes GAS and the linker |
| **ELF** | Executable and Linkable Format | The binary file format produced by the toolchain (`.elf` files) |
| **WDT** | Watchdog Timer | A safety timer that resets the chip if software hangs; we disable it with `WDTPW\|WDTHOLD` |
| **eZ-FET** | Easy Emulation Flash Emulation Tool | The USB debugger built into the LaunchPad — programs and debugs the MSP430 |

## Assembly Syntax (GAS)

| Term | What it means |
|------|---------------|
| `.text` | Assembler directive — "put the following code in the Flash code section" |
| `.section` | Assembler directive — names a specific section (e.g., `.vectors` for the interrupt table) |
| `.global` | Makes a label visible to the linker (required for `_start`) |
| `.word` | Emit a 16-bit value into the output (used for the vector table) |
| `.equ` | Define a named constant (like `#define` in C) — e.g., `.equ TICK_MS, 5` |
| `#` prefix | Immediate value — a literal number, not a memory address |
| `&` prefix | Absolute address — read/write the memory at this address |
| `@` prefix | Indirect — use the value in a register as a memory address |
