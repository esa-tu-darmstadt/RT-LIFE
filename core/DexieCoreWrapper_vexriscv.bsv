package DexieCoreWrapper_vexriscv;
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
	import AXI4_Lite_Slave::*;
	import AXI4_Lite_Types::*;
	import GenericAxi4LiteSlave::*;
	import AXI4_Slave::*;
	import AXI4_Types::*;
	import AXI4_Master::*;
	
	import DexieCore::*;
	
	interface DexieIntf_VexRiscv;
		//Passing through the DexieIntf of mkDexieCore here would not work
		//since some of its always_enabled Action methods are used by the wrapper.
		
		interface GenericAxi4LiteSlave#(16, 32) s_axi_ctrl;			// interface for start and stop of cumputations
		interface AXI4_Slave#(32, 32, 6, 0) 	s_axi_bram; 		// interface for transition table
		interface AXI4_Master#(32, 32, 6, 0)	m_axi_cpu_mem;
		
		//The CF signals are retrieved during the Execute stage inside the BranchPlugin.
		//valid: Valid signal for curPc, curInstr, nextPc.
		//curPc: PC of the current instruction.
		//curInstr: Current instruction word.
		//nextPc: PC of the next instruction.
		(* always_enabled *)
		method Action cf(Bool valid, Bit#(32) curPc, Bit#(32) curInstr, Bit#(32) nextPc);
		
		//m_load: Valid signal for mem_addr and mem_size for memory read operations.
		//m_store: Valid signal for mem_addr, mem_size and mem_write_data for memory store operations.
		//m_addr: Memory r/w address
		//m_size: Memory r/w operation size : 00 => 1, 01 => 2, 10 => 4 bytes
		//m_storedata: Memory store data
		//m_stalling: Signals if the memory operation is stalled by stallOnStore, and the message will repeat until it is not stalled anymore.
		//m_stuckByOthers: Signals if the memory operation stage is stalled because of something external (including but not limited to stallOnStore).
		//                 Combinationally dependant on the stall output signals.
		(* always_enabled *)
		method Action df_mem(Bit#(32) pc, Bool m_load, Bool m_store, Bit#(32) m_addr, Bit#(2) m_size, Bit#(32) m_storedata, Bool m_stalling, Bool m_stuckByOthers);
		
		//valid:  Additional valid signal.
		//r_dest: Destination register identifier (rd) for the previous instruction.
		//        Set to 0 if the mem_reg_write_data is invalid or is to be 'written' to the zero register.
		//r_write_data: Register write data.
		(* always_enabled *)
		method Action df_reg(Bool valid, Bit#(32) pc, Bit#(5) r_dest, Bit#(32) r_write_data);
		
		(* always_ready *)
		method Bool dexie_stall();
		(* always_ready *)
		method Bool dexie_df_mem_stallOnStore();
		(* always_ready *)
		method Bool dexie_df_mem_continueStore();
		
		(* always_ready *)
		method Bool rst();
		(* always_ready *)
		method Bool irq();
	endinterface
	
	(* synthesize *)
	module mkDexieCoreWrapper_vexriscv(DexieIntf_VexRiscv);
		DexieIntf dexieCore <- mkDexieCore(True); //dexie_stall affects stores directly
		
		Wire#(Bit#(32)) inst_pc <- mkDWire(0);
		
		method Action cf(Bool valid, Bit#(32) curPc, Bit#(32) curInstr, Bit#(32) nextPc);
			//Forward the current CF data to DExIE.
			dexieCore.cfdata(valid, curInstr, curPc, nextPc);
		endmethod
		
		method Action df_mem(Bit#(32) pc, Bool m_load, Bool m_store, Bit#(32) m_addr, Bit#(2) m_size, Bit#(32) m_storedata, Bool m_stalling, Bool m_stuckByOthers);
			//Forward the current DF mem data to DExIE.
			//Any VexRiscv Plugin can set the stuckByOthers signal, including the DexieStallPlugin.
			//However, if stall on store is not active but m_stuckByOthers is set, m_willIssue is set to False
			// to signal that the load/store will not actually be performed at the moment.
			dexieCore.mem(pc, m_load, m_store, m_addr, m_size, m_storedata, m_stalling, m_stalling == m_stuckByOthers);
		endmethod
		method Action df_reg(Bool valid, Bit#(32) pc, Bit#(5) r_dest, Bit#(32) r_write_data);
			//Forward the current DF reg data to DExIE.
			dexieCore.reg_write(pc, valid ? r_dest : 0, r_write_data);
		endmethod
		
		method Bool rst();
			return dexieCore.rst();
		endmethod
		method Bool irq();
			return dexieCore.irq();
		endmethod
		method Bool dexie_stall();
			return dexieCore.stall();
		endmethod
		method Bool dexie_df_mem_stallOnStore();
			return dexieCore.stallOnStore();
		endmethod
		method Bool dexie_df_mem_continueStore();
			return dexieCore.continueStore();
		endmethod
		
		interface GenericAxi4LiteSlave s_axi_ctrl = dexieCore.s_axi_ctrl;
		interface AXI4_Slave s_axi_bram = dexieCore.s_axi_bram;
		interface AXI4_Master m_axi_cpu_mem = dexieCore.m_axi_cpu_mem;
	endmodule
	
endpackage