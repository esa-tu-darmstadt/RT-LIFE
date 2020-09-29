package DexieCF_Nested;
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
	import DexieCF_CfDetectors::*;


	// interface bus_to_targ_req_ifc = fifoToPut (bus_to_targ_reqs);
	module mkDexieCF_Nested(DexieCfIfc);
		// -------------------------------------------- INTERFACE FIFOS -----------------------------------------------------------------------------
		FIFO#(T_FsmConfigData) 		dexToDexCf_Conf 		<- mkFIFO();		// Create interface fifo
		FIFO#(T_RiscCoreState2) 	dexToDexCf_CoreState2 	<- mkFIFO();		// Create interface fifo
		FIFO#(T_DexieToCfState)		dexToDexCf_DexState		<- mkFIFO();	
		FIFO#(T_DexieCfResponse) 	dexCfResp 				<- mkFIFO();		// Create interface fifo

		// ----------------------------- STATE INFO FROM DExIE CORE ----------------------------------
		rule stateInfoFromDexieCore;
			dexToDexCf_DexState.deq;
		endrule
		
		// Dummy for DExIE CF configuration writing.
		// First DExIE CF confguration is written here. Then, the core's instruction memory is written.
		rule writeCfConfiguration;
			dexToDexCf_Conf.deq;
		endrule

		// CF-Stall for multicycle operations
		Wire#(Bool) stall <- mkDWire(False);

		// For VexRiscv, stall on store and continue stall signals are needed to guarantee
		// a latency of one complete register-separated clock cycle
		
		// Dummy for checking the core's control flow
		// Stops the core, if the example code snippet "testprograms/en_if" choses the untaken branch.
		rule stateInfoFromCore2;
			let stateFromCore2 = dexToDexCf_CoreState2.first;
			dexToDexCf_CoreState2.deq;
			let curr_pc = stateFromCore2.curr_pc;
			let next_pc = stateFromCore2.next_pc;
			let curr_inst = stateFromCore2.curr_instr;
			$display("current pc %h next pc %h instruct %h", curr_pc, next_pc, curr_inst);
			// If instruction represents a conditional branch, current pc and next pc match, than reset the core
			if(isConditionalBranch(curr_inst) && curr_pc=='h1c0 && next_pc=='h1c4) begin
				dexCfResp.enq(T_DexieCfResponse{respCode:BR_BTerr});
			end
		endrule

		// ------------------------------------------- INTERFACE CONNECTIONS -------------------------------------------------------------
		method Bool getStallSignal();
			return stall;
		endmethod

		interface dexToDexCf_Conf_ifc 	= fifoToPut(dexToDexCf_Conf);		// Connect fifo to interface	
		interface coreState_ifc2		= fifoToPut(dexToDexCf_CoreState2);	// Connect fifo to interface
		interface dexState_ifc			= fifoToPut(dexToDexCf_DexState);	// Connect fifo to interface	
		interface dexCfResp_ifc 		= fifoToGet(dexCfResp);				// Connect fifo to interface
	endmodule
endpackage
