package DexieCoreWrapper_orca;
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
	
	import Assert::*;
	
	interface DexieIntf_Orca;
		interface GenericAxi4LiteSlave#(16, 32) s_axi_ctrl;			// interface for start and stop of cumputations
		interface AXI4_Slave#(32, 32, 6, 0) 	s_axi_bram; 		// interface for transition table
		interface AXI4_Master#(32, 32, 6, 0)	m_axi_cpu_mem;
		
		//cf_valid: Valid signal for instr, pc, next_pc_prediction.
		(* always_enabled *)
		method Action cfValid(Bool cf_valid);
		//inst: Current instruction in the Execute phase.
		(* always_enabled *)
		method Action instr(Bit#(32) inst);
		//counter: Current PC in the Execute phase.
		(* always_enabled *)
		method Action pc(Bit#(32) counter);
		//counter: Prediction of the next PC.
		(* always_enabled *)
		method Action next_pc_prediction(Bit#(32) counter);
		//validated: Set if the last or current PC prediction is valid.
		(* always_enabled *)
		method Action next_pc_prediction_validated(Bool validated);
		//corrected: Set if the last PC prediction was invalid. A PC prediction can either be validated or corrected but not both.
		//counter: Corrected PC. Valid if corrected is set.
		(* always_enabled *)
		method Action next_pc_correction(Bool corrected, Bit#(32) counter);
		
		//m_load: Valid signal for mem_addr and mem_size for memory read operations. Set or reset during the same cycle as cfValid.
		//m_store: Valid signal for mem_addr, mem_size and mem_write_data for memory store operations. Set or reset during the same cycle as cfValid.
		//m_addr: Memory r/w address
		//m_size: Memory r/w operation size : 00 => 1, 01 => 2, 10 => 4 bytes
		//m_storedata: Memory store data
		//m_stalling: Signals if the memory operation is stalled by stallOnStore, and the message will repeat until it is not stalled anymore.
		(* always_enabled *)
		method Action mem(Bool m_load, Bool m_store, Bit#(32) m_addr, Bit#(2) m_size, Bit#(32) m_storedata, Bool m_stalling);
		
		//r_dest: Destination register identifier (rd) for the previous instruction.
		//        Set to 0 if the mem_reg_write_data is invalid or is to be 'written' to the zero register.
		//r_write_data: Register write data.
		(* always_enabled *)
		method Action reg_write(Bit#(5) r_dest, Bit#(32) r_write_data);
		
		(* always_ready *)
		method Bool rst();
		(* always_ready *)
		method Bool irq();
		
		(* always_ready *)
		method Bool stall();
		(* always_ready *)
		method Bool stallOnStore();
		(* always_ready *)
		method Bool continueStore();
	endinterface
	
	(* synthesize *)
	module mkDexieCoreWrapper_orca(DexieIntf_Orca);
		DexieIntf dexieCore <- mkDexieCore(True); //dexie_stall affects stores directly
		
		//Set if there is a 'last' CF message where the prediction has not been validated or corrected yet.
		Reg#(Bool) last_cfValid <- mkReg(False);
		//Set if there is a 'last' CF message of an instruction that hasn't yet finished the writeback stage.
		Reg#(Bool) last_dfValid <- mkReg(False);
		//Values from the last CF update that was not stalled.
		Reg#(Bit#(32)) last_instr <- mkReg(0);
		Reg#(Bit#(32)) last_pc <- mkReg(0);
		Reg#(Bit#(32)) last_next_pc_prediction <- mkReg(0);
		
		//Current values from the cfValid, instr, pc and next_pc_prediction methods.
		Wire#(Bool) current_cfValid <- mkWire;
		Wire#(Bit#(32)) current_instr <- mkWire;
		Wire#(Bit#(32)) current_pc <- mkWire;
		Wire#(Bit#(32)) current_next_pc_prediction <- mkWire;
		
		//Current values from the next_pc_prediction_validated and next_pc_correction methods.
		Wire#(Bool) current_next_pc_validated <- mkWire;
		Wire#(Bool) current_next_pc_corrected <- mkWire;
		Wire#(Bit#(32)) current_next_pc_correction <- mkWire;
		
		//Current values from the mem method.
		Wire#(Bool) current_m_load <- mkWire;
		Wire#(Bool) current_m_store <- mkWire;
		Wire#(Bit#(32)) current_m_addr <- mkWire;
		Wire#(Bit#(2)) current_m_size <- mkWire;
		Wire#(Bit#(32)) current_m_storedata <- mkWire;
		Wire#(Bool) current_m_stalling <- mkWire;
		
		//Current values from the reg_write method.
		Wire#(Bit#(5)) current_r_dest <- mkWire;
		Wire#(Bit#(32)) current_r_write_data <- mkWire;
		
		//Current stall signals from dexieCore.
		Wire#(Bool) isStalling <- mkDWire(False);
		Wire#(Bool) doStallOnStore <- mkDWire(False);
		Wire#(Bool) doContinueStore <- mkDWire(False);
		
		Reg#(Bool) lastStallingStore <- mkReg(False); //Set if the core stalled because of stallOnWrite during the last cycle.
		
		rule updateStalling;
			isStalling <= dexieCore.stall();
			doStallOnStore <= dexieCore.stallOnStore();
			doContinueStore <= dexieCore.continueStore();
		endrule
		rule updateLastStallingStore;
			Bool curStallingStore = current_m_stalling && current_m_store;
			lastStallingStore <= curStallingStore && !dexieCore.rst();
		endrule
		
		//Updates the last_* registers based on current_*.
		rule updateLast;
			Bool setCFValid = False;
			Bool setDFValid = lastStallingStore ? last_dfValid : False;
			if (current_cfValid && !lastStallingStore) begin
				//Assign the last instruction.
				//If we're executing a store that is/was stalled, ignore it unless it is the first instance of that store.
				last_instr <= current_instr;
				last_pc <= current_pc;
				last_next_pc_prediction <= current_next_pc_prediction;
				if (!current_next_pc_validated || last_cfValid) begin
					//Only set last_cfValid if the prediction for current_next_pc has not been validated yet.
					setCFValid = True; //Set last_cfValid for one cycle. 
				end
				if (current_r_dest == 0 || last_dfValid) begin
					//Mark the last_* registers as valid for reg_write.
					setDFValid = True;
				end
			end
			if (dexieCore.rst()) begin
				//Reset the internal valid signals if the core is being reset.
				setCFValid = False;
				setDFValid = False;
			end
			last_cfValid <= setCFValid;
			last_dfValid <= setDFValid;
		endrule
		
		//Calls the dexieCore CF methods.
		rule updateInst;
			Bool valid = False;
			Bit#(32) pcToForward = ?;
			Bit#(32) instrToForward = ?;
			Bit#(32) nextPCToForward = ?;
			if (current_cfValid && !lastStallingStore) begin
				$display("Wrapper: pc 0x%h, next_pc_prediction 0x%h, instr 0x%h", current_pc, current_next_pc_prediction, current_instr);
			end
			if (current_next_pc_validated && (!lastStallingStore || last_cfValid)) begin
				$display("current_next_pc_validated");
				//The last/current prediction for the next PC is correct.
				//Ignore this during store stalls if no 'old' instruction is pending next_pc verification/correction to prevent duplication of CF messages.
				//For syscalls, the validation occurs one cycle after the cfValid signal.
				//Otherwise (including for branches), the validation occurs simultaneously with cfValid.
				dynamicAssert(last_cfValid || current_cfValid, "Next PC validated without any valid instruction");
				valid = True;
				instrToForward = (last_cfValid ? last_instr : current_instr);
				pcToForward = (last_cfValid ? last_pc : current_pc);
				nextPCToForward = (last_cfValid ? last_next_pc_prediction : current_next_pc_prediction);
			end
			else if (current_next_pc_corrected && last_cfValid) begin
				//For branches, Orca's to_pc_correction_valid signal can be set for several cycles, even if the syscall unit inputs aren't valid anymore.
				//Generally, a branch correction is valid one cycle after to_syscall_valid (and thereby one cycle after dexie_cf_valid). 
				$display("current_next_pc_corrected");
				//The predicted next PC (from the last cycle) was wrong and the correction is available.
				valid = True;
				instrToForward = last_instr;
				pcToForward = last_pc;
				nextPCToForward = current_next_pc_correction;
			end
			else begin
				//Since there is no next PC, set the valid signals to False.
			end
			dexieCore.cfdata(valid, instrToForward, pcToForward, nextPCToForward);
		endrule
		
		
		rule updateMem;
			//Forward the current DF mem data to DExIE.
			//There is no additional condition on whether a store would commit without stallOnStore.
			// Therefore, set m_willIssue to True.
			dynamicAssert(!current_m_load || !current_m_store || current_cfValid, "mem called without matching control flow signals");
			dynamicAssert(!current_m_load || !current_m_store, "mem called with both m_read and m_write set");
			dexieCore.mem(current_pc, current_m_load, current_m_store, current_m_addr, current_m_size, current_m_storedata, current_m_stalling, True);
		endrule
		
		rule updateReg;
			//Forward the current DF reg data to DExIE.
			dynamicAssert(current_r_dest == 0 || last_dfValid, "reg_write called without matching control flow signals from the last cycle");
			//The last 'current PC' signal from the Execute phase matches the Writeback phase PC.
			dexieCore.reg_write(last_pc, current_r_dest, current_r_write_data);
		endrule
		
		method Action cfValid(Bool cf_valid);
			current_cfValid <= cf_valid;
		endmethod
		
		method Action instr(Bit#(32) inst);
			current_instr <= inst;
		endmethod
		
		method Action pc(Bit#(32) counter);
			current_pc <= counter;
		endmethod
		method Action next_pc_prediction(Bit#(32) counter);
			current_next_pc_prediction <= counter;
		endmethod
		method Action next_pc_prediction_validated(Bool validated);
			current_next_pc_validated <= validated;
		endmethod
		method Action next_pc_correction(Bool corrected, Bit#(32) counter);
			current_next_pc_corrected <= corrected;
			current_next_pc_correction <= counter;
		endmethod
		
		method Action mem(Bool m_load, Bool m_store, Bit#(32) m_addr, Bit#(2) m_size, Bit#(32) m_storedata, Bool m_stalling);
			current_m_load <= m_load;
			current_m_store <= m_store;
			current_m_addr <= m_addr;
			current_m_size <= m_size;
			current_m_storedata <= m_storedata;
			current_m_stalling <= m_stalling;
		endmethod
		
		method Action reg_write(Bit#(5) r_dest, Bit#(32) r_write_data);
			current_r_dest <= r_dest;
			current_r_write_data <= r_write_data;
		endmethod
		
		method Bool rst();
			return dexieCore.rst();
		endmethod
		method Bool irq();
			return dexieCore.irq();
		endmethod
		
		method Bool stall();
			return isStalling;
		endmethod
		method Bool stallOnStore();
			return doStallOnStore;
		endmethod
		method Bool continueStore();
			return doContinueStore;
		endmethod
		
		interface GenericAxi4LiteSlave s_axi_ctrl = dexieCore.s_axi_ctrl;
		interface AXI4_Slave s_axi_bram = dexieCore.s_axi_bram;
		interface AXI4_Master m_axi_cpu_mem = dexieCore.m_axi_cpu_mem;
	endmodule
	
endpackage