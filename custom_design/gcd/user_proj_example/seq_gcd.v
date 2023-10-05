// SPDX-FileCopyrightText: 2020 Efabless Corporation
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
// SPDX-License-Identifier: Apache-2.0

`default_nettype none
/*
 *-------------------------------------------------------------
 *
 * user_proj_example
 *
 * This is an example of a (trivially simple) user project,
 * showing how the user project can connect to the logic
 * analyzer, the wishbone bus, and the I/O pads.
 *
 * This project generates an integer count, which is output
 * on the user area GPIO pads (digital output only).  The
 * wishbone connection allows the project to be controlled
 * (start and stop) from the management SoC program.
 *
 * See the testbenches in directory "mprj_counter" for the
 * example programs that drive this user project.  The three
 * testbenches are "io_ports", "la_test1", and "la_test2".
 *
 *-------------------------------------------------------------
 */


     
module seq_gcd (
        clk,
        rst_n,        
	la_write_a,
	la_write_b,
        a_i,
        b_i,
        gcd_o,
	rdata,        
	ready
);
        input wire clk;
        input wire rst_n;        
	input wire [31:0] la_write_a;
	input wire [31:0] la_write_b;
        input wire [31:0] a_i;
        input wire [31:0] b_i;
        output reg [31:0] gcd_o;
	output reg [31:0] rdata;        
	output reg ready;
        reg [31:0] a_q;
        reg [31:0] b_q;
        wire [31:0] a_muxed;
        wire [31:0] b_muxed;
	wire la_load;
	reg done_o;
        reg CS;
        reg NS;
        reg load_int;		
        always @(posedge clk or negedge rst_n) begin : proc_seq
                if (~rst_n) begin
                        a_q <= 0;
                        b_q <= 0;
			gcd_o <= 0;
			rdata <= 0;
			ready <= 0;
                end
                else begin
                        a_q <= a_muxed;
                        b_q <= b_muxed;
			if (done_o) gcd_o <= a_q;
                end
        end
        //assign gcd_o = a_q;
	assign la_load = (&la_write_a)&(&la_write_b);
        assign a_muxed = (load_int ? a_i : b_q);
        assign b_muxed = (load_int ? b_i : a_q % b_q);		
        always @(posedge clk or negedge rst_n) begin : proc_update_state
                if (~rst_n)
                        CS <= 1'd0;
                else
                        CS <= NS;				
        end
        always @(*) begin : proc_compute_NS
                load_int = 1'b0;
                done_o = 1'b0;
                case (CS)
                        1'd0: begin
                                done_o = 1'b0;
                                load_int = la_load;
                                if (la_load)
                                        NS = 1'd1;
                                else
                                        NS = 1'd0;
                        end
                        1'd1: begin
                                load_int = 1'b0;
                                done_o = b_q == 0;
                                if (b_q == 0)
                                        NS = 1'd0;
                                else
                                        NS = 1'd1;
                        end
                endcase
        end
endmodule   
`default_nettype wire
