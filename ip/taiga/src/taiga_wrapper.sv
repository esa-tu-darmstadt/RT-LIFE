/*
 * Copyright © 2019 Carsten Heinz
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
 */

import taiga_config::*;
import taiga_types::*;
import l2_config_and_types::*;

module taiga_wrapper (
	input logic clk,
	input logic rst,

	output wire [29:0] instruction_bram_addr,
	output wire        instruction_bram_en,
	output wire [3:0]  instruction_bram_we,
	output wire [31:0] instruction_bram_din,
	input  wire [31:0] instruction_bram_dout,

	output wire [29:0] data_bram_addr,
	output wire        data_bram_en,
	output wire [3:0]  data_bram_we,
	output wire [31:0] data_bram_din,
	input  wire [31:0] data_bram_dout,

	// AXI Bus
	// AXI Write Channels
	output wire                            m_axi_awvalid,
	input  wire                            m_axi_awready,
	output wire [5:0]                      m_axi_awid,
	output wire [31:0]                     m_axi_awaddr,
	//~ output wire [3:0]                      m_axi_awregion,
	output wire [7:0]                      m_axi_awlen,
	output wire [2:0]                      m_axi_awsize,
	output wire [1:0]                      m_axi_awburst,
	//~ output wire                            m_axi_awlock,
	output wire [3:0]                      m_axi_awcache,
	//~ output wire [2:0]                      m_axi_awprot,
	//~ output wire [3:0]                      m_axi_awqos,

	output wire                            m_axi_wvalid,
	input  wire                            m_axi_wready,
	output wire [31:0]                     m_axi_wdata,
	output wire [3:0]                      m_axi_wstrb,
	output wire                            m_axi_wlast,

	input  wire                            m_axi_bvalid,
	output wire                            m_axi_bready,
	input  wire [1:0]                      m_axi_bresp,
	input  wire [5:0]                      m_axi_bid,

	// AXI Read Channels
	output wire                            m_axi_arvalid,
	input  wire                            m_axi_arready,
	output wire [5:0]                      m_axi_arid,
	output wire [31:0]                     m_axi_araddr,
	//~ output wire [3:0]                      m_axi_arregion,
	output wire [7:0]                      m_axi_arlen,
	output wire [2:0]                      m_axi_arsize,
	output wire [1:0]                      m_axi_arburst,
	//~ output wire                            m_axi_arlock,
	output wire [3:0]                      m_axi_arcache,
	//~ output wire [2:0]                      m_axi_arprot,
	//~ output wire [3:0]                      m_axi_arqos,

	input  wire                            m_axi_rvalid,
	output wire                            m_axi_rready,
	input  wire [5:0]                      m_axi_rid,
	input  wire [31:0]                     m_axi_rdata,
	input  wire [1:0]                      m_axi_rresp,
	input  wire                            m_axi_rlast,

	// AXI Cache
	// AXI Write Channels
	output wire                            axi_awvalid,
	input  wire                            axi_awready,
	output wire [5:0]                      axi_awid,
	output wire [31:0]                     axi_awaddr,
	//~ output wire [3:0]                      axi_awregion,
	output wire [7:0]                      axi_awlen,
	output wire [2:0]                      axi_awsize,
	output wire [1:0]                      axi_awburst,
	//~ output wire                            axi_awlock,
	output wire [3:0]                      axi_awcache,
	output wire [2:0]                      axi_awprot,
	//~ output wire [3:0]                      axi_awqos,

	output wire                            axi_wvalid,
	input  wire                            axi_wready,
	output wire [31:0]                     axi_wdata,
	output wire [3:0]                      axi_wstrb,
	output wire                            axi_wlast,

	input  wire                            axi_bvalid,
	output wire                            axi_bready,
	input  wire [1:0]                      axi_bresp,
	input  wire [5:0]                      axi_bid,

	// AXI Read Channels
	output wire                            axi_arvalid,
	input  wire                            axi_arready,
	output wire [5:0]                      axi_arid,
	output wire [31:0]                     axi_araddr,
	//~ output wire [3:0]                      axi_arregion,
	output wire [7:0]                      axi_arlen,
	output wire [2:0]                      axi_arsize,
	output wire [1:0]                      axi_arburst,
	//~ output wire                            axi_arlock,
	output wire [3:0]                      axi_arcache,
	output wire [2:0]                      axi_arprot,
	//~ output wire [3:0]                      axi_arqos,

	input  wire                            axi_rvalid,
	output wire                            axi_rready,
	input  wire [5:0]                      axi_rid,
	input  wire [31:0]                     axi_rdata,
	input  wire [1:0]                      axi_rresp,
	input  wire                            axi_rlast,
	
	output wire        dexie_cf_valid,
	output wire [31:0] dexie_cf_cur_pc,
	output wire [31:0] dexie_cf_cur_instruction,
	output wire [31:0] dexie_cf_next_pc,
	
	output wire [31:0] dexie_instruction_pc_dec,
	output wire [31:0] dexie_instruction_data_dec,
	output wire        dexie_instruction_issued_dec,
	
	output wire [31:0] dexie_df_mem_pc,
	output wire        dexie_df_mem_load,
	output wire        dexie_df_mem_store,
	output wire [31:0] dexie_df_mem_addr,
	output wire [1:0]  dexie_df_mem_len,
	output wire [31:0] dexie_df_mem_storedata,
	output wire        dexie_df_mem_stalling,
	
	output wire [31:0] dexie_df_reg_pc,
	output wire [4:0]  dexie_df_reg_rd_addr,
	output wire [31:0] dexie_df_reg_rd_val,
	
	input wire         dexie_stall,
	input wire         dexie_df_mem_stallOnStore,
	input wire         dexie_df_mem_continueStore,

	input logic timer_interrupt,
	input logic interrupt
);

local_memory_interface instruction_bram();
assign instruction_bram_addr = {instruction_bram.addr[27:0],2'b0};
assign instruction_bram_en = instruction_bram.en;
assign instruction_bram_we = instruction_bram.be;
assign instruction_bram_din = instruction_bram.data_in;
assign instruction_bram.data_out = instruction_bram_dout;

local_memory_interface data_bram();
assign data_bram_addr = {data_bram.addr[27:0],2'b0};
assign data_bram_en = data_bram.en;
assign data_bram_we = data_bram.be;
assign data_bram_din = data_bram.data_in;
assign data_bram.data_out = data_bram_dout;

axi_interface m_axi();
assign m_axi_awvalid = m_axi.awvalid;
assign m_axi.awready = m_axi_awready;
assign m_axi_awid = m_axi.awid;
assign m_axi_awaddr = m_axi.awaddr;
assign m_axi_awlen = m_axi.awlen;
assign m_axi_awsize = m_axi.awsize;
assign m_axi_awburst = m_axi.awburst;
assign m_axi_awcache = m_axi.awcache;

assign m_axi_wvalid = m_axi.wvalid;
assign m_axi.wready = m_axi_wready;
assign m_axi_wdata = m_axi.wdata;
assign m_axi_wstrb = m_axi.wstrb;
assign m_axi_wlast = m_axi.wlast;

assign m_axi.bvalid = m_axi_bvalid;
assign m_axi_bready = m_axi.bready;
assign m_axi.bresp = m_axi_bresp;
assign m_axi.bid = m_axi_bid;

assign m_axi_arvalid = m_axi.arvalid;
assign m_axi.arready = m_axi_arready;
assign m_axi_arid = m_axi.arid;
assign m_axi_araddr = m_axi.araddr;
assign m_axi_arlen = m_axi.arlen;
assign m_axi_arsize = m_axi.arsize;
assign m_axi_arburst = m_axi.arburst;
assign m_axi_arcache = m_axi.arcache;

assign m_axi.rvalid = m_axi_rvalid;
assign m_axi_rready = m_axi.rready;
assign m_axi.rid = m_axi_rid;
assign m_axi.rdata = m_axi_rdata;
assign m_axi.rresp = m_axi_rresp;
assign m_axi.rlast = m_axi_rlast;

avalon_interface m_avalon();
wishbone_interface m_wishbone();

l2_requester_interface l2[L2_NUM_PORTS-1:0]();
//assign l2[1].request = 0;
assign l2[1].request_push = 0;
assign l2[1].wr_data_push = 0;
assign l2[1].inv_ack = l2[1].inv_valid;
assign l2[1].rd_data_ack = l2[1].rd_data_valid;

l2_memory_interface arb_mem();

dexie_interface dexie();

assign dexie_cf_valid = dexie.cf_valid;
assign dexie_cf_cur_pc = dexie.cf_cur_pc;
assign dexie_cf_cur_instruction = dexie.cf_cur_instruction;
assign dexie_cf_next_pc = dexie.cf_next_pc;

assign dexie_instruction_pc_dec = dexie.instruction_pc_dec;
assign dexie_instruction_data_dec = dexie.instruction_data_dec;
assign dexie_instruction_issued_dec = dexie.instruction_issued_dec;

assign dexie_df_mem_pc            = dexie.df_mem_pc;
assign dexie_df_mem_load          = dexie.df_mem_load;
assign dexie_df_mem_store         = dexie.df_mem_store;
assign dexie_df_mem_addr          = dexie.df_mem_addr;
assign dexie_df_mem_len           = dexie.df_mem_len;
assign dexie_df_mem_storedata     = dexie.df_mem_storedata;
assign dexie_df_mem_stalling      = dexie.df_mem_stalling;

assign dexie_df_reg_pc            = dexie.df_reg_pc;
assign dexie_df_reg_rd_addr       = dexie.df_reg_rd_addr;
assign dexie_df_reg_rd_val        = dexie.df_reg_rd_val;

assign dexie.stall                = dexie_stall;
assign dexie.df_mem_stallOnStore  = dexie_df_mem_stallOnStore;
assign dexie.df_mem_continueStore = dexie_df_mem_continueStore;

taiga taiga (
	.clk(clk),
	.rst(rst),

	.instruction_bram(instruction_bram),
	.data_bram(data_bram),

	.m_axi(m_axi),
	.m_avalon(m_avalon),
	.m_wishbone(m_wishbone),
	.dexie(dexie),
	.l2(l2[0]),

	.timer_interrupt(0),
	.interrupt(0)
);

l2_arbiter l2_arb (
	.clk(clk),
	.rst(rst),
	.request(l2),
	.mem(arb_mem)
);

axi_to_arb l2_to_mem (
	.clk(clk),
	.rst(rst),
	.l2(arb_mem),
	.* // e.g. axi_*
);

endmodule
