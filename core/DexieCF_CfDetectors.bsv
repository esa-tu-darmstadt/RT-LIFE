import DexieTypes::*;

/* 
 * Copyright (c) 2019-2020 Embedded Systems and Applications, TU Darmstadt.
 * This file is part of RT-LIFE
 * (see https://github.com/esa-tu-darmstadt/RT-LIFE).
 *
 * Permission is hereby granted, free of charge, to any person obtaining
 * a copy of this software and associated documentation files (the "Software"),
 * to deal in the Software without restriction, including without limitation
 * the rights to use, copy, modify, merge, publish, distribute, sublicense,
 * and/or sell copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included
 * in all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
 * THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */
 
// -------------------------------------------- DETECT BRANCHES -----------------------------------------------
function Bool isConditionalBranch(Bit#(32) inst);
    Bit#(7) opcode = inst[6:0];
    return (opcode==7'b1100011);
endfunction



// --------------------------------------------- DETECT JAL -------------------------------------------------------------------------
/**
* Check if the currently started instruction is a JAL instruction.
*/
function Bool isJAL(Bit#(32) inst);
    Bit#(1) rd      = inst[7];
    Bit#(7) opcode  = inst[6:0];
    return (opcode == 7'b_1101111 && rd!=0);
endfunction

function Bool isJ(Bit#(32) inst);
    Bit#(1) rd      = inst[7];
    Bit#(7) opcode  = inst[6:0];
    return (opcode == 7'b_1101111 && rd==0);
endfunction


// --------------------------------------------- DETECT JALR -------------------------------------------------------------------------
/**
* Check if the currently started instruction is a JALR instruction. (Ret is replaced by JALR. inst 31..20 is imm 11:0, 31 is sign extension, inst 14..12 is func3)
*/		
function Bool isJALR(Bit#(32) inst);
    Bit#(7) opcode = inst[6:0];
    Bit#(3) funct3 = inst[14:12];
    return ((opcode == 7'b_1100111) && (funct3 == 3'b_000));
endfunction
