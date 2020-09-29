 package DexieMem_Nested;
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
import FIFO::*;
import FIFOF::*;
import SpecialFIFOs::*;
import BRAM::*;
import BRAMCore::*;
import Vector::*;
import DReg::*;
import DexieTypes::*;

module mkDexieMem_Nested(DexieMemIfc);
    // -------------------------------------------- INTERFACE FIFOS -----------------------------------------------------------------------------
    FIFO#(T_CoreToMemMon) 		coreMemState 		<- mkBypassFIFO();		// Create interface fifo
    FIFO#(T_MemMon_Response) 	dexMemResp 	        <- mkBypassFIFO();		// Create interface fifo

    // ---------------------------------------- STATE INFORMATION IMPORT -------------------------------------------------------------------
    Reg#(Bool) stall <- mkDReg(False); 
    Wire#(Bool) doStallOnStore <- mkDWire(False);
    Wire#(Bool) doContinueStore <- mkDWire(False);

    // Dummy for a stateless memory write monitor
    rule memStateFromCore;
        let cstate = coreMemState.first();
        let pc = cstate.pc;
        let store = cstate.m_store;
        let m_addr = cstate.m_addr;
        let m_size = cstate.m_size;
        let m_storedata = cstate.m_storedata;
        coreMemState.deq;
        $display("Received memory status! pc %h addr %h data %h", pc, m_addr, m_storedata);
        // Mem size(0-3): 8, 16, 32 or 64 bit 
        // Veriy pc, store, address, size and data
        // Dummy stops write execution exactly at pc ox270 of en_mix1
        if(pc=='h270 && m_addr=='h1ffcc && m_size==2 && m_storedata=='ha) begin
            dexMemResp.enq(T_MemMon_Response{respCode:1});
            $display("Stopping illegal memory write.");
        end
    endrule


    // ------------------------------------------- INTERFACE CONNECTIONS -------------------------------------------------------------
    method Bool getStallSignal();
        return stall;
    endmethod

    method Bool getStallOnStoreSignal();
        return doStallOnStore;
    endmethod

    method Bool getContinueStoreSignal();
        return doContinueStore;
    endmethod


    interface core2MemMon_ifc 	= fifoToPut(coreMemState);		// Connect fifo to interface	
    interface dexMemResp_ifc	= fifoToGet(dexMemResp);	// Connect fifo to interface
endmodule
endpackage
