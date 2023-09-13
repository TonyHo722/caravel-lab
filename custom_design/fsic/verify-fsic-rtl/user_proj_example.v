
module user_proj_example #(
    parameter BITS = 32
)(
`ifdef USE_POWER_PINS
  input  wire           vccd1,
  input  wire           vccd2,
  input  wire           vssd1,
  input  wire           vssd2,
`endif

    // Wishbone Slave ports (WB MI A)
    input wb_clk_i,
    input wb_rst_i,
    input wbs_stb_i,
    input wbs_cyc_i,
    input wbs_we_i,
    input [3:0] wbs_sel_i,
    input [31:0] wbs_dat_i,
    input [31:0] wbs_adr_i,
    output wbs_ack_o,
    output [31:0] wbs_dat_o,

    // Logic Analyzer Signals
    input  [127:0] la_data_in,
    output [127:0] la_data_out,
    input  [127:0] la_oenb,

    // IOs
    input  [`MPRJ_IO_PADS-1:0] io_in,
    output [`MPRJ_IO_PADS-1:0] io_out,
    output [`MPRJ_IO_PADS-1:0] io_oeb,

	input user_clock2,

    // IRQ
    output [2:0] user_irq
);


FSIC #(.BITS( BITS )) u_fsic  (

                      `ifdef USE_POWER_PINS
                      .vccd1       (vccd1),                   // I
                      .vccd2       (vccd2),                   // I
                      .vssd1       (vssd1),                   // I
                      .vssd2       (vssd2),                   // I
                      `endif // USE_POWER_PINS

                      // MGMT SoC Wishbone Slave
                      .wb_rst      (wb_rst_i),                // I
                      .wb_clk      (wb_clk_i),                // I

                      .wbs_adr     (wbs_adr_i),               // I  32
                      .wbs_wdata   (wbs_dat_i),               // I  32
                      .wbs_sel     (wbs_sel_i),               // I  4
                      .wbs_cyc     (wbs_cyc_i),               // I
                      .wbs_stb     (wbs_stb_i),               // I
                      .wbs_we      (wbs_we_i),                // I

                      .wbs_ack     (wbs_ack_o),               // O
                      .wbs_rdata   (wbs_dat_o),               // O  32

                      // Logic Analyzer
                      .la_data_in  (la_data_in),              // I  128
                      .la_oenb     (la_oenb),                 // I  128
                      .la_data_out (la_data_out),             // O  128

                      // IO Pads
                      .io_in       (io_in),                   // I  38
                      .io_out      (io_out),                  // O  38
                      .io_oeb      (io_oeb),                  // O  38

                      // IRQ
                      .user_irq    (user_irq),                // O  3

                      // MISC (Independent clock, on independent integer divider)
                      .user_clock2 (user_clock2)              // I
                     );

endmodule
