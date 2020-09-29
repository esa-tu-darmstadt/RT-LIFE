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

module mul_unit(
        input logic clk,
        input logic rst,

        input mul_inputs_t mul_inputs,
        unit_issue_interface.unit issue,
        output unit_writeback_t wb
        );

    logic signed [65:0] result;
    logic [1:0] mulh;
    logic [1:0] done;
    instruction_id_t id [1:0];

    logic rs1_signed, rs2_signed;
    logic signed [32:0] rs1_ext, rs2_ext;
    logic [31:0] pc_ext; //PC signal input added for DExIE dataflow writeback.
    logic signed [32:0] rs1_r, rs2_r;
    logic [31:0] pc_r; //PC signal output register added for DExIE dataflow writeback.
    ////////////////////////////////////////////////////
    //Implementation

    assign rs1_signed = mul_inputs.op[1:0] inside {MULH_fn3[1:0], MULHSU_fn3[1:0]};//MUL doesn't matter
    assign rs2_signed = mul_inputs.op[1:0] inside {MUL_fn3[1:0], MULH_fn3[1:0]};//MUL doesn't matter

    assign rs1_ext = signed'({mul_inputs.rs1[31] & rs1_signed, mul_inputs.rs1});
    assign rs2_ext = signed'({mul_inputs.rs2[31] & rs2_signed, mul_inputs.rs2});
    assign pc_ext = mul_inputs.pc;

    //Input and output registered Multiply
    always_ff @ (posedge clk) begin
        rs1_r <= rs1_ext;
        rs2_r <= rs2_ext;
        pc_r <= pc_ext;
        result <= rs1_r * rs2_r;
    end

    always_ff @ (posedge clk) begin
        mulh[0] <= (mul_inputs.op[1:0] != MUL_fn3[1:0]);
        mulh[1] <= mulh[0];

        id[0] <= issue.instruction_id;
        id[1] <= id[0];

        done[0] <= issue.new_request;
        done[1] <= done[0];
    end

    //Issue/write-back handshaking
    ////////////////////////////////////////////////////
    assign issue.ready = 1;
    assign wb.rd = mulh[1] ? result[63:32] : result[31:0];
    assign wb.done = done[1];
    assign wb.id = id[1];
    assign wb.pc = pc_r; //PC signal added for DExIE dataflow writeback.
    ////////////////////////////////////////////////////
    //End of Implementation
    ////////////////////////////////////////////////////

    ////////////////////////////////////////////////////
    //Assertions

endmodule
