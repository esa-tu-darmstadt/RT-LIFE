/*
 * Copyright © 2019 Eric Matthews,  Lesley Shannon
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 * Initial code developed under the supervision of Dr. Lesley Shannon,
 * Reconfigurable Computing Lab, Simon Fraser University.
 *
 * Author(s):
 *             Eric Matthews <ematthew@sfu.ca>
 */

import taiga_config::*;
import taiga_types::*;
import l2_config_and_types::*;

//DExIE interface containing all output and input signals.
interface dexie_interface;
	//Branch Unit (Decode/early Execute phase)
	logic cf_valid;
	logic [31:0] cf_cur_pc;
	logic [31:0] cf_cur_instruction;
	logic [31:0] cf_next_pc;
	
    //Decode: 
    //Early CF trace signals (not registered in contrast to trace outputs).
    logic [31:0] instruction_pc_dec;
    logic [31:0] instruction_data_dec;
    logic instruction_issued_dec;
    
    //Load Store Unit signals (Dataflow)
    logic [31:0] df_mem_pc; //PC of the current LSU operation.
    logic df_mem_load; //Set whenever a load is to be issued. Can be set even if DExIE stalls the LSU through stallOnWrite.
    logic df_mem_store; //Set whenever a store is to be issued. Set even if DExIE stalls the LSU through stallOnWrite.
    logic [31:0] df_mem_addr; //Address of the LSU operation. Valid if df_mem_load or df_mem_store is set.
    logic [1:0] df_mem_len; //Length of the LSU operation (bits 1:0 of funct3). Valid if df_mem_load or df_mem_store is set.
    logic [31:0] df_mem_storedata; //Data to store in case df_mem_store is set. Valid if df_mem_store is set.
    logic df_mem_stalling; //Set whenever a operation stalls because of DExIE. Always valid.
    
    //Writeback signals (Dataflow)
    logic [31:0] df_reg_pc; //PC of the writeback.
    logic [4:0] df_reg_rd_addr; //Current RD register address. The value 0 stands for either no writeback or a writeback to the null register.
    logic [31:0] df_reg_rd_val; //New RD value. Valid if df_reg_rd_addr != 0.
    
    //Input (from DExIE)
    logic stall; //Stalls issues from the decode phase to execution units.
    logic df_mem_stallOnStore; //If set, new stores in the LSU are stalled before being issued to the BRAM, data cache or bus.
    logic df_mem_continueStore; //If set, new stores in the LSU can proceed even if df_mem_stallOnStore is set.
    
    modport master (input stall, df_mem_stallOnStore, df_mem_continueStore,
            output cf_valid, cf_cur_pc, cf_cur_instruction, cf_next_pc,
			instruction_pc_dec, instruction_data_dec, instruction_issued_dec,
            df_mem_pc, df_mem_load, df_mem_store, df_mem_addr, df_mem_len, df_mem_storedata, df_mem_stalling,
            df_reg_pc, df_reg_rd_addr, df_reg_rd_val);
endinterface

interface axi_interface;

    logic arready;
    logic arvalid;
    logic [C_M_AXI_ADDR_WIDTH-1:0] araddr;
    logic [7:0] arlen;
    logic [2:0] arsize;
    logic [1:0] arburst;
    logic [3:0] arcache;
    logic [5:0] arid;

    //read data
    logic rready;
    logic rvalid;
    logic [C_M_AXI_DATA_WIDTH-1:0] rdata;
    logic [1:0] rresp;
    logic rlast;
    logic [5:0] rid;

    //Write channel
    //write address
    logic awready;
    logic awvalid;
    logic [C_M_AXI_ADDR_WIDTH-1:0] awaddr;
    logic [7:0] awlen;
    logic [2:0] awsize;
    logic [1:0] awburst;
    logic [3:0] awcache;
    logic [5:0] awid;

    //write data
    logic wready;
    logic wvalid;
    logic [C_M_AXI_DATA_WIDTH-1:0] wdata;
    logic [(C_M_AXI_DATA_WIDTH/8)-1:0] wstrb;
    logic wlast;

    //write response
    logic bready;
    logic bvalid;
    logic [1:0] bresp;
    logic [5:0] bid;

    modport master (input arready, rvalid, rdata, rresp, rlast, rid, awready, wready, bvalid, bresp, bid,
            output arvalid, araddr, arlen, arsize, arburst, arcache, arid, rready, awvalid, awaddr, awlen, awsize, awburst, awcache, awid,
            wvalid, wdata, wstrb, wlast, bready);


    modport slave (input arvalid, araddr, arlen, arsize, arburst, arcache,
            rready,
            awvalid, awaddr, awlen, awsize, awburst, awcache, arid,
            wvalid, wdata, wstrb, wlast, awid,
            bready,
            output arready, rvalid, rdata, rresp, rlast, rid,
            awready,
            wready,
            bvalid, bresp, bid);

endinterface

interface avalon_interface;
    logic [31:0] addr;
    logic read;
    logic write;
    logic [3:0] byteenable;
    logic [31:0] readdata;
    logic [31:0] writedata;
    logic waitrequest;
    logic readdatavalid;
    logic writeresponsevalid;

    modport master (input readdata, waitrequest, readdatavalid, writeresponsevalid,
            output addr, read, write, byteenable, writedata);
    modport slave (output readdata, waitrequest, readdatavalid, writeresponsevalid,
            input addr, read, write, byteenable, writedata);

endinterface

interface wishbone_interface;
    logic [31:0] addr;
    logic we;
    logic [3:0] sel;
    logic [31:0] readdata;
    logic [31:0] writedata;
    logic stb;
    logic cyc;
    logic ack;

    modport master (input readdata, ack,
            output addr, we, sel, writedata, stb, cyc);
    modport slave (output readdata, ack,
            input addr, we, sel, writedata, stb, cyc);

endinterface

interface l1_arbiter_request_interface;
    logic [31:0] addr;
    logic [31:0] data ;
    logic rnw ;
    logic [3:0] be;
    logic [4:0] size;
    logic is_amo;
    logic [4:0] amo;

    logic request;
    logic ack;

    function  l2_request_t to_l2 (input bit[L2_SUB_ID_W-1:0] sub_id);
        to_l2.addr = addr[31:2];
        to_l2.rnw = rnw;
        to_l2.be = be;
        to_l2.is_amo = is_amo;
        to_l2.amo_type_or_burst_size = is_amo ? amo : size;
        to_l2.sub_id = sub_id;
    endfunction

    modport master (output addr, data, rnw, be, size, is_amo, amo, request, input ack);
    modport slave (import to_l2, input addr, data, rnw, be, size, is_amo, amo, request, output ack);

endinterface

interface l1_arbiter_return_interface;
    logic [31:2] inv_addr;
    logic inv_valid;
    logic inv_ack;
    logic [31:0] data;
    logic data_valid;

    modport master (input inv_addr, inv_valid, data, data_valid, output inv_ack);
    modport slave (output inv_addr, inv_valid, data, data_valid, input inv_ack);

endinterface

