import Vector::*;
import GetPut::*;
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

// ------------------------------------------------------------------------

// Configuration Data from core to DexieCF_Nested
typedef struct {
	Bit#(32) 	address;	// where to write the configuration, bitwidth=AXI
	Bit#(32) 	data;		// ...data itself
} T_FsmConfigData deriving (Bits);

// Core State2 (updated every cycle) - exported at the end of the fetch stage
typedef struct {
	Bit#(32) 	curr_pc; // use complete bitwidth here for now
	Bit#(32) 	next_pc;
	Bit#(32) 	curr_instr;
} T_RiscCoreState2 deriving (Bits, FShow);

typedef struct {
	Bool 		started;
	Bool 		reset;
} T_DexieToCfState deriving (Bits);

// Dummy response code, which are used by DExIE, but could also be deployed for other Security Monitors
typedef enum{
	Valid_Finish,
	BR_BTerr,				// branch: PC does not match any taken untaken bt entry
	Stack_overflow,			// stack: overflow
	Stack_underflow,		// stack: undeflow
	Stack_RetAddr,			// stack: return address does not match
	FM_FuncIdNotFound,		// FM: Function address not found in table
	TT_InvTransact,			// TT: invalid transaction
	AC_ReturnFromNonAcc		// AC: returning from non-accepting state
} T_cfRespCode deriving(Eq, Bits);

typedef struct {
	T_cfRespCode respCode;
} T_DexieCfResponse deriving (Bits);

interface DexieCfIfc;
	method Bool getStallSignal();
	interface Put#(T_FsmConfigData) 	dexToDexCf_Conf_ifc;	// Interface config write
	interface Put#(T_RiscCoreState2) 	coreState_ifc2;			// Interface write core state
	(* always_ready, always_enabled *)
	interface Put#(T_DexieToCfState) 	dexState_ifc;	
	interface Get#(T_DexieCfResponse) 	dexCfResp_ifc;			// Interface return interrupt+reset
endinterface

// -------------------- DExIE MEM INTERFACE DEFINITIONS --------------------------------


// Core State (updated every cycle)
typedef struct {
	Bit#(32) pc;		// PC for the memory signals
	Bool m_load;		// Specifies whether a load has started.
	Bool m_store; 		// Specifies whether a store has started. Repeated for each cycle a store is affected by stallOnStore.
	Bit#(32) m_addr; 	// The load/store address.
	Bit#(2) m_size; 	// The store size (not valid for load).
	Bit#(32) m_storedata; // The data to store (not valid for load).
	Bool m_stalling; 	// Specifies whether a store is stalling due to stallOnStore (only valid if m_store is set). stallOnStore and continueStore must not combinationally depend on m_stalling.
	Bool m_willIssue;	// Specifies whether the store will be committed when DExIE does not stall it (only valid if m_load or m_store is set).
	//             Serves as a load/store valid mask for VexRiscv where another external unit could cause a stall but factoring such a stall in to m_load and m_store would cause a combinational dependency on stallOnStore.
	//             For most cores, it is set to True constantly.    stallOnStore and continueStore must not combinationally depend on m_willIssue.
} T_CoreToMemMon deriving (Bits);

// Response
typedef Int#(2) T_MemMon_RespCode;	//0=runnung & no violation, 1=violated specification
typedef struct {
	T_MemMon_RespCode respCode;
} T_MemMon_Response deriving (Bits);

// DExIE Memory Interface
interface DexieMemIfc;
	method Bool getStallSignal();
	method Bool getStallOnStoreSignal();
	method Bool getContinueStoreSignal();
	(* always_ready, always_enabled *)
	interface Put#(T_CoreToMemMon) 		core2MemMon_ifc;			// Interface write core state
	interface Get#(T_MemMon_Response) 	dexMemResp_ifc;			// Interface return interrupt+reset
endinterface

// -------------------- DExIE Reg INTERFACE DEFINITIONS --------------------------------
// Core State (updated every cycle)
typedef struct {
	Bit#(32) pc; 			// PC for the register write
	Bit#(5) r_dest;			// Destination Register
	Bit#(32) r_write_data;	// Write Data
} T_CoreToRegMon deriving (Bits);

// Response
typedef Int#(2) T_RegMon_RespCode;	//0=runnung & no violation, 1=violated specification
typedef struct {
	T_RegMon_RespCode respCode;	
} T_RegMon_Response deriving (Bits);


// DExIE Register Interface
interface DexieRegIfc;
	method Bool getStallSignal();
	(* always_ready, always_enabled *)
	interface Put#(T_CoreToRegMon) 		core2RegMon_ifc;			// Interface write core state
	interface Get#(T_RegMon_Response) 	dexRegResp_ifc;			// Interface return interrupt+reset
endinterface






