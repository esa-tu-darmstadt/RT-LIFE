//Copyright 1986-2019 Xilinx, Inc. All Rights Reserved.
//--------------------------------------------------------------------------------
//Tool Version: Vivado v.2019.1 (lin64) Build 2552052 Fri May 24 14:47:09 MDT 2019
//Date        : Sun Aug 25 12:47:14 2019
//Host        : dwalin running 64-bit Fedora release 30 (Thirty)
//Command     : generate_target orca_pe_wrapper.bd
//Design      : orca_pe_wrapper
//Purpose     : IP block netlist
//--------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

module orca_pe_wrapper
   (ARESET_N,
    CLK,
    M_AXI_araddr,
    M_AXI_arburst,
    M_AXI_arcache,
    M_AXI_arid,
    M_AXI_arlen,
    M_AXI_arlock,
    M_AXI_arprot,
    M_AXI_arqos,
    M_AXI_arready,
    M_AXI_arregion,
    M_AXI_arsize,
    M_AXI_aruser,
    M_AXI_arvalid,
    M_AXI_awaddr,
    M_AXI_awburst,
    M_AXI_awcache,
    M_AXI_awid,
    M_AXI_awlen,
    M_AXI_awlock,
    M_AXI_awprot,
    M_AXI_awqos,
    M_AXI_awready,
    M_AXI_awregion,
    M_AXI_awsize,
    M_AXI_awuser,
    M_AXI_awvalid,
    M_AXI_bid,
    M_AXI_bready,
    M_AXI_bresp,
    M_AXI_buser,
    M_AXI_bvalid,
    M_AXI_rdata,
    M_AXI_rid,
    M_AXI_rlast,
    M_AXI_rready,
    M_AXI_rresp,
    M_AXI_ruser,
    M_AXI_rvalid,
    M_AXI_wdata,
    M_AXI_wlast,
    M_AXI_wready,
    M_AXI_wstrb,
    M_AXI_wvalid,
    S_AXI_BRAM_araddr,
    S_AXI_BRAM_arburst,
    S_AXI_BRAM_arcache,
    S_AXI_BRAM_arlen,
    S_AXI_BRAM_arlock,
    S_AXI_BRAM_arprot,
    S_AXI_BRAM_arqos,
    S_AXI_BRAM_arready,
    S_AXI_BRAM_arsize,
    S_AXI_BRAM_arvalid,
    S_AXI_BRAM_awaddr,
    S_AXI_BRAM_awburst,
    S_AXI_BRAM_awcache,
    S_AXI_BRAM_awlen,
    S_AXI_BRAM_awlock,
    S_AXI_BRAM_awprot,
    S_AXI_BRAM_awqos,
    S_AXI_BRAM_awready,
    S_AXI_BRAM_awsize,
    S_AXI_BRAM_awvalid,
    S_AXI_BRAM_bready,
    S_AXI_BRAM_bresp,
    S_AXI_BRAM_bvalid,
    S_AXI_BRAM_rdata,
    S_AXI_BRAM_rlast,
    S_AXI_BRAM_rready,
    S_AXI_BRAM_rresp,
    S_AXI_BRAM_rvalid,
    S_AXI_BRAM_wdata,
    S_AXI_BRAM_wlast,
    S_AXI_BRAM_wready,
    S_AXI_BRAM_wstrb,
    S_AXI_BRAM_wvalid,
    S_AXI_CTRL_araddr,
    S_AXI_CTRL_arprot,
    S_AXI_CTRL_arready,
    S_AXI_CTRL_arvalid,
    S_AXI_CTRL_awaddr,
    S_AXI_CTRL_awprot,
    S_AXI_CTRL_awready,
    S_AXI_CTRL_awvalid,
    S_AXI_CTRL_bready,
    S_AXI_CTRL_bresp,
    S_AXI_CTRL_bvalid,
    S_AXI_CTRL_rdata,
    S_AXI_CTRL_rready,
    S_AXI_CTRL_rresp,
    S_AXI_CTRL_rvalid,
    S_AXI_CTRL_wdata,
    S_AXI_CTRL_wready,
    S_AXI_CTRL_wstrb,
    S_AXI_CTRL_wvalid,
    interrupt);
  input ARESET_N;
  input CLK;
  output [31:0]M_AXI_araddr;
  output [1:0]M_AXI_arburst;
  output [3:0]M_AXI_arcache;
  output [5:0]M_AXI_arid;
  output [7:0]M_AXI_arlen;
  output M_AXI_arlock;
  output [2:0]M_AXI_arprot;
  output [3:0]M_AXI_arqos;
  input M_AXI_arready;
  output [3:0]M_AXI_arregion;
  output [2:0]M_AXI_arsize;
  output M_AXI_aruser;
  output M_AXI_arvalid;
  output [31:0]M_AXI_awaddr;
  output [1:0]M_AXI_awburst;
  output [3:0]M_AXI_awcache;
  output [5:0]M_AXI_awid;
  output [7:0]M_AXI_awlen;
  output M_AXI_awlock;
  output [2:0]M_AXI_awprot;
  output [3:0]M_AXI_awqos;
  input M_AXI_awready;
  output [3:0]M_AXI_awregion;
  output [2:0]M_AXI_awsize;
  output M_AXI_awuser;
  output M_AXI_awvalid;
  input [5:0]M_AXI_bid;
  output M_AXI_bready;
  input [1:0]M_AXI_bresp;
  input M_AXI_buser;
  input M_AXI_bvalid;
  input [31:0]M_AXI_rdata;
  input [5:0]M_AXI_rid;
  input M_AXI_rlast;
  output M_AXI_rready;
  input [1:0]M_AXI_rresp;
  input M_AXI_ruser;
  input M_AXI_rvalid;
  output [31:0]M_AXI_wdata;
  output M_AXI_wlast;
  input M_AXI_wready;
  output [3:0]M_AXI_wstrb;
  output M_AXI_wvalid;
  input [15:0]S_AXI_BRAM_araddr;
  input [1:0]S_AXI_BRAM_arburst;
  input [3:0]S_AXI_BRAM_arcache;
  input [7:0]S_AXI_BRAM_arlen;
  input [0:0]S_AXI_BRAM_arlock;
  input [2:0]S_AXI_BRAM_arprot;
  input [3:0]S_AXI_BRAM_arqos;
  output [0:0]S_AXI_BRAM_arready;
  input [2:0]S_AXI_BRAM_arsize;
  input [0:0]S_AXI_BRAM_arvalid;
  input [15:0]S_AXI_BRAM_awaddr;
  input [1:0]S_AXI_BRAM_awburst;
  input [3:0]S_AXI_BRAM_awcache;
  input [7:0]S_AXI_BRAM_awlen;
  input [0:0]S_AXI_BRAM_awlock;
  input [2:0]S_AXI_BRAM_awprot;
  input [3:0]S_AXI_BRAM_awqos;
  output [0:0]S_AXI_BRAM_awready;
  input [2:0]S_AXI_BRAM_awsize;
  input [0:0]S_AXI_BRAM_awvalid;
  input [0:0]S_AXI_BRAM_bready;
  output [1:0]S_AXI_BRAM_bresp;
  output [0:0]S_AXI_BRAM_bvalid;
  output [31:0]S_AXI_BRAM_rdata;
  output [0:0]S_AXI_BRAM_rlast;
  input [0:0]S_AXI_BRAM_rready;
  output [1:0]S_AXI_BRAM_rresp;
  output [0:0]S_AXI_BRAM_rvalid;
  input [31:0]S_AXI_BRAM_wdata;
  input [0:0]S_AXI_BRAM_wlast;
  output [0:0]S_AXI_BRAM_wready;
  input [3:0]S_AXI_BRAM_wstrb;
  input [0:0]S_AXI_BRAM_wvalid;
  input [31:0]S_AXI_CTRL_araddr;
  input [2:0]S_AXI_CTRL_arprot;
  output S_AXI_CTRL_arready;
  input S_AXI_CTRL_arvalid;
  input [31:0]S_AXI_CTRL_awaddr;
  input [2:0]S_AXI_CTRL_awprot;
  output S_AXI_CTRL_awready;
  input S_AXI_CTRL_awvalid;
  input S_AXI_CTRL_bready;
  output [1:0]S_AXI_CTRL_bresp;
  output S_AXI_CTRL_bvalid;
  output [31:0]S_AXI_CTRL_rdata;
  input S_AXI_CTRL_rready;
  output [1:0]S_AXI_CTRL_rresp;
  output S_AXI_CTRL_rvalid;
  input [31:0]S_AXI_CTRL_wdata;
  output S_AXI_CTRL_wready;
  input [3:0]S_AXI_CTRL_wstrb;
  input S_AXI_CTRL_wvalid;
  output interrupt;

  wire ARESET_N;
  wire CLK;
  wire [31:0]M_AXI_araddr;
  wire [1:0]M_AXI_arburst;
  wire [3:0]M_AXI_arcache;
  wire [5:0]M_AXI_arid;
  wire [7:0]M_AXI_arlen;
  wire M_AXI_arlock;
  wire [2:0]M_AXI_arprot;
  wire [3:0]M_AXI_arqos;
  wire M_AXI_arready;
  wire [3:0]M_AXI_arregion;
  wire [2:0]M_AXI_arsize;
  wire M_AXI_aruser;
  wire M_AXI_arvalid;
  wire [31:0]M_AXI_awaddr;
  wire [1:0]M_AXI_awburst;
  wire [3:0]M_AXI_awcache;
  wire [5:0]M_AXI_awid;
  wire [7:0]M_AXI_awlen;
  wire M_AXI_awlock;
  wire [2:0]M_AXI_awprot;
  wire [3:0]M_AXI_awqos;
  wire M_AXI_awready;
  wire [3:0]M_AXI_awregion;
  wire [2:0]M_AXI_awsize;
  wire M_AXI_awuser;
  wire M_AXI_awvalid;
  wire [5:0]M_AXI_bid;
  wire M_AXI_bready;
  wire [1:0]M_AXI_bresp;
  wire M_AXI_buser;
  wire M_AXI_bvalid;
  wire [31:0]M_AXI_rdata;
  wire [5:0]M_AXI_rid;
  wire M_AXI_rlast;
  wire M_AXI_rready;
  wire [1:0]M_AXI_rresp;
  wire M_AXI_ruser;
  wire M_AXI_rvalid;
  wire [31:0]M_AXI_wdata;
  wire M_AXI_wlast;
  wire M_AXI_wready;
  wire [3:0]M_AXI_wstrb;
  wire M_AXI_wvalid;
  wire [15:0]S_AXI_BRAM_araddr;
  wire [1:0]S_AXI_BRAM_arburst;
  wire [3:0]S_AXI_BRAM_arcache;
  wire [7:0]S_AXI_BRAM_arlen;
  wire [0:0]S_AXI_BRAM_arlock;
  wire [2:0]S_AXI_BRAM_arprot;
  wire [3:0]S_AXI_BRAM_arqos;
  wire [0:0]S_AXI_BRAM_arready;
  wire [2:0]S_AXI_BRAM_arsize;
  wire [0:0]S_AXI_BRAM_arvalid;
  wire [15:0]S_AXI_BRAM_awaddr;
  wire [1:0]S_AXI_BRAM_awburst;
  wire [3:0]S_AXI_BRAM_awcache;
  wire [7:0]S_AXI_BRAM_awlen;
  wire [0:0]S_AXI_BRAM_awlock;
  wire [2:0]S_AXI_BRAM_awprot;
  wire [3:0]S_AXI_BRAM_awqos;
  wire [0:0]S_AXI_BRAM_awready;
  wire [2:0]S_AXI_BRAM_awsize;
  wire [0:0]S_AXI_BRAM_awvalid;
  wire [0:0]S_AXI_BRAM_bready;
  wire [1:0]S_AXI_BRAM_bresp;
  wire [0:0]S_AXI_BRAM_bvalid;
  wire [31:0]S_AXI_BRAM_rdata;
  wire [0:0]S_AXI_BRAM_rlast;
  wire [0:0]S_AXI_BRAM_rready;
  wire [1:0]S_AXI_BRAM_rresp;
  wire [0:0]S_AXI_BRAM_rvalid;
  wire [31:0]S_AXI_BRAM_wdata;
  wire [0:0]S_AXI_BRAM_wlast;
  wire [0:0]S_AXI_BRAM_wready;
  wire [3:0]S_AXI_BRAM_wstrb;
  wire [0:0]S_AXI_BRAM_wvalid;
  wire [31:0]S_AXI_CTRL_araddr;
  wire [2:0]S_AXI_CTRL_arprot;
  wire S_AXI_CTRL_arready;
  wire S_AXI_CTRL_arvalid;
  wire [31:0]S_AXI_CTRL_awaddr;
  wire [2:0]S_AXI_CTRL_awprot;
  wire S_AXI_CTRL_awready;
  wire S_AXI_CTRL_awvalid;
  wire S_AXI_CTRL_bready;
  wire [1:0]S_AXI_CTRL_bresp;
  wire S_AXI_CTRL_bvalid;
  wire [31:0]S_AXI_CTRL_rdata;
  wire S_AXI_CTRL_rready;
  wire [1:0]S_AXI_CTRL_rresp;
  wire S_AXI_CTRL_rvalid;
  wire [31:0]S_AXI_CTRL_wdata;
  wire S_AXI_CTRL_wready;
  wire [3:0]S_AXI_CTRL_wstrb;
  wire S_AXI_CTRL_wvalid;
  wire interrupt;

  orca_pe orca_pe_i
       (.ARESET_N(ARESET_N),
        .CLK(CLK),
        .M_AXI_araddr(M_AXI_araddr),
        .M_AXI_arburst(M_AXI_arburst),
        .M_AXI_arcache(M_AXI_arcache),
        .M_AXI_arid(M_AXI_arid),
        .M_AXI_arlen(M_AXI_arlen),
        .M_AXI_arlock(M_AXI_arlock),
        .M_AXI_arprot(M_AXI_arprot),
        .M_AXI_arqos(M_AXI_arqos),
        .M_AXI_arready(M_AXI_arready),
        .M_AXI_arregion(M_AXI_arregion),
        .M_AXI_arsize(M_AXI_arsize),
        .M_AXI_aruser(M_AXI_aruser),
        .M_AXI_arvalid(M_AXI_arvalid),
        .M_AXI_awaddr(M_AXI_awaddr),
        .M_AXI_awburst(M_AXI_awburst),
        .M_AXI_awcache(M_AXI_awcache),
        .M_AXI_awid(M_AXI_awid),
        .M_AXI_awlen(M_AXI_awlen),
        .M_AXI_awlock(M_AXI_awlock),
        .M_AXI_awprot(M_AXI_awprot),
        .M_AXI_awqos(M_AXI_awqos),
        .M_AXI_awready(M_AXI_awready),
        .M_AXI_awregion(M_AXI_awregion),
        .M_AXI_awsize(M_AXI_awsize),
        .M_AXI_awuser(M_AXI_awuser),
        .M_AXI_awvalid(M_AXI_awvalid),
        .M_AXI_bid(M_AXI_bid),
        .M_AXI_bready(M_AXI_bready),
        .M_AXI_bresp(M_AXI_bresp),
        .M_AXI_buser(M_AXI_buser),
        .M_AXI_bvalid(M_AXI_bvalid),
        .M_AXI_rdata(M_AXI_rdata),
        .M_AXI_rid(M_AXI_rid),
        .M_AXI_rlast(M_AXI_rlast),
        .M_AXI_rready(M_AXI_rready),
        .M_AXI_rresp(M_AXI_rresp),
        .M_AXI_ruser(M_AXI_ruser),
        .M_AXI_rvalid(M_AXI_rvalid),
        .M_AXI_wdata(M_AXI_wdata),
        .M_AXI_wlast(M_AXI_wlast),
        .M_AXI_wready(M_AXI_wready),
        .M_AXI_wstrb(M_AXI_wstrb),
        .M_AXI_wvalid(M_AXI_wvalid),
        .S_AXI_BRAM_araddr(S_AXI_BRAM_araddr),
        .S_AXI_BRAM_arburst(S_AXI_BRAM_arburst),
        .S_AXI_BRAM_arcache(S_AXI_BRAM_arcache),
        .S_AXI_BRAM_arlen(S_AXI_BRAM_arlen),
        .S_AXI_BRAM_arlock(S_AXI_BRAM_arlock),
        .S_AXI_BRAM_arprot(S_AXI_BRAM_arprot),
        .S_AXI_BRAM_arqos(S_AXI_BRAM_arqos),
        .S_AXI_BRAM_arready(S_AXI_BRAM_arready),
        .S_AXI_BRAM_arsize(S_AXI_BRAM_arsize),
        .S_AXI_BRAM_arvalid(S_AXI_BRAM_arvalid),
        .S_AXI_BRAM_awaddr(S_AXI_BRAM_awaddr),
        .S_AXI_BRAM_awburst(S_AXI_BRAM_awburst),
        .S_AXI_BRAM_awcache(S_AXI_BRAM_awcache),
        .S_AXI_BRAM_awlen(S_AXI_BRAM_awlen),
        .S_AXI_BRAM_awlock(S_AXI_BRAM_awlock),
        .S_AXI_BRAM_awprot(S_AXI_BRAM_awprot),
        .S_AXI_BRAM_awqos(S_AXI_BRAM_awqos),
        .S_AXI_BRAM_awready(S_AXI_BRAM_awready),
        .S_AXI_BRAM_awsize(S_AXI_BRAM_awsize),
        .S_AXI_BRAM_awvalid(S_AXI_BRAM_awvalid),
        .S_AXI_BRAM_bready(S_AXI_BRAM_bready),
        .S_AXI_BRAM_bresp(S_AXI_BRAM_bresp),
        .S_AXI_BRAM_bvalid(S_AXI_BRAM_bvalid),
        .S_AXI_BRAM_rdata(S_AXI_BRAM_rdata),
        .S_AXI_BRAM_rlast(S_AXI_BRAM_rlast),
        .S_AXI_BRAM_rready(S_AXI_BRAM_rready),
        .S_AXI_BRAM_rresp(S_AXI_BRAM_rresp),
        .S_AXI_BRAM_rvalid(S_AXI_BRAM_rvalid),
        .S_AXI_BRAM_wdata(S_AXI_BRAM_wdata),
        .S_AXI_BRAM_wlast(S_AXI_BRAM_wlast),
        .S_AXI_BRAM_wready(S_AXI_BRAM_wready),
        .S_AXI_BRAM_wstrb(S_AXI_BRAM_wstrb),
        .S_AXI_BRAM_wvalid(S_AXI_BRAM_wvalid),
        .S_AXI_CTRL_araddr(S_AXI_CTRL_araddr),
        .S_AXI_CTRL_arprot(S_AXI_CTRL_arprot),
        .S_AXI_CTRL_arready(S_AXI_CTRL_arready),
        .S_AXI_CTRL_arvalid(S_AXI_CTRL_arvalid),
        .S_AXI_CTRL_awaddr(S_AXI_CTRL_awaddr),
        .S_AXI_CTRL_awprot(S_AXI_CTRL_awprot),
        .S_AXI_CTRL_awready(S_AXI_CTRL_awready),
        .S_AXI_CTRL_awvalid(S_AXI_CTRL_awvalid),
        .S_AXI_CTRL_bready(S_AXI_CTRL_bready),
        .S_AXI_CTRL_bresp(S_AXI_CTRL_bresp),
        .S_AXI_CTRL_bvalid(S_AXI_CTRL_bvalid),
        .S_AXI_CTRL_rdata(S_AXI_CTRL_rdata),
        .S_AXI_CTRL_rready(S_AXI_CTRL_rready),
        .S_AXI_CTRL_rresp(S_AXI_CTRL_rresp),
        .S_AXI_CTRL_rvalid(S_AXI_CTRL_rvalid),
        .S_AXI_CTRL_wdata(S_AXI_CTRL_wdata),
        .S_AXI_CTRL_wready(S_AXI_CTRL_wready),
        .S_AXI_CTRL_wstrb(S_AXI_CTRL_wstrb),
        .S_AXI_CTRL_wvalid(S_AXI_CTRL_wvalid),
        .interrupt(interrupt));
endmodule
