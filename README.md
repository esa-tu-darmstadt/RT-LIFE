# RT-LIFE: A Portable Interface for Real-Time Lightweight Integrity Enforcement of RISC-V Cores


**Requirements:**   
Xilinx Vivado 2018.3 or newer  
TaPaSCo RISC-V https://github.com/esa-tu-darmstadt/tapasco-riscv  
TaPaSCo https://git.esa.informatik.tu-darmstadt.de/tapasco/tapasco  
Bluespec https://github.com/B-Lang-org/bsc  
RISC-V Toolchain https://github.com/riscv/riscv-gnu-toolchain  

**Project structure:**   
- Folder `core` contains RT-LIFE core wrappers and rudimentary SecMon dummies.  
- Folder `ip` contains the RT-LIFE extended cores. These originate from TaPaSCo RISC-V  
- Folder `testPrograms` contains a number of small application examples.  
- The project's `root directory` contains the project packaging scripts.  
- Folder `dexie_ip` contains the final resulting TaPaSCo-PE  

**First steps:**  
- Run `make binaries`    
- Use `riscv32-unknown-elf-objdump -d`, to analyse the ELF object file of a sample code snippet    
- Sample ELF object files can be found in: `testPrograms/en_*/elf`    
- Have a closer look on CF, memory write and register write instructions  

- Look into `core/DexieReg_Nested`, `core/DexieMem_Nested` and `core/DexieCF_Nested`
- Play with the dummy Security Monitors in the middle of these files

- `make taiga_pe` (or any other core)
- Using `tapasco-import`, `tapasco-compose` and `tapasco load-bitstream`, the design can be deloyed on any TaPaSCo-compatible FPGA board.

- Be aware, that the first 16 words (64 Bytes) are dummy input for the dummy Security Monitors (currently not interpreted). Subsequent data is written into the instruction memory.

**License:**

Copyright (c) 2019-2020 Embedded Systems and Applications, TU Darmstadt.
This file is part of RT-LIFE
(see https://github.com/esa-tu-darmstadt/RT-LIFE).

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the "Software"),
to deal in the Software without restriction, including without limitation
the rights to use, copy, modify, merge, publish, distribute, sublicense,
and/or sell copies of the Software, and to permit persons to whom the
Software is furnished to do so, subject to the following conditions:
The above copyright notice and this permission notice shall be included
in all copies or substantial portions of the Software.  

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.