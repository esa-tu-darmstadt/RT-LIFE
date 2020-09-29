#!/bin/bash

 # 
 # Copyright (c) 2019-2020 Embedded Systems and Applications, TU Darmstadt.
 # This file is part of RT-LIFE
 # (see https://github.com/esa-tu-darmstadt/RT-LIFE).
 #
 # Permission is hereby granted, free of charge, to any person obtaining
 # a copy of this software and associated documentation files (the "Software"),
 # to deal in the Software without restriction, including without limitation
 # the rights to use, copy, modify, merge, publish, distribute, sublicense,
 # and/or sell copies of the Software, and to permit persons to whom the
 # Software is furnished to do so, subject to the following conditions:
 #
 # The above copyright notice and this permission notice shall be included
 # in all copies or substantial portions of the Software.
 #
 # THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 # IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 # FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
 # THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 # LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 # OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 # THE SOFTWARE.
 #

MARCH="rv32im"
MABI="ilp32"
FLAGS="-march=${MARCH} -mabi=${MABI} -nostdlib -T rv.ld startup.s -g"
OFLGS="-O binary -j .text.init -j .text"

#### Platform dependant
CROSS="riscv64-unknown-elf"

for d in en_*/
do
	for f in $d/*.c 
	do
		mkdir -p $d/elf/
		mkdir -p $d/bin/
		${CROSS}-gcc 		${FLAGS} -o $d/elf/${f#*/}.elf $f
		${CROSS}-objcopy 	${OFLGS} 	$d/elf/${f#*/}.elf $d/bin/${f#*/}.bin
	done
done
