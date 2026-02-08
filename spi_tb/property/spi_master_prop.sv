module spi_master_prop (
    input wire        clk,
    input wire        rst_n,
    input wire        start,
    input wire [7:0]  tx_data,
    input wire [7:0]  rx_data,
    input wire        done,
    input wire        cpol,
    input wire        cpha,
    input wire [7:0]  clk_div,
    input wire        sclk,
    input wire        mosi,
    input wire        miso,
    input wire        cs_n,
    input wire [1:0]  state,
    input wire [7:0]  shift_out,
    input wire [7:0]  shift_in,
    input wire [2:0]  bit_cnt,
    input wire [7:0]  clk_cnt
);

    localparam IDLE     = 2'd0;
    localparam LEADING  = 2'd1;
    localparam TRAILING = 2'd2;
    localparam DONE_ST  = 2'd3;

    // =============================================
    // Assumptions: cpol/cpha are config and must be stable
    // =============================================
    asm_cpol_stable : assume property (@(posedge clk) disable iff (!rst_n) $stable(cpol));
    asm_cpha_stable : assume property (@(posedge clk) disable iff (!rst_n) $stable(cpha));

    // =============================================
    // Reset Properties
    // =============================================
    property p_reset_state;
        @(posedge clk) !rst_n |-> ##1 (state == IDLE);
    endproperty

    property p_reset_cs_n;
        @(posedge clk) !rst_n |-> ##1 cs_n;
    endproperty

    property p_reset_done;
        @(posedge clk) !rst_n |-> ##1 !done;
    endproperty

    property p_reset_bit_cnt;
        @(posedge clk) !rst_n |-> ##1 (bit_cnt == 3'd0);
    endproperty

    property p_reset_clk_cnt;
        @(posedge clk) !rst_n |-> ##1 (clk_cnt == 8'd0);
    endproperty

    property p_reset_rx_data;
        @(posedge clk) !rst_n |-> ##1 (rx_data == 8'd0);
    endproperty

    // =============================================
    // FSM State Transition Properties
    // =============================================
    property p_idle_to_leading;
        @(posedge clk) disable iff (!rst_n)
        (state == IDLE) && start |-> ##1 (state == LEADING);
    endproperty

    property p_idle_stay;
        @(posedge clk) disable iff (!rst_n)
        (state == IDLE) && !start |-> ##1 (state == IDLE);
    endproperty

    property p_leading_to_trailing;
        @(posedge clk) disable iff (!rst_n)
        (state == LEADING) && (clk_cnt == clk_div) |-> ##1 (state == TRAILING);
    endproperty

    property p_leading_stay;
        @(posedge clk) disable iff (!rst_n)
        (state == LEADING) && (clk_cnt != clk_div) |-> ##1 (state == LEADING);
    endproperty

    property p_trailing_to_done;
        @(posedge clk) disable iff (!rst_n)
        (state == TRAILING) && (clk_cnt == clk_div) && (bit_cnt == 3'd0)
        |-> ##1 (state == DONE_ST);
    endproperty

    property p_trailing_to_leading;
        @(posedge clk) disable iff (!rst_n)
        (state == TRAILING) && (clk_cnt == clk_div) && (bit_cnt != 3'd0)
        |-> ##1 (state == LEADING);
    endproperty

    property p_trailing_stay;
        @(posedge clk) disable iff (!rst_n)
        (state == TRAILING) && (clk_cnt != clk_div) |-> ##1 (state == TRAILING);
    endproperty

    property p_done_to_idle;
        @(posedge clk) disable iff (!rst_n)
        (state == DONE_ST) |-> ##1 (state == IDLE);
    endproperty

    // =============================================
    // CS_N Properties
    // =============================================
    property p_cs_n_idle;
        @(posedge clk) disable iff (!rst_n)
        (state == IDLE) && !start |-> cs_n;
    endproperty

    property p_cs_n_active;
        @(posedge clk) disable iff (!rst_n)
        (state == LEADING) || (state == TRAILING) |-> !cs_n;
    endproperty

    property p_cs_n_deassert_done;
        @(posedge clk) disable iff (!rst_n)
        (state == DONE_ST) |-> ##1 cs_n;
    endproperty

    // =============================================
    // SCLK Properties
    // =============================================
    property p_sclk_idle;
        @(posedge clk) disable iff (!rst_n)
        (state == IDLE) |-> ##1 (sclk == $past(cpol));
    endproperty

    property p_sclk_leading_toggle;
        @(posedge clk) disable iff (!rst_n)
        (state == LEADING) && (clk_cnt == clk_div)
        |-> ##1 (sclk == ($past(cpol) ^ 1'b1));
    endproperty

    property p_sclk_trailing_toggle;
        @(posedge clk) disable iff (!rst_n)
        (state == TRAILING) && (clk_cnt == clk_div)
        |-> ##1 (sclk == $past(cpol));
    endproperty

    // =============================================
    // Done Signal Properties
    // =============================================
    property p_done_pulse;
        @(posedge clk) disable iff (!rst_n)
        done |-> ##1 !done;
    endproperty

    property p_done_in_done_st;
        @(posedge clk) disable iff (!rst_n)
        (state == DONE_ST) |-> ##1 done;
    endproperty

    property p_no_done_outside;
        @(posedge clk) disable iff (!rst_n)
        (state != DONE_ST) |-> ##1 !done;
    endproperty

    // =============================================
    // Bit Counter Properties
    // =============================================
    property p_bit_cnt_init;
        @(posedge clk) disable iff (!rst_n)
        (state == IDLE) && start |-> ##1 (bit_cnt == 3'd7);
    endproperty

    property p_bit_cnt_dec;
        @(posedge clk) disable iff (!rst_n)
        (state == TRAILING) && (clk_cnt == clk_div) && (bit_cnt != 3'd0)
        |-> ##1 (bit_cnt == $past(bit_cnt) - 1'b1);
    endproperty

    // =============================================
    // Clock Counter Properties
    // =============================================
    property p_clk_cnt_reset_on_match;
        @(posedge clk) disable iff (!rst_n)
        ((state == LEADING) || (state == TRAILING)) && (clk_cnt == clk_div)
        |-> ##1 (clk_cnt == 8'd0);
    endproperty

    property p_clk_cnt_inc;
        @(posedge clk) disable iff (!rst_n)
        ((state == LEADING) || (state == TRAILING)) && (clk_cnt != clk_div)
        |-> ##1 (clk_cnt == $past(clk_cnt) + 1'b1);
    endproperty

    // =============================================
    // Data Path Properties
    // =============================================
    property p_mosi_init;
        @(posedge clk) disable iff (!rst_n)
        (state == IDLE) && start |-> ##1 (mosi == $past(tx_data[7]));
    endproperty

    property p_rx_data_capture;
        @(posedge clk) disable iff (!rst_n)
        (state == TRAILING) && (clk_cnt == clk_div) && (bit_cnt == 3'd0)
        |-> ##1 (rx_data == $past(shift_in));
    endproperty

    // =============================================
    // Assertion Instantiations
    // =============================================
    // Reset
    ast_reset_state    : assert property (p_reset_state);
    ast_reset_cs_n     : assert property (p_reset_cs_n);
    ast_reset_done     : assert property (p_reset_done);
    ast_reset_bit_cnt  : assert property (p_reset_bit_cnt);
    ast_reset_clk_cnt  : assert property (p_reset_clk_cnt);
    ast_reset_rx_data  : assert property (p_reset_rx_data);

    // FSM transitions
    ast_idle_to_leading     : assert property (p_idle_to_leading);
    ast_idle_stay           : assert property (p_idle_stay);
    ast_leading_to_trailing : assert property (p_leading_to_trailing);
    ast_leading_stay        : assert property (p_leading_stay);
    ast_trailing_to_done    : assert property (p_trailing_to_done);
    ast_trailing_to_leading : assert property (p_trailing_to_leading);
    ast_trailing_stay       : assert property (p_trailing_stay);
    ast_done_to_idle        : assert property (p_done_to_idle);

    // CS_N
    ast_cs_n_idle           : assert property (p_cs_n_idle);
    ast_cs_n_active         : assert property (p_cs_n_active);
    ast_cs_n_deassert_done  : assert property (p_cs_n_deassert_done);

    // SCLK
    ast_sclk_idle           : assert property (p_sclk_idle);
    ast_sclk_leading_toggle : assert property (p_sclk_leading_toggle);
    ast_sclk_trailing_toggle: assert property (p_sclk_trailing_toggle);

    // Done
    ast_done_pulse          : assert property (p_done_pulse);
    ast_done_in_done_st     : assert property (p_done_in_done_st);
    ast_no_done_outside     : assert property (p_no_done_outside);

    // Bit counter
    ast_bit_cnt_init        : assert property (p_bit_cnt_init);
    ast_bit_cnt_dec         : assert property (p_bit_cnt_dec);

    // Clock counter
    ast_clk_cnt_reset       : assert property (p_clk_cnt_reset_on_match);
    ast_clk_cnt_inc         : assert property (p_clk_cnt_inc);

    // Data path
    ast_mosi_init           : assert property (p_mosi_init);
    ast_rx_data_capture     : assert property (p_rx_data_capture);

    // Cover properties for coverage
    cov_idle_to_leading     : cover property (p_idle_to_leading);
    cov_leading_to_trailing : cover property (p_leading_to_trailing);
    cov_trailing_to_done    : cover property (p_trailing_to_done);
    cov_trailing_to_leading : cover property (p_trailing_to_leading);
    cov_done_to_idle        : cover property (p_done_to_idle);
    cov_done_pulse          : cover property (p_done_pulse);
    cov_rx_data_capture     : cover property (p_rx_data_capture);

endmodule
