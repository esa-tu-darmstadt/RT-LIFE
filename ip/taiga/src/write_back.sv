/*
 * Copyright © 2017-2019 Eric Matthews,  Lesley Shannon
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

module write_back(
        input logic clk,
        input logic rst,

        input logic gc_fetch_flush,
        input logic instruction_issued_with_rd,

        input unit_writeback_t unit_wb[NUM_WB_UNITS-1:0],
        register_file_writeback_interface.writeback rf_wb,
        tracking_interface.wb ti,
        output logic instruction_complete,
        output logic instruction_queue_empty,
        output instruction_id_t oldest_id,

        input instruction_id_t store_done_id,
        input logic store_complete,
        post_issue_forwarding_interface.wb store_forwarding,

        input logic store_issued_with_data,
        input logic [31:0] store_data,

        //Trace signals
        output logic tr_wb_mux_contention,
        
        //DExIE signals
        output logic [31:0] dexie_df_reg_pc,
        output logic [4:0] dexie_df_reg_rd_addr,
        output logic [31:0] dexie_df_reg_rd_val
        );
    //////////////////////////////////////

    //Inflight metadata for IDs
    (* ramstyle = "MLAB, no_rw_check" *) logic[$bits(inflight_instruction_packet)-1:0] id_metadata [MAX_INFLIGHT_COUNT-1:0];

    //aliases for write-back-interface signals
    instruction_id_t unit_instruction_id [NUM_WB_UNITS-1:0];
    logic [NUM_WB_UNITS-1:0] unit_done;
    //Force usage of f7 muxes
    (* keep = "true" *) logic [XLEN-1:0] unit_rd [2*NUM_WB_UNITS-1:0];
    logic [31:0] unit_pc [NUM_WB_UNITS-1:0]; //PC values from the writeback interfaces. Added for DExIE.
    //Per-ID muxes for commit buffer
    logic [$clog2(NUM_WB_UNITS)-1:0] id_unit_select [MAX_INFLIGHT_COUNT-1:0];
    logic [$clog2(NUM_WB_UNITS)-1:0] id_unit_select_r [MAX_INFLIGHT_COUNT-1:0];
    //Commit buffer
    logic [XLEN-1:0] results_by_id [MAX_INFLIGHT_COUNT-1:0];
    logic [XLEN-1:0] results_by_id_new [MAX_INFLIGHT_COUNT-1:0];
    logic [31:0] pc_by_id [MAX_INFLIGHT_COUNT-1:0]; //PC values for all inflight instructions. Added for DExIE.
    instruction_id_t id_retiring;
    inflight_instruction_packet retiring_instruction_packet;

    logic [MAX_INFLIGHT_COUNT-1:0] id_inuse;

    logic [MAX_INFLIGHT_COUNT-1:0] id_writeback_pending;
    logic [MAX_INFLIGHT_COUNT-1:0] id_writeback_pending_r;

    logic [MAX_INFLIGHT_COUNT-1:0] id_writing_to_buffer;

    logic [MAX_INFLIGHT_COUNT-1:0] id_retiring_one_hot;
    logic [MAX_INFLIGHT_COUNT-1:0] id_issued_one_hot;

    logic retiring_next_cycle, retiring;
    ////////////////////////////////////////////////////
    //Implementation
    //Re-assigning interface inputs to array types so that they can be dynamically indexed
    genvar i;
    generate
        for (i=0; i< NUM_WB_UNITS; i++) begin : interface_to_array_g
            assign unit_instruction_id[i] = unit_wb[i].id;
            assign unit_done[i] = unit_wb[i].done;
            assign unit_rd[i] = unit_wb[i].rd;
            assign unit_pc[i] = unit_wb[i].pc; //Added for DExIE.
        end
        for (i=NUM_WB_UNITS; i< 2*NUM_WB_UNITS; i++) begin
            assign unit_rd[i] = store_data;
        end


    endgenerate

    ////////////////////////////////////////////////////
    //ID done determination
    //For each ID, check if a unit is reporting that ID as done and OR the results together
    //Additionally, OR the result of any store operation completing
    always_comb begin
        id_writing_to_buffer = 0;
        for (int i=0; i< NUM_WB_UNITS; i++) begin
            if (unit_done[i])
                id_writing_to_buffer[unit_instruction_id[i]] |= 1;// using an if statement and assigning 1 vs simply assigning unit_done[i] halves the LUTs for Xilinx
        end
        if (store_complete)
            id_writing_to_buffer[store_done_id] |= 1;
    end

    ////////////////////////////////////////////////////
    //Unit select for writeback buffer
    //Set unit_ID for each ID as they are issued
    //If ID is not in use, use the current issue_unit_id value
    //This is used to support single cycle units, such as the ALU
    //Stores are not tracked for id_inuse as their data is placed in the buffer at issue time
    always_comb begin
        id_issued_one_hot = 0;
        id_issued_one_hot[ti.issue_id] = ti.issued & ~ti.inflight_packet.is_store;
    end

    generate for (i=0; i< MAX_INFLIGHT_COUNT; i++) begin
        always_ff @ (posedge clk) begin
            if (id_issued_one_hot[i])
                id_unit_select_r[i] <= ti.issue_unit_id;
        end
        assign id_unit_select[i] = id_inuse[i] ? id_unit_select_r[i] : ti.issue_unit_id;
    end endgenerate

    ////////////////////////////////////////////////////
    //Writeback Buffer
    //Mux outputs of units based on IDs
    //If ID is done write result to buffer
    logic [MAX_INFLIGHT_COUNT-1:0] store_mux;
    always_comb begin
        store_mux = 0;
        store_mux[ti.issue_id] = store_issued_with_data;
    end
    
    generate for (i=0; i< MAX_INFLIGHT_COUNT; i++) begin
        always_ff @ (posedge clk) begin
            if (id_writing_to_buffer[i] |store_mux[i]) begin
                pc_by_id[i] <= unit_pc[id_unit_select[i]]; //Added for DExIE.
                results_by_id[i] <= unit_rd[{store_mux[i],id_unit_select[i]}];
            end
        end
    end endgenerate

    ////////////////////////////////////////////////////
    //Unit Forwarding Support
    //Track whether an ID has written to the commit buffer
    always_ff @ (posedge clk) begin
        if (rst)
            id_inuse <= 0;
        else
            id_inuse <= (id_issued_one_hot | id_inuse) & ~id_writing_to_buffer;
    end

    //As IDs are freed for reuse in repeating order, the results will not be overwritten before the instruction
    //needing them has itself completed
    assign store_forwarding.data_valid = ~id_inuse[store_forwarding.id];
    assign store_forwarding.data = results_by_id[store_forwarding.id];

    ////////////////////////////////////////////////////
    //ID Tracking
    //Provides ordering of IDs, ID for issue and oldest ID for committing to register file
    id_tracking id_fifos (.*, .issued(ti.issued), .retired(retiring_next_cycle), .id_available(ti.id_available),
    .oldest_id(oldest_id), .next_id(ti.issue_id), .empty(instruction_queue_empty));

    ////////////////////////////////////////////////////
    //Metadata storage for IDs
    //stores destination register for each ID and whether it is a store instruction
    initial begin
        foreach(id_metadata[i])
            id_metadata[i] = '0;
    end
    //Inflight Instruction ID table
    //Stores rd_addr and whether instruction is a store
    //Workaround: Use always instead of always_ff since the Questa simulator does not like the initial block otherwise.
    always @ (posedge clk) begin
        if (ti.id_available)
            id_metadata[ti.issue_id] <= ti.inflight_packet;
    end
    assign retiring_instruction_packet = id_metadata[id_retiring];

    ////////////////////////////////////////////////////
    //Register File Interface
    //Track whether the ID has a pending write to the register file
    always_ff @ (posedge clk) begin
        if (rst)
            id_writeback_pending_r <= 0;
        else
            id_writeback_pending_r <= id_writeback_pending;
    end

    assign id_writeback_pending = id_writing_to_buffer | (id_writeback_pending_r & ~id_retiring_one_hot);

    //Is the oldest instruction ready to commit?
    assign retiring_next_cycle = id_writeback_pending[oldest_id];

    always_ff @(posedge clk) begin
        retiring <= retiring_next_cycle;
        id_retiring <= oldest_id;
    end

    always_comb begin
        id_retiring_one_hot = 0;
        id_retiring_one_hot[id_retiring] = retiring;
    end

    //Instruction completion tracking for retired instruction count
    assign instruction_complete = retiring & ~retiring_instruction_packet.is_store;

    assign rf_wb.rd_addr = retiring_instruction_packet.rd_addr;
    assign rf_wb.id = id_retiring;
    assign rf_wb.retiring = instruction_complete;
    assign rf_wb.rd_nzero = |retiring_instruction_packet.rd_addr;
    assign rf_wb.rd_data = results_by_id[id_retiring];
    
    //Assign the DExIE DF writeback signals for the retiring instruction.
    assign dexie_df_reg_pc = pc_by_id[id_retiring];
    //If no instruction is retiring, use the zero register number to mark the PC and write data signals as invalid.
    assign dexie_df_reg_rd_addr = instruction_complete ? rf_wb.rd_addr : 5'd0;
    //Use the write data from the Register File inputs.
    assign dexie_df_reg_rd_val = rf_wb.rd_data;

    //Register bypass for issue operands
    assign rf_wb.rs1_valid = id_writeback_pending_r[rf_wb.rs1_id];//includes the instruction writing to the register file
    assign rf_wb.rs2_valid = id_writeback_pending_r[rf_wb.rs2_id];
    assign rf_wb.rs1_data = results_by_id[rf_wb.rs1_id];
    assign rf_wb.rs2_data = results_by_id[rf_wb.rs2_id];
    ////////////////////////////////////////////////////
    //End of Implementation
    ////////////////////////////////////////////////////

    ////////////////////////////////////////////////////
    //Assertions

    ////////////////////////////////////////////////////
    //Trace Interface
    generate if (ENABLE_TRACE_INTERFACE) begin
        //Checks if any two pairs are set indicating mux contention
        always_comb begin
            tr_wb_mux_contention = 0;
            for (int i=0; i<MAX_INFLIGHT_COUNT-1; i++) begin
                    for (int j=i+1; j<MAX_INFLIGHT_COUNT; j++) begin
                        tr_wb_mux_contention |= (id_writeback_pending[i] & id_writeback_pending[j]);
                    end
            end
        end
    end
    endgenerate

endmodule
