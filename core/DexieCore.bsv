package DexieCore;
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

	import FIFOF::*;
	import FIFO::*;
	import SpecialFIFOs::*;

	import BRAM::*;
	import BRAMCore::*;
	
	import RegFile::*;
	import GetPut::*;
	import DexieTypes::*;
	import DexieCF_Nested::*;
	import DexieMem_Nested::*;
	import DexieReg_Nested::*;
	
	
	interface DexieIntf;
		interface GenericAxi4LiteSlave#(16, 32) s_axi_ctrl;			// interface for start and stop of cumputations
		interface AXI4_Slave#(32, 32, 6, 0) 	s_axi_bram; 		// interface for transition table
		interface AXI4_Master#(32, 32, 6, 0)	m_axi_cpu_mem;
		
		//cf_valid: Valid signal for the other cf_* signals.
		//cf_curInst: Current instruction word. May also be a compressed instruction (16 bit).
		//cf_curPC: Program Counter of the current instruction word.
		//cf_nextPC: Confirmed next Program Counter.
		(* always_enabled *)
		method Action cfdata(Bool cf_valid, Bit#(32) cf_curInst, Bit#(32) cf_curPC, Bit#(32) cf_nextPC);
		
		//pc: PC for the memory signals.
		//m_load: Specifies whether a load has started.
		//m_store: Specifies whether a store has started. Repeated for each cycle a store is affected by stallOnStore.
		//m_addr: The load/store address.
		//m_size: The store size (not valid for load).
		//m_storedata: The data to store (not valid for load).
		//m_stalling: Specifies whether a store is stalling due to stallOnStore (only valid if m_store is set).
		//             stallOnStore and continueStore must not combinationally depend on m_stalling.
		//m_willIssue: Specifies whether the store will be committed when DExIE does not stall it (only valid if m_load or m_store is set).
		//             Serves as a load/store valid mask for VexRiscv where another external unit could cause a stall
		//               but factoring such a stall in to m_load and m_store would cause a combinational dependency on stallOnStore.
		//             For most cores, it is set to True constantly.
		//             stallOnStore and continueStore must not combinationally depend on m_willIssue.
		(* always_enabled *)
		method Action mem(Bit#(32) pc, Bool m_load, Bool m_store, Bit#(32) m_addr, Bit#(2) m_size, Bit#(32) m_storedata, Bool m_stalling, Bool m_willIssue);
		
		//pc: PC for the register write signals.
		//r_dest: Target integer register. Value 0 means invalid or write to x0.
		//r_write_data: Data to write.
		(* always_enabled *)
		method Action reg_write(Bit#(32) pc, Bit#(5) r_dest, Bit#(32) r_write_data);
		
		(* always_ready *)
		method Bool rst();											// return rst, rstn and irq
		(* always_ready *)
		method Bool rstn();
		(* always_ready *)
		method Bool irq();
		(* always_ready *)											// Allow dexie to stall the core. Must not combinationally depend on cfdata signals.
		method Bool stall();
		(* always_ready *)											// Allow dexie to stall the core before performing a store
		method Bool stallOnStore();
		(* always_ready *)											// Allow dexie to continue a store even with stallOnStore set
		method Bool continueStore();
	endinterface
	
	//Module parameter stallAffectsStores: Set if a stall through DexieIntf::stall() affects stores.
	//                                     If it is set, no mem store message will be generated, even if a store is being stalled by DexieIntf::stallOnStore().
	//                                     If it is not set, DexieIntf::stall() affects another stage in the core and can't directly prevent stores.
	module mkDexieCore#(Bool stallAffectsStores)(DexieIntf);
		// AXI MEM
		AXI4_Slave_Wr#(32, 32, 6, 0) wrs <- mkAXI4_Slave_Wr(32, 32, 32);
		AXI4_Slave_Rd#(32, 32, 6, 0) rds <- mkAXI4_Slave_Rd(32, 32);

		// AXI to CPU
		AXI4_Master_Wr#(32, 32, 6, 0) wrm <- mkAXI4_Master_Wr(4, 32, 32, False);
		AXI4_Master_Rd#(32, 32, 6, 0) rdm <- mkAXI4_Master_Rd(32, 32, False);

		Reg#(Bool) started 			<- mkReg(False);
		Reg#(Bool) irq_ack 			<- mkReg(False);
		Reg#(Bool) setIntr 			<- mkReg(False);

		// CSRs
		Reg#(Bit#(8)) 	exitCode 	<- mkReg(0); 
		Reg#(Bit#(32)) 	retLo 		<- mkReg(0);
		Reg#(Bit#(32)) 	retHi 		<- mkReg(0);
		Reg#(Bit#(32))  counterLo   <- mkReg(0);
		Reg#(Bit#(32))  counterHi   <- mkReg(0);
		Reg#(Bit#(32))	arg0	 	<- mkReg(0);
		Reg#(Bit#(32)) 	arg2 		<- mkReg(0);
		Reg#(Bit#(32)) 	arg3 		<- mkReg(0);
		Reg#(Bit#(32)) 	arg4 		<- mkReg(0);

		// Output wires for reset and interrupt
		Reg#(Bool) 	intr 	<- mkReg(False);
		Reg#(Bool) 	reset 	<- mkReg(True);
		Reg#(Bool) 	resetn 	<- mkReg(False);
		
		Wire#(Bool) resetBypass <- mkDWire(False);
		Wire#(Bool) resetGet <- mkDWire(True);
		Wire#(Bool) resetnGet <- mkDWire(False);

		// AXI CTRL
		List#(RegisterOperator#(16, 32)) operators = Nil;
		operators = registerHandler('h00, started, operators);
		operators = registerHandler('h0c, irq_ack, operators);
		operators = registerHandler('h10, retLo, operators);
		operators = registerHandler('h14, retHi, operators);
		operators = registerHandler('h20, arg0, operators); //arg0: Receives memory transfer address
		operators = registerHandlerRO('h30, exitCode, operators); //arg1: DExIE exit code (out only)
		operators = registerHandler('h40, arg2, operators);
		operators = registerHandler('h50, arg3, operators);
		operators = registerHandler('h60, arg4, operators);
		operators = registerHandlerRO('h70, counterLo, operators);
		operators = registerHandlerRO('h74, counterHi, operators);
		operators = registerHandler('h80, setIntr, operators);
		GenericAxi4LiteSlave#(16, 32) a4sl <- mkGenericAxi4LiteSlave(operators, 4, 4);
		

		/* AXI4 Handling */
		Reg#(Bit#(8)) 	arlen 			<- mkReg(0);
		Reg#(Bit#(8)) 	current 		<- mkReg(0);
		Reg#(Bool) 		transferStarted <- mkReg(False);
		Reg#(Bool) 		wrStarted 		<- mkReg(False);
		Reg#(Bit#(32)) 	wrAddr 			<- mkReg(0);
		Reg#(Bit#(6))   arid			<- mkReg(0);
		Reg#(Bit#(6))	wid				<- mkReg(0);

		// DExIE cf wires
		Wire#(Bit#(32)) next_pc 			<- mkDWire(0);
		Wire#(Bool)		next_pc_Valid	 	<- mkDWire(False);
		Wire#(Bit#(32)) curr_instr 			<- mkDWire(0);
		Wire#(Bit#(32)) curr_instr_pc		<- mkDWire(0);
		Wire#(Bool)		curr_instr_Valid 	<- mkDWire(False);

		// ------------------------- Counter Handling --------------------------
		rule resetCounter(!started);
			counterHi <= 0;
			counterLo <= 0;
		endrule
		rule increaseCounter(started);
			Bit#(64) counterIn = {counterHi, counterLo};
			Bit#(64) counterOut = counterIn + 1;
			counterHi <= counterOut[63:32];
			counterLo <= counterOut[31:0];
		endrule
		
		// ------------------- Interrupt and evilIRQ Handling ------------------
		function Action sendIRQ();
			action
				$display("Sending IRQ");
				intr 		<= True;
				started 	<= False;
				exitCode 	<= 0;
				//reset/resetn handled by setResets
			endaction
		endfunction
		
		function Action evilIRQ(Bit#(8) set_exitCode);
			action
				$display("Sending evil IRQ");
				intr 		<= True;
				started 	<= False;
				exitCode 	<= set_exitCode;
				//reset/resetn handled by setResets
			endaction
		endfunction
		
		function Action evilIRQ_Bypass(Bit#(8) set_exitCode);
			action
				resetBypass <= True;
				evilIRQ(set_exitCode);
			endaction
		endfunction
		
		rule r_setIntr(setIntr);
			if (!intr) sendIRQ();
			setIntr <= False;
		endrule
		
		(* descending_urgency = "r_setIntr, r_resetIntr" *)
		rule r_resetIntr(irq_ack);
			intr <= False;
			irq_ack <= False;
		endrule
		
		
		// -------------------------- DExIE CF --------------------------------------------------
		let cf <- mkDexieCF_Nested;

		// Forwards configuration writes to DexieCF - is called from "handleAxiBramData", 
		function Action passDexieCfConfigData(Bit#(32) addressOut, Bit#(32) dataOut);
			action
				cf.dexToDexCf_Conf_ifc.put(T_FsmConfigData{address: addressOut, data: dataOut});
			endaction
		endfunction

		// Delays, then forwards per-cycle riscv-core information
		Reg#(Bit#(32)) pcToForward 		<- mkReg(0);
		Reg#(Bit#(32)) instrToForward 	<- mkReg(0);

		rule assertInstrAndNextPCValid(curr_instr_Valid != next_pc_Valid);
			if (curr_instr_Valid) begin
				$display("core: curr_instr_Valid is set but next_pc_Valid is not");
			end
			if (next_pc_Valid) begin
				$display("core: next_pc_Valid is set but curr_instr_Valid is not");
			end
		endrule
		
		rule showStallState(cf.getStallSignal());
			$display("core: stall signal set");
		endrule

		rule forwardCoreState2ToDexieCF(curr_instr_Valid && next_pc_Valid && !cf.getStallSignal());
			$display("Forwarding state");
			cf.coreState_ifc2.put(T_RiscCoreState2{curr_pc:curr_instr_pc, next_pc:next_pc, curr_instr:curr_instr});
			$display("core: curr_pc %h", curr_instr_pc);
			$display("core: curr_inst %h", curr_instr);
			$display("core: next_pc %h", next_pc);
		endrule

		// dexie state must be seperated from risc-v-core-state, as started becomes True before instValid is True
		rule forwardDexieToCfState;
			cf.dexState_ifc.put(T_DexieToCfState{started:started, reset:reset});
		endrule

		rule getDexieCfResponse;
			let response <- cf.dexCfResp_ifc.get;
			if(response.respCode == Valid_Finish) begin
				sendIRQ();
			end else  begin
				evilIRQ_Bypass(8'h_FF); // Uncomment line to continue running in case of evil IRQ 
			end
		endrule


		/**
		* Forwards AXI4 write requests to the external BRAM for storage into processor local memory.
		* @param addr: The AXI4 write request package accepted by the slave.
		*/
		function Action forwardWriteRequest(AXI4_Write_Rq_Addr#(32, 6, 0) addr);
			return action
				wrm.request_addr.put(addr);
			endaction;
		endfunction

		/**
		* Forwards AXI4 write data packages to the external BRAM storage.
		* @param data: The package to forward
		*/
		function Action forwardWriteData(AXI4_Write_Rq_Data#(32, 0) data);
			return action
				wrm.request_data.put(data);
			endaction;
		endfunction

		/**
		* Handles writes to the different tables.
		*/
		rule handleAXIBramWr (!wrStarted); // Read is not necessary rn.
			wrStarted <= True;
			let req <- wrs.request_addr.get();
			let address = req.addr & 32'h_00_FF_FF_FF;
			if(address >= 64) begin
				forwardWriteRequest(AXI4_Write_Rq_Addr{
					id: req.id,
					addr: 			address - 64,
					burst_length: 	req.burst_length,
					burst_size: 	req.burst_size,
					burst_type: 	req.burst_type,
					lock: 			req.lock,
					cache: 			req.cache,
					prot: 			req.prot,
					qos: 			req.qos,
					region: 		req.region,
					user: 			req.user
				});
			end
			wid <= req.id;
			wrAddr <= address;
		endrule

		/**
		* Distributes the data of the S_AXI_BRAM data channel
		*/
		// (*conflict_free = "writeStatesTT, handleAXI4BramData"*) //...we only need 1 cycle, next StateTT will be ready in #MaxJUmpTargets cycles, so no conflict here
		rule handleAXI4BramData (wrStarted && !started); // explicit guard only to please the compiler
			let reqD <- wrs.request_data.get();
			let data = reqD.data;
			if(wrAddr<64) begin
				passDexieCfConfigData(wrAddr>>2, data);	// Forward to dexieCF
			end else begin
				forwardWriteData(reqD); 				// Write in programm memory, no need to edit adresses
			end
			if(reqD.last) begin
				wrStarted <= False;
				wrs.response.put(AXI4_Write_Rs{id: 0, resp: OKAY, user: reqD.user});
				$display("Finished transfer");
			end
		endrule
		
		/*No matter what happens, we send okay anyways.*/
		rule discardWriteResps;
			let foo <- wrm.response.get();
		endrule

		/**
		* Does nothing sensible except making sure that Tapasco doesn't crash.
		*/
		rule handleAXIBramRdReq (!transferStarted);
			let req <- rds.request.get();
			arlen <= pack(req.burst_length);
			transferStarted <= True;
		endrule
		
		rule putAXIBramRdRes (transferStarted && current <= arlen);
			rds.response.put(AXI4_Read_Rs{id: 0, data: 0, resp: OKAY, last: current==arlen, user: 0});
			if(current == arlen) begin
			    transferStarted <= False;
			    current <= 0;
			end
			else
			    current <= current + 1;
		endrule

		// ---------------------------- RESET HANDLING ----------------------------------------------------------------------
		rule setResets;
			reset <= !started;
			resetn <= started;
		endrule

		//Resolves conflict between setResets, evilIRQ_Bypass and rst/rstn.
		rule setResetGet;
			resetGet <= reset;
			resetnGet <= resetn;
		endrule
		
		function Bool resetting();
			return resetGet || resetBypass;
		endfunction
		
		function Bool nresetting();
			return resetnGet && !resetBypass;
		endfunction
		
		// ----------- DExIE DATAFLOW MEMORY SIGNALS --------		
		Wire#(Bit#(32)) current_m_pc <- mkWire;
		Wire#(Bool) current_m_load <- mkWire;
		Wire#(Bool) current_m_store <- mkWire;
		Wire#(Bit#(32)) current_m_addr <- mkWire;
		Wire#(Bit#(2)) current_m_size <- mkWire;
		Wire#(Bit#(32)) current_m_storedata <- mkWire;
		Wire#(Bool) current_m_stalling <- mkWire;
		Wire#(Bool) current_m_willIssue <- mkWire;
		
		// ----------- DExIE DATAFLOW REG SIGNALS -----------
		Wire#(Bit#(32)) current_r_pc <- mkWire;
		Wire#(Bit#(5)) current_r_dest <- mkWire;
		Wire#(Bit#(32)) current_r_write_data <- mkWire;
		
				
		// ------ VERBOSE DEBUGGING -----
		rule displayDataflow;
			if (current_m_load && current_m_willIssue && resetn) begin
				$display("Core: Load pc 0x%h, m_addr 0x%h", current_m_pc, current_m_addr);
			end
			if (current_m_store && current_m_willIssue && resetn) begin
				$display("Core: Store pc 0x%h, m_addr 0x%h, m_size %d, m_write_data 0x%h, stalling %d", 
					current_m_pc, current_m_addr, current_m_size, current_m_storedata, current_m_stalling);
			end
			if (current_r_dest != 0 && resetn) begin
				$display("Core: Reg Write pc 0x%h, r_dest %d, r_write_data 0x%h", current_r_pc, current_r_dest, current_r_write_data);
			end
		endrule

		// --------- DF MEMORY -------
		let dfMem <- mkDexieMem_Nested;

		// Forward the core's state to dfMem
		rule forwardCoreState2ToDexieMem(current_m_store);
			$display("Forwarding Memory State");
			dfMem.core2MemMon_ifc.put(T_CoreToMemMon{pc:current_m_pc, m_load:current_m_load, m_store:current_m_store, m_addr:current_m_addr, m_size:current_m_size, m_storedata:current_m_storedata, m_stalling:current_m_stalling, m_willIssue:current_m_willIssue});
		endrule
		
		rule getDexieMemResponse;
			let response <- dfMem.dexMemResp_ifc.get;
			if(response.respCode == 1) begin
				evilIRQ_Bypass(8'h_FF);
			end
		endrule

		// --------------------- DExIE Reg DF --------------------------------------------
		let dfReg <- mkDexieReg_Nested;

		// Forward the core's state to dfReg
		rule forwardCoreState2ToDexieReg(current_r_dest!=0);
			$display("Forwarding Reg State");
			dfReg.core2RegMon_ifc.put(T_CoreToRegMon{pc:current_r_pc, r_dest:current_r_dest, r_write_data:current_r_write_data});
		endrule

		// Reset core, if register write was deemed illegal
		rule getDexieRegResponse;
			let response <- dfReg.dexRegResp_ifc.get;
			if(response.respCode == 1) begin
				evilIRQ_Bypass(8'h_FF);
			end
		endrule

		// --------- STALL SIGNALS ---------
		Wire#(Bool) doStallOnStore <- mkDWire(dfMem.getStallOnStoreSignal());
		Wire#(Bool) doContinueStore <- mkDWire(dfMem.getContinueStoreSignal());
		Wire#(Bool) doStall <- mkDWire(cf.getStallSignal() || dfReg.getStallSignal()|| dfMem.getStallSignal());


		// ----------------------------- METHODS AND INTERFACES ----------------------------------- 
		// CF
		method Action cfdata(Bool cf_valid, Bit#(32) cf_curInst, Bit#(32) cf_curPC, Bit#(32) cf_nextPC);
			curr_instr_Valid <= cf_valid;
			curr_instr <= cf_curInst;
			curr_instr_pc <= cf_curPC;
			next_pc_Valid <= cf_valid;
			next_pc <= cf_nextPC;
		endmethod
		// DF MEM
		method Action mem(Bit#(32) pc, Bool m_load, Bool m_store, Bit#(32) m_addr, Bit#(2) m_size, Bit#(32) m_storedata, Bool m_stalling, Bool m_willIssue);
			current_m_pc <= pc;
			current_m_load <= m_load;
			current_m_store <= m_store;
			current_m_addr <= m_addr;
			current_m_size <= m_size;
			current_m_storedata <= m_storedata;
			current_m_stalling <= m_stalling;
			current_m_willIssue <= m_willIssue;
		endmethod
		// DF REG
		method Action reg_write(Bit#(32) pc, Bit#(5) r_dest, Bit#(32) r_write_data);
			current_r_pc <= pc;
			current_r_dest <= r_dest;
			current_r_write_data <= r_write_data;
		endmethod

		method Bool rst();
			return resetting();
		endmethod

		method Bool rstn();
			return nresetting();
		endmethod

		method Bool irq();
			return intr;
		endmethod
		
		method Bool stall();
			return doStall;
		endmethod
		
		method Bool stallOnStore();
			//Use Stall on Store alongside the synchronous reset to prevent evil stores.
			return doStallOnStore || resetting();
		endmethod
		
		method Bool continueStore();
			return doContinueStore;
		endmethod

		interface GenericAxi4LiteSlave s_axi_ctrl = a4sl;

		interface AXI4_Slave s_axi_bram;
			interface AXI4_Slave_Rd_Fab rd = rds.fab;
			interface AXI4_Slave_Wr_Fab wr = wrs.fab;
		endinterface
		
		interface AXI4_Master m_axi_cpu_mem;
			interface AXI4_Master_Rd_Fab rd = rdm.fab;
			interface AXI4_Master_Wr_Fab wr = wrm.fab;
		endinterface

	endmodule

endpackage
