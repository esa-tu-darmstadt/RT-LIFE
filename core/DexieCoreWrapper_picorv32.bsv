//Legacy PicoRV32 interface, not updated for recent DexieCore versions.
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
package DexieCoreWrapper_picorv32;

	import AXI4_Lite_Slave::*;
	import AXI4_Lite_Types::*;
	import GenericAxi4LiteSlave::*;
	import AXI4_Slave::*;
	import AXI4_Types::*;
	import AXI4_Master::*;
	
	import DexieCore::*;
	
	interface DexieIntf_PicoRV32;
		//Passing through the DexieIntf of mkDexieCore here would not work
		//since some of its always_enabled Action methods are used by the wrapper.
		
		interface GenericAxi4LiteSlave#(16, 32) s_axi_ctrl;			// interface for start and stop of cumputations
		interface AXI4_Slave#(32, 32, 6, 0) 	s_axi_bram; 		// interface for transition table
		interface AXI4_Master#(32, 32, 6, 0)	m_axi_cpu_mem;
		
		//instr: Current PC in the Fetch state.
		(* always_enabled *)
		method Action pc(Bit#(32) counter);
		//instr: Current instruction in the Fetch state.
		(* always_enabled *)
		method Action instr(Bit#(32) inst);
		//cf_valid: Valid signal for pc and instr.
		(* always_enabled *)
		method Action cfValid(Bool cf_valid);
		
		//m_load: Valid signal for mem_addr and mem_size for memory read operations. Set or reset during the same cycle as cfValid.
		//m_store: Valid signal for mem_addr, mem_size and mem_write_data for memory store operations. Set or reset during the same cycle as cfValid.
		//m_addr: Memory r/w address
		//m_size: Memory r/w operation size : 00 => 1, 01 => 2, 10 => 4 bytes
		//m_storedata: Memory store data
		//m_stalling: Signals if the memory operation is stalled by stallOnStore, and the message will repeat until it is not stalled anymore.
		(* always_enabled *)
		method Action mem(Bit#(32) m_pc, Bool m_load, Bool m_store, Bit#(32) m_addr, Bit#(2) m_size, Bit#(32) m_storedata, Bool m_stalling);
		
		//r_dest: Destination register identifier (rd) for the previous instruction.
		//        Set to 0 if the mem_reg_write_data is invalid or is to be 'written' to the zero register.
		//r_write_data: Register write data.
		(* always_enabled *)
		method Action reg_write(Bit#(32) r_pc, Bit#(5) r_dest, Bit#(32) r_write_data);
		
		(* always_ready *)
		method Bool dexie_stall();
		(* always_ready *)
		method Bool dexie_stallOnStore();
		(* always_ready *)
		method Bool dexie_continueStore();
		
		(* always_ready *)
		method Bool rstn();
		(* always_ready *)
		method Bool irq();
	endinterface
	
	(* synthesize *)
	module mkDexieCoreWrapper_picorv32(DexieIntf_PicoRV32);
		DexieIntf dexieCore <- mkDexieCore(True); //dexie_stall affects stores directly
		
		//Previous PC/Instruction stored for one or several cycles.
		Reg#(Bit#(32)) prev_pc <- mkReg(0);
		Reg#(Bit#(32)) prev_instr <- mkReg(0);
		Reg#(Bool) prev_cfValid <- mkReg(False);
		
		//Combinatorial PC/Instruction signals from the current cycle.
		Wire#(Bit#(32)) cur_pc <- mkWire;
		Wire#(Bit#(32)) cur_instr <- mkWire;
		Wire#(Bool) cur_cfValid <- mkDWire(False);
		
		rule updateCFSignals;
			if (cur_cfValid) $display("Wrapper: cur_pc %h, cur_instr %h", cur_pc, cur_instr);
			Bool set_prev_cfValid = prev_cfValid;
			if (cur_cfValid && prev_cfValid) begin
				//The previous PC/instruction pair is used as the 'current' instruction.
				//The PC from the just started instruction load is used as the next PC.
				dexieCore.cfdata(True, prev_instr, prev_pc, cur_pc);
			end
			else begin
				//No new data for DExIE CF.
				dexieCore.cfdata(False, ?, ?, ?);
			end
			if (cur_cfValid) begin
				//Store the PC and Instruction until the next PC is known.
				prev_pc <= cur_pc;
				prev_instr <= cur_instr;
				set_prev_cfValid = True;
			end
			if (dexieCore.rst()) begin
				//Forget the previous PC/instruction when resetting the core.
				set_prev_cfValid = False;
			end
			prev_cfValid <= set_prev_cfValid;
		endrule
		
		
		method Action pc(Bit#(32) counter);
			cur_pc <= counter;
		endmethod

		method Action instr(Bit#(32) inst);
			cur_instr <= inst;
		endmethod

		method Action cfValid(Bool cf_valid);
			cur_cfValid <= cf_valid;
		endmethod
		
		method Action mem(Bit#(32) m_pc, Bool m_load, Bool m_store, Bit#(32) m_addr, Bit#(2) m_size, Bit#(32) m_storedata, Bool m_stalling);
			//Forward the current DF mem data to DExIE.
			//There is no additional condition on whether a store would commit without stallOnStore.
			// Therefore, set m_willIssue to True.
			dexieCore.mem(m_pc, m_load, m_store, m_addr, m_size, m_storedata, m_stalling, True);
		endmethod
		
		method Action reg_write(Bit#(32) r_pc, Bit#(5) r_dest, Bit#(32) r_write_data);
			//Forward the current DF reg data to DExIE.
			dexieCore.reg_write(r_pc, r_dest, r_write_data);
		endmethod
		
		
		method Bool rstn();
			return dexieCore.rstn();
		endmethod
		method Bool irq();
			return dexieCore.irq();
		endmethod
		
		method Bool dexie_stall();
			return dexieCore.stall();
		endmethod
		method Bool dexie_stallOnStore();
			return dexieCore.stallOnStore();
		endmethod
		method Bool dexie_continueStore();
			return dexieCore.continueStore();
		endmethod
		
		interface GenericAxi4LiteSlave s_axi_ctrl = dexieCore.s_axi_ctrl;
		interface AXI4_Slave s_axi_bram = dexieCore.s_axi_bram;
		interface AXI4_Master m_axi_cpu_mem = dexieCore.m_axi_cpu_mem;
	endmodule
	
endpackage