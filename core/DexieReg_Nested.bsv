package DexieReg_Nested;
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

module mkDexieReg_Nested(DexieRegIfc);
    // -------------------------------------------- INTERFACE FIFOS -----------------------------------------------------------------------------
    FIFO#(T_CoreToRegMon) 		coreRegState 		<- mkBypassFIFO();		// Create interface fifo
    FIFO#(T_RegMon_Response) 	dexRegResp 	        <- mkBypassFIFO();		// Create interface fifo

    // The stall signal can be used for more complex multicycle dicision-making.
    // It does not help to prevent illegal register writes.
    // It can stop subsequent operations from further processing the illegal value
    Reg#(Bool) stall <- mkDReg(False);

    // Dummy example for a register write detection
    rule regStateFromCore;
        $display("Received register status!");
        let coreState=coreRegState.first;
        coreRegState.deq;
        T_RegMon_RespCode resp;
        
        // Example DF-REG: Uncomment here, to prevent registers 16 and bigger from being initialized with 0x00
        /*
        // We compare PC, register ID and written data
        if(coreState.pc>10 && coreState.r_dest==16 && coreState.r_write_data==0) begin
            resp=1; // Stop the core.
        end else begin
            resp=0; // Do not stop the core.
        end
        dexRegResp.enq(T_RegMon_Response{respCode: resp});
        */
    endrule

    // ------------------------------------------- INTERFACE CONNECTIONS -------------------------------------------------------------
    method Bool getStallSignal();
        return stall;
    endmethod

    interface core2RegMon_ifc 	= fifoToPut(coreRegState);		// Connect fifo to interface	
    interface dexRegResp_ifc	= fifoToGet(dexRegResp);	// Connect fifo to interface
endmodule
endpackage
