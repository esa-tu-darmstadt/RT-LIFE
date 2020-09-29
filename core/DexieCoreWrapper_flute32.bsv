package DexieCoreWrapper_flute32;
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
	import Assert::*;
	
	import GetPut::*;
	import ClientServer::*;
	
	import AXI4_Lite_Slave::*;
	import AXI4_Lite_Types::*;
	import GenericAxi4LiteSlave::*;
	import AXI4_Slave::*;
	import AXI4_Types::*;
	import AXI4_Master::*;
	
	import DexieCore::*;
	
	//From Flute
	import TV_Info::*;
	import DExIE_Info::*;
	
	interface DexieIntf_FluteRV32;
		//Passing through the DexieIntf of mkDexieCore here would not work
		//since some of its always_enabled Action methods are used by the wrapper.
		
		interface GenericAxi4LiteSlave#(16, 32) s_axi_ctrl;			// interface for start and stop of cumputations
		interface AXI4_Slave#(32, 32, 6, 0) 	s_axi_bram; 		// interface for transition table
		interface AXI4_Master#(32, 32, 6, 0)	m_axi_cpu_mem;
		
		//Tandem Verifier interface before the encoder (modified Flute with -D TANDEM_VERIF_DIRECT)
		interface Put#(Trace_Data)  trace_data_in;
		//Use a copy of the core's RDY_trace_data_out_get as an enable condition for trace_data_in.put(.).
		(* always_ready, always_enabled *)
		method Action trace_data_rdy(Bool rdy);
		
		//DExIE taps from Stage 1 (modified Flute with -D INCLUDE_DEXIE_TAP). Rather large combinatorial path.
		interface Put#(Dexie_CFData)     dexie_cfdata_in;
		interface Put#(Dexie_DFMemData)  dexie_dfmemdata_in;
		//DExIE Writeback Taps from Stage 2.
		interface Put#(Dexie_DFRegData)  dexie_dfregdata_in;
		//Use a copy of the core's RDY_dexie_data_out_get as an enable condition for dexie_data_in.put(.).
		(* always_ready, always_enabled *)
		method Action dexie_cfdata_rdy(Bool rdy);
		(* always_ready, always_enabled *)
		method Action dexie_dfmemdata_rdy(Bool rdy);
		(* always_ready, always_enabled *)
		method Action dexie_dfregdata_rdy(Bool rdy);
		
		//Soft reset
		interface Client #(Bool, Bool)  cpu_reset_client;
		//Use a copy of the core's RDY_cpu_reset_server_request_put as an enable condition for cpu_reset_client.request.get(.).
		(* always_ready, always_enabled *)
		method Action cpu_reset_request_rdy(Bool rdy);
		//Use a copy of the core's RDY_cpu_reset_server_response_get as an enable condition for cpu_reset_client.response.put(.).
		(* always_ready, always_enabled *)
		method Action cpu_reset_response_rdy(Bool rdy);
		
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
	module mkDexieCoreWrapper_flute32(DexieIntf_FluteRV32);
		DexieIntf dexieCore <- mkDexieCore(True); //dexie_stall affects stores directly
		
		Wire#(Dexie_CFData)    cur_dexie_cfdata <- mkWire;
		Wire#(Dexie_DFMemData) cur_dexie_dfmemdata <- mkWire;
		Wire#(Dexie_DFRegData) cur_dexie_dfregdata <- mkWire;
		
		rule processDexieCFData_Valid;
			//If new CF data has arrived through the Put interface, forward it to DExIE.
			dexieCore.cfdata(True, cur_dexie_cfdata.instr, cur_dexie_cfdata.pc, cur_dexie_cfdata.next_pc);
		endrule
		(* descending_urgency = "processDexieCFData_Valid, processDexieCFData_Invalid" *)
		rule processDexieCFData_Invalid;
			//If no new CF data is available, set the valid signal to False.
			dexieCore.cfdata(False, ?, ?, ?);
		endrule
		
		rule processDexieDFMemData_Valid;
			//If new DF memory data has arrived through the Put interface, forward it to DExIE.
			//There is no additional condition on whether a store would commit without stallOnStore.
			// Therefore, set m_willIssue to True.
			dexieCore.mem(cur_dexie_dfmemdata.pc, cur_dexie_dfmemdata.load, cur_dexie_dfmemdata.store,
				cur_dexie_dfmemdata.addr, cur_dexie_dfmemdata.len, cur_dexie_dfmemdata.storeval,
				cur_dexie_dfmemdata.stalling, True);
		endrule
		(* descending_urgency = "processDexieDFMemData_Valid, processDexieDFMemData_Invalid" *)
		rule processDexieDFMemData_Invalid;
			//If no new DF memory data is available, set the read,store signals to False.
			dexieCore.mem(?, False, False, ?, ?, ?, False, True);
		endrule
		
		rule processDexieDFRegData_Valid;
			//If new DF register writeback data has arrived through the Put interface, forward it to DExIE.
			dexieCore.reg_write(cur_dexie_dfregdata.pc, 
				cur_dexie_dfregdata.r_dest, cur_dexie_dfregdata.r_data);
		endrule
		(* descending_urgency = "processDexieDFRegData_Valid, processDexieDFRegData_Invalid" *)
		rule processDexieDFRegData_Invalid;
			//If no new DF register writeback data is available, set the register address to 0.
			dexieCore.reg_write(?, 0, ?);
		endrule
		
		Reg#(Bool) softReset_Pending <- mkReg(True);
		Wire#(Bool) resetGet <- mkDWire(False);
		rule updateReset;
			if (dexieCore.rst()) begin
				//Initiate a soft reset once the hard reset is done.
				softReset_Pending <= True;
			end
			else if (resetGet) begin
				//If the core has called get() on the soft reset interface,
				// disable the reset request for the next call.
				softReset_Pending <= False;
			end
		endrule
		
		//Copies of the RDY signals of the corresponding Get/Put interfaces on the Flute core.
		//Used as additional ready conditions for the Get/Put interfaces on the Wrapper.
		//Since the RDY wire of the Get/Put is connected to the EN of the corresponding Put/Get on the other end,
		// these additional signals are used in order to enable the interface methods in the core only when they are ready.
		//This method depends on the fact that the wrapper interface methods are always ready, except for the manually added condition.
		Wire#(Bool) traceDataPutRDY <- mkWire;
		Wire#(Bool) dexieCFDataPutRDY <- mkWire;
		Wire#(Bool) dexieDFMemDataPutRDY <- mkWire;
		Wire#(Bool) dexieDFRegDataPutRDY <- mkWire;
		Wire#(Bool) cpuResetRequestGetRDY <- mkWire;
		Wire#(Bool) cpuResetResponsePutRDY <- mkWire;
		
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
		
		method Action trace_data_rdy(Bool rdy);
			traceDataPutRDY <= rdy;
		endmethod
		method Action dexie_cfdata_rdy(Bool rdy);
			dexieCFDataPutRDY <= rdy;
		endmethod
		method Action dexie_dfmemdata_rdy(Bool rdy);
			dexieDFMemDataPutRDY <= rdy;
		endmethod
		method Action dexie_dfregdata_rdy(Bool rdy);
			dexieDFRegDataPutRDY <= rdy;
		endmethod
		method Action cpu_reset_request_rdy(Bool rdy);
			cpuResetRequestGetRDY <= rdy;
		endmethod
		method Action cpu_reset_response_rdy(Bool rdy);
			cpuResetResponsePutRDY <= rdy;
		endmethod
		
		interface Put trace_data_in;
			method Action put(Trace_Data in) if (traceDataPutRDY);
				//Data not used
			endmethod
		endinterface
		
		//Interfaces for the CF and DF data messages.
		interface Put dexie_cfdata_in;
			method Action put(Dexie_CFData in) if (dexieCFDataPutRDY);
				cur_dexie_cfdata <= in;
			endmethod
		endinterface
		interface Put dexie_dfmemdata_in;
			method Action put(Dexie_DFMemData in) if (dexieDFMemDataPutRDY);
				cur_dexie_dfmemdata <= in;
			endmethod
		endinterface
		interface Put dexie_dfregdata_in;
			method Action put(Dexie_DFRegData in) if (dexieDFRegDataPutRDY);
				cur_dexie_dfregdata <= in;
			endmethod
		endinterface
		
		//Soft reset interface.
		interface Client cpu_reset_client;
			interface Get request;
				method ActionValue#(Bool) get() if (cpuResetRequestGetRDY);
					//If the core calls get() on the reset request interface and receives True,
					// the core will initiate a soft reset.
					resetGet <= True;
					if (softReset_Pending && !dexieCore.rst())
						$display("Soft resetting Flute");
					return softReset_Pending;
				endmethod
			endinterface
			interface Put response;
				method Action put(Bool reset) if (cpuResetResponsePutRDY);
					//The core will signal completion of the soft reset using the reset response interface.
					$display("Flute reset complete");
				endmethod
			endinterface
		endinterface
		
		interface GenericAxi4LiteSlave s_axi_ctrl = dexieCore.s_axi_ctrl;
		interface AXI4_Slave s_axi_bram = dexieCore.s_axi_bram;
		interface AXI4_Master m_axi_cpu_mem = dexieCore.m_axi_cpu_mem;
	endmodule
	
endpackage