/*
 * Copyright © 2017, 2018, 2019 Eric Matthews,  Lesley Shannon
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

module taiga (
        input logic clk,
        input logic rst,

        local_memory_interface.master instruction_bram,
        local_memory_interface.master data_bram,

        axi_interface.master m_axi,
        avalon_interface.master m_avalon,
        wishbone_interface.master m_wishbone,

        output trace_outputs_t tr,
        dexie_interface.master dexie,

        l2_requester_interface.master l2,

        input logic timer_interrupt,
        input logic interrupt
        );

    l1_arbiter_request_interface l1_request[L1_CONNECTIONS-1:0]();
    l1_arbiter_return_interface l1_response[L1_CONNECTIONS-1:0]();
    logic sc_complete;
    logic sc_success;

    branch_predictor_interface bp();
    branch_results_t br_results;
    logic branch_flush;

    ras_interface ras();

    register_file_decode_interface rf_decode();
    alu_inputs_t alu_inputs;
    load_store_inputs_t ls_inputs;
    branch_inputs_t branch_inputs;
    mul_inputs_t mul_inputs;
    div_inputs_t div_inputs;
    gc_inputs_t gc_inputs;

    unit_issue_interface unit_issue [NUM_UNITS-1:0]();

    exception_packet_t  ls_exception;
    logic ls_exception_valid;

    tracking_interface ti();
    unit_writeback_t unit_wb [NUM_WB_UNITS-1:0];
    register_file_writeback_interface rf_wb();

    mmu_interface immu();
    mmu_interface dmmu();

    tlb_interface itlb();
    tlb_interface dtlb();
    logic tlb_on;
    logic [ASIDLEN-1:0] asid;

    //Pre-Decode
    logic pre_decode_push;
    logic pre_decode_pop;
    logic [31:0] pre_decode_instruction;
    logic [31:0] pre_decode_pc;
    branch_predictor_metadata_t branch_metadata;
    logic branch_prediction_used;
    logic [BRANCH_PREDICTOR_WAYS-1:0] bp_update_way;
    logic fb_valid;
    fetch_buffer_packet_t fb;

    //Global Control
    logic gc_issue_hold;
    logic gc_issue_flush;
    logic gc_fetch_flush;
    logic gc_fetch_pc_override;
    logic gc_supress_writeback;
    instruction_id_t oldest_id;
    logic load_store_issue;
    logic [31:0] gc_fetch_pc;


    logic[31:0] csr_rd;
    instruction_id_t csr_id;
    logic csr_done;

    //Decode Unit and Fetch Unit
    logic illegal_instruction;
    logic instruction_queue_empty;

    logic instruction_issued;
    logic instruction_issued_no_rd;
    logic instruction_issued_with_rd;
    logic instruction_complete;
    logic gc_flush_required;

    //LS
    instruction_id_t store_done_id;
    logic store_complete;
    post_issue_forwarding_interface store_forwarding();

    logic store_issued_with_data;
    logic [31:0] store_data;

    //Trace Interface Signals
    logic tr_operand_stall;
    logic tr_unit_stall;
    logic tr_no_id_stall;
    logic tr_no_instruction_stall;
    logic tr_other_stall;
    logic tr_branch_operand_stall;
    logic tr_alu_operand_stall;
    logic tr_ls_operand_stall;
    logic tr_div_operand_stall;

    logic tr_instruction_issued_dec;
    logic [31:0] tr_instruction_pc_dec;
    logic [31:0] tr_instruction_data_dec;

    logic tr_branch_correct;
    logic tr_branch_misspredict;
    logic tr_return_misspredict;
    logic tr_wb_mux_contention;

    logic tr_rs1_forwarding_needed;
    logic tr_rs2_forwarding_needed;
    logic tr_rs1_and_rs2_forwarding_needed;
    
	logic dexie_cf_valid;
	logic [31:0] dexie_cf_cur_pc;
	logic [31:0] dexie_cf_cur_instruction;
	logic [31:0] dexie_cf_next_pc;
	
    logic [31:0] dexie_df_mem_pc;
    logic dexie_df_mem_load;
    logic dexie_df_mem_store;
    logic [31:0] dexie_df_mem_addr;
    logic [1:0] dexie_df_mem_len;
    logic [31:0] dexie_df_mem_storedata;
    logic dexie_df_mem_stalling;
    
    logic dexie_df_mem_stallOnStore;
    logic dexie_df_mem_continueStore;
    
    logic [31:0] dexie_df_reg_pc;
    logic [4:0] dexie_df_reg_rd_addr;
    logic [31:0] dexie_df_reg_rd_val;
        
    logic dexie_rs1_valid;
    logic dexie_rs2_valid;
    logic [31:0] dexie_rs1_data;
    logic [31:0] dexie_rs2_data;
    
    logic dexie_stall;
    ////////////////////////////////////////////////////
    //Implementation


    ////////////////////////////////////////////////////
    // Memory Interface
    generate if (ENABLE_S_MODE || USE_ICACHE || USE_DCACHE)
            l1_arbiter arb(.*);
    endgenerate

    ////////////////////////////////////////////////////
    // Fetch and Pre-Decode
    fetch fetch_block (.*, .icache_on('1), .tlb(itlb), .l1_request(l1_request[L1_ICACHE_ID]), .l1_response(l1_response[L1_ICACHE_ID]), .exception(1'b0));
    branch_predictor bp_block (.*);
    ras ras_block(.*);
    generate if (ENABLE_S_MODE) begin
            tlb_lut_ram #(ITLB_WAYS, ITLB_DEPTH) i_tlb (.*, .tlb(itlb), .mmu(immu));
            mmu i_mmu (.*,  .mmu(immu) , .l1_request(l1_request[L1_IMMU_ID]), .l1_response(l1_response[L1_IMMU_ID]), .mmu_exception());
        end
        else begin
            assign itlb.complete = 1;
            assign itlb.physical_address = itlb.virtual_address;
        end
    endgenerate
    pre_decode pre_decode_block(.*);

    ////////////////////////////////////////////////////
    //Decode/Issue
    decode decode_block (.*);
    register_file register_file_block (.*);

    ////////////////////////////////////////////////////
    //Execution Units
    branch_unit branch_unit_block (.*, .issue(unit_issue[BRANCH_UNIT_ID]));
    alu_unit alu_unit_block (.*, .issue(unit_issue[ALU_UNIT_WB_ID]), .wb(unit_wb[ALU_UNIT_WB_ID]));
    load_store_unit load_store_unit_block (.*, .dcache_on(1'b1), .clear_reservation(1'b0), .tlb(dtlb), .issue(unit_issue[LS_UNIT_WB_ID]), .wb(unit_wb[LS_UNIT_WB_ID]), .l1_request(l1_request[L1_DCACHE_ID]), .l1_response(l1_response[L1_DCACHE_ID]));
    generate if (ENABLE_S_MODE) begin
            tlb_lut_ram #(DTLB_WAYS, DTLB_DEPTH) d_tlb (.*, .tlb(dtlb), .mmu(dmmu));
            mmu d_mmu (.*, .mmu(dmmu), .l1_request(l1_request[L1_DMMU_ID]), .l1_response(l1_response[L1_DMMU_ID]), .mmu_exception());
        end
        else begin
            assign dtlb.complete = 1;
            assign dtlb.physical_address = dtlb.virtual_address;
        end
    endgenerate
    gc_unit gc_unit_block (.*, .issue(unit_issue[GC_UNIT_ID]));

    generate if (USE_MUL)
            mul_unit mul_unit_block (.*, .issue(unit_issue[MUL_UNIT_WB_ID]), .wb(unit_wb[MUL_UNIT_WB_ID]));
    endgenerate
    generate if (USE_DIV)
            div_unit div_unit_block (.*, .issue(unit_issue[DIV_UNIT_WB_ID]), .wb(unit_wb[DIV_UNIT_WB_ID]));
    endgenerate

    ////////////////////////////////////////////////////
    //Writeback Mux and Instruction Tracking
    write_back write_back_mux (.*);


    ////////////////////////////////////////////////////
    //End of Implementation
    ////////////////////////////////////////////////////

    ////////////////////////////////////////////////////
    //Assertions
    //Ensure that reset is held for at least 32 cycles to clear shift regs
    // always_ff @ (posedge clk) begin
    //     assert property(@(posedge clk) $rose (rst) |=> rst[*32]) else $error("Reset not held for long enough!");
    // end

    ////////////////////////////////////////////////////
    //Assertions

    ////////////////////////////////////////////////////
    //Trace Interface, DExIE
    generate if (ENABLE_TRACE_INTERFACE) begin
        //Assign the DExIE output signals without registers.
        //Instead, registers/FIFO are used inside DExIE where required to reduce the critical path.
        assign dexie.instruction_issued_dec = tr_instruction_issued_dec;
        assign dexie.instruction_pc_dec     = tr_instruction_pc_dec;
        assign dexie.instruction_data_dec   = tr_instruction_data_dec;
		//The CF signals from branch_unit only are valid if the instruction was issued to any unit
		// (branch_unit assumes that an instruction not issued to it is untaken, even if the operands are not ready).
        assign dexie.cf_valid               = dexie_cf_valid & instruction_issued;
        assign dexie.cf_cur_pc              = dexie_cf_cur_pc;
        assign dexie.cf_cur_instruction     = dexie_cf_cur_instruction;
        assign dexie.cf_next_pc             = dexie_cf_next_pc;
        assign dexie.df_mem_pc              = dexie_df_mem_pc;
        assign dexie.df_mem_load            = dexie_df_mem_load;
        assign dexie.df_mem_store           = dexie_df_mem_store;
        assign dexie.df_mem_addr            = dexie_df_mem_addr;
        assign dexie.df_mem_len             = dexie_df_mem_len;
        assign dexie.df_mem_storedata       = dexie_df_mem_storedata;
        assign dexie.df_mem_stalling        = dexie_df_mem_stalling;
        
        assign dexie.df_reg_pc              = dexie_df_reg_pc;
        assign dexie.df_reg_rd_addr         = dexie_df_reg_rd_addr;
        assign dexie.df_reg_rd_val          = dexie_df_reg_rd_val;
        
        assign dexie_stall                  = dexie.stall;
        assign dexie_df_mem_stallOnStore    = dexie.df_mem_stallOnStore;
        assign dexie_df_mem_continueStore   = dexie.df_mem_continueStore;

        always_ff @(posedge clk) begin
            tr.events.operand_stall <= tr_operand_stall;
            tr.events.unit_stall <= tr_unit_stall;
            tr.events.no_id_stall <= tr_no_id_stall;
            tr.events.no_instruction_stall <= tr_no_instruction_stall;
            tr.events.other_stall <= tr_other_stall;
            tr.events.instruction_issued_dec <= tr_instruction_issued_dec;
            tr.events.branch_operand_stall <= tr_branch_operand_stall;
            tr.events.alu_operand_stall <= tr_alu_operand_stall;
            tr.events.ls_operand_stall <= tr_ls_operand_stall;
            tr.events.div_operand_stall <= tr_div_operand_stall;
            tr.events.branch_correct <= tr_branch_correct;
            tr.events.branch_misspredict <= tr_branch_misspredict;
            tr.events.return_misspredict <= tr_return_misspredict;
            tr.events.wb_mux_contention <= tr_wb_mux_contention;
            tr.events.rs1_forwarding_needed <= tr_rs1_forwarding_needed;
            tr.events.rs2_forwarding_needed <= tr_rs2_forwarding_needed;
            tr.events.rs1_and_rs2_forwarding_needed <= tr_rs1_and_rs2_forwarding_needed;
            tr.instruction_pc_dec <= tr_instruction_pc_dec;
            tr.instruction_data_dec <= tr_instruction_data_dec;
        end
    end
    endgenerate

endmodule
