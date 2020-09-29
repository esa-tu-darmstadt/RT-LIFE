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

module taiga_wrapper_verilog (
	input wire clk,
	input wire rst,

	(* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 instruction_bram CLK" *)
	output wire        instruction_bram_clk,
	(* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 instruction_bram RST" *)
	output wire        instruction_bram_rst,
	(* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 instruction_bram ADDR" *)
	output wire [29:0] instruction_bram_addr,
	(* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 instruction_bram EN" *)
	output wire        instruction_bram_en,
	(* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 instruction_bram WE" *)
	output wire [3:0]  instruction_bram_we,
	(* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 instruction_bram DIN" *)
	output wire [31:0] instruction_bram_din,
	(* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 instruction_bram DOUT" *)
	input  wire [31:0] instruction_bram_dout,

	(* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 data_bram CLK" *)
	output wire        data_bram_clk,
	(* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 data_bram RST" *)
	output wire        data_bram_rst,
	(* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 data_bram ADDR" *)
	output wire [29:0] data_bram_addr,
	(* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 data_bram EN" *)
	output wire        data_bram_en,
	(* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 data_bram WE" *)
	output wire [3:0]  data_bram_we,
	(* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 data_bram DIN" *)
	output wire [31:0] data_bram_din,
	(* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 data_bram DOUT" *)
	input  wire [31:0] data_bram_dout,

	// AXI Bus
	// AXI Write Channels
	output wire                            m_axi_awvalid,
	input  wire                            m_axi_awready,
	//~ output wire [5:0]                      m_axi_awid,
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
	//~ input  wire [5:0]                      m_axi_bid,

	// AXI Read Channels
	output wire                            m_axi_arvalid,
	input  wire                            m_axi_arready,
	//~ output wire [5:0]                      m_axi_arid,
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
	//~ input  wire [5:0]                      m_axi_rid,
	input  wire [31:0]                     m_axi_rdata,
	input  wire [1:0]                      m_axi_rresp,
	input  wire                            m_axi_rlast,

	// AXI Cache
	// AXI Write Channels
	output wire                            m_axi_cache_awvalid,
	input  wire                            m_axi_cache_awready,
	output wire [5:0]                      m_axi_cache_awid,
	output wire [31:0]                     m_axi_cache_awaddr,
	//~ output wire [3:0]                      m_axi_cache_awregion,
	output wire [7:0]                      m_axi_cache_awlen,
	output wire [2:0]                      m_axi_cache_awsize,
	output wire [1:0]                      m_axi_cache_awburst,
	//~ output wire                            m_axi_cache_awlock,
	output wire [3:0]                      m_axi_cache_awcache,
	output wire [2:0]                      m_axi_cache_awprot,
	//~ output wire [3:0]                      m_axi_cache_awqos,

	output wire                            m_axi_cache_wvalid,
	input  wire                            m_axi_cache_wready,
	output wire [31:0]                     m_axi_cache_wdata,
	output wire [3:0]                      m_axi_cache_wstrb,
	output wire                            m_axi_cache_wlast,

	input  wire                            m_axi_cache_bvalid,
	output wire                            m_axi_cache_bready,
	input  wire [1:0]                      m_axi_cache_bresp,
	input  wire [5:0]                      m_axi_cache_bid,

	// AXI Read Channels
	output wire                            m_axi_cache_arvalid,
	input  wire                            m_axi_cache_arready,
	output wire [5:0]                      m_axi_cache_arid,
	output wire [31:0]                     m_axi_cache_araddr,
	//~ output wire [3:0]                      m_axi_cache_arregion,
	output wire [7:0]                      m_axi_cache_arlen,
	output wire [2:0]                      m_axi_cache_arsize,
	output wire [1:0]                      m_axi_cache_arburst,
	//~ output wire                            m_axi_cache_arlock,
	output wire [3:0]                      m_axi_cache_arcache,
	output wire [2:0]                      m_axi_cache_arprot,
	//~ output wire [3:0]                      m_axi_cache_arqos,

	input  wire                            m_axi_cache_rvalid,
	output wire                            m_axi_cache_rready,
	input  wire [5:0]                      m_axi_cache_rid,
	input  wire [31:0]                     m_axi_cache_rdata,
	input  wire [1:0]                      m_axi_cache_rresp,
	input  wire                            m_axi_cache_rlast,
	
	output wire                            dexie_cf_valid,
	output wire [31:0]                     dexie_cf_cur_pc,
	output wire [31:0]                     dexie_cf_cur_instruction,
	output wire [31:0]                     dexie_cf_next_pc,
	
	output wire [31:0]                     dexie_instruction_pc_dec,
	output wire [31:0]                     dexie_instruction_data_dec,
	output wire                            dexie_instruction_issued_dec,
	
	output wire [31:0]                     dexie_df_mem_pc,
	output wire                            dexie_df_mem_load,
	output wire                            dexie_df_mem_store,
	output wire [31:0]                     dexie_df_mem_addr,
	output wire [1:0]                      dexie_df_mem_len,
	output wire [31:0]                     dexie_df_mem_storedata,
	output wire                            dexie_df_mem_stalling,
	
	output wire [31:0]                     dexie_df_reg_pc,
	output wire [4:0]                      dexie_df_reg_rd_addr,
	output wire [31:0]                     dexie_df_reg_rd_val,
	
	input wire                             dexie_stall,
	input wire                             dexie_df_mem_stallOnStore,
	input wire                             dexie_df_mem_continueStore,
	
	input  wire                            irq
);

assign instruction_bram_clk = clk;
assign instruction_bram_rst = rst;
assign data_bram_clk = clk;
assign data_bram_rst = rst;

wire [5:0]                      m_axi_awid;
wire [5:0]                      m_axi_bid;
wire [5:0]                      m_axi_arid;
wire [5:0]                      m_axi_rid;


taiga_wrapper taiga_wrapper (
	.clk(clk),
	.rst(rst),

	.instruction_bram_addr(instruction_bram_addr),
	.instruction_bram_en(instruction_bram_en),
	.instruction_bram_we(instruction_bram_we),
	.instruction_bram_din(instruction_bram_din),
	.instruction_bram_dout(instruction_bram_dout),

	.data_bram_addr(data_bram_addr),
	.data_bram_en(data_bram_en),
	.data_bram_we(data_bram_we),
	.data_bram_din(data_bram_din),
	.data_bram_dout(data_bram_dout),

	// AXI Bus
	.m_axi_awvalid(m_axi_awvalid),
	.m_axi_awready(m_axi_awready),
	.m_axi_awid(m_axi_awid),
	.m_axi_awaddr(m_axi_awaddr),
	//~ .m_axi_awregion(m_axi_awregion),
	.m_axi_awlen(m_axi_awlen),
	.m_axi_awsize(m_axi_awsize),
	.m_axi_awburst(m_axi_awburst),
	//~ .m_axi_awlock(m_axi_awlock),
	.m_axi_awcache(m_axi_awcache),
	//~ .m_axi_awprot(m_axi_awprot),
	//~ .m_axi_awqos(m_axi_awqos),

	.m_axi_wvalid(m_axi_wvalid),
	.m_axi_wready(m_axi_wready),
	.m_axi_wdata(m_axi_wdata),
	.m_axi_wstrb(m_axi_wstrb),
	.m_axi_wlast(m_axi_wlast),

	.m_axi_bvalid(m_axi_bvalid),
	.m_axi_bready(m_axi_bready),
	.m_axi_bresp(m_axi_bresp),
	.m_axi_bid(m_axi_bid),

	.m_axi_arvalid(m_axi_arvalid),
	.m_axi_arready(m_axi_arready),
	.m_axi_arid(m_axi_arid),
	.m_axi_araddr(m_axi_araddr),
	//~ .m_axi_arregion(m_axi_arregion),
	.m_axi_arlen(m_axi_arlen),
	.m_axi_arsize(m_axi_arsize),
	.m_axi_arburst(m_axi_arburst),
	//~ .m_axi_arlock(m_axi_arlock),
	.m_axi_arcache(m_axi_arcache),
	//~ .m_axi_arprot(m_axi_arprot),
	//~ .m_axi_arqos(m_axi_arqos),

	.m_axi_rvalid(m_axi_rvalid),
	.m_axi_rready(m_axi_rready),
	.m_axi_rid(m_axi_rid),
	.m_axi_rdata(m_axi_rdata),
	.m_axi_rresp(m_axi_rresp),
	.m_axi_rlast(m_axi_rlast),

	// AXI Cache
	.axi_awvalid(m_axi_cache_awvalid),
	.axi_awready(m_axi_cache_awready),
	.axi_awid(m_axi_cache_awid),
	.axi_awaddr(m_axi_cache_awaddr),
	//~ .axi_awregion(m_axi_cache_awregion),
	.axi_awlen(m_axi_cache_awlen),
	.axi_awsize(m_axi_cache_awsize),
	.axi_awburst(m_axi_cache_awburst),
	//~ .axi_awlock(m_axi_cache_awlock),
	.axi_awcache(m_axi_cache_awcache),
	.axi_awprot(m_axi_cache_awprot),
	//~ .axi_awqos(m_axi_cache_awqos),

	.axi_wvalid(m_axi_cache_wvalid),
	.axi_wready(m_axi_cache_wready),
	.axi_wdata(m_axi_cache_wdata),
	.axi_wstrb(m_axi_cache_wstrb),
	.axi_wlast(m_axi_cache_wlast),

	.axi_bvalid(m_axi_cache_bvalid),
	.axi_bready(m_axi_cache_bready),
	.axi_bresp(m_axi_cache_bresp),
	.axi_bid(m_axi_cache_bid),

	.axi_arvalid(m_axi_cache_arvalid),
	.axi_arready(m_axi_cache_arready),
	.axi_arid(m_axi_cache_arid),
	.axi_araddr(m_axi_cache_araddr),
	//~ .axi_arregion(m_axi_cache_arregion),
	.axi_arlen(m_axi_cache_arlen),
	.axi_arsize(m_axi_cache_arsize),
	.axi_arburst(m_axi_cache_arburst),
	//~ .axi_arlock(m_axi_cache_arlock),
	.axi_arcache(m_axi_cache_arcache),
	.axi_arprot(m_axi_cache_arprot),
	//~ .axi_arqos(m_axi_cache_arqos),

	.axi_rvalid(m_axi_cache_rvalid),
	.axi_rready(m_axi_cache_rready),
	.axi_rid(m_axi_cache_rid),
	.axi_rdata(m_axi_cache_rdata),
	.axi_rresp(m_axi_cache_rresp),
	.axi_rlast(m_axi_cache_rlast),
	
	.dexie_cf_valid          (dexie_cf_valid),
	.dexie_cf_cur_pc         (dexie_cf_cur_pc),
	.dexie_cf_cur_instruction(dexie_cf_cur_instruction),
	.dexie_cf_next_pc        (dexie_cf_next_pc),
	
	.dexie_instruction_pc_dec    (dexie_instruction_pc_dec),
	.dexie_instruction_data_dec  (dexie_instruction_data_dec),
	.dexie_instruction_issued_dec(dexie_instruction_issued_dec),
	
	.dexie_df_mem_pc           (dexie_df_mem_pc           ),
	.dexie_df_mem_load         (dexie_df_mem_load         ),
	.dexie_df_mem_store        (dexie_df_mem_store        ),
	.dexie_df_mem_addr         (dexie_df_mem_addr         ),
	.dexie_df_mem_len          (dexie_df_mem_len          ),
	.dexie_df_mem_storedata    (dexie_df_mem_storedata    ),
	.dexie_df_mem_stalling     (dexie_df_mem_stalling     ),
	
	.dexie_df_reg_pc           (dexie_df_reg_pc           ),
	.dexie_df_reg_rd_addr      (dexie_df_reg_rd_addr      ),
	.dexie_df_reg_rd_val       (dexie_df_reg_rd_val       ),
	
	.dexie_stall               (dexie_stall               ),
	.dexie_df_mem_stallOnStore (dexie_df_mem_stallOnStore ),
	.dexie_df_mem_continueStore(dexie_df_mem_continueStore),
	
	.timer_interrupt(0),
	.interrupt(irq)
);

endmodule
