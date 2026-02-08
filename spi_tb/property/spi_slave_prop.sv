module spi_slave_prop (
    input wire        clk,
    input wire        rst_n,
    input wire        sclk,
    input wire        mosi,
    input wire        miso,
    input wire        cs_n,
    input wire [7:0]  tx_data,
    input wire [7:0]  rx_data,
    input wire        rx_valid,
    input wire        cpol,
    input wire        cpha,
    input wire        sclk_d,
    input wire        cs_n_d,
    input wire [7:0]  shift_out,
    input wire [7:0]  shift_in,
    input wire [2:0]  bit_cnt,
    input wire        active
);

    // Assumptions: cpol/cpha are config and must be stable
    asm_cpol_stable : assume property (@(posedge clk) disable iff (!rst_n) $stable(cpol));
    asm_cpha_stable : assume property (@(posedge clk) disable iff (!rst_n) $stable(cpha));

    wire sclk_posedge_w = sclk & ~sclk_d;
    wire sclk_negedge_w = ~sclk & sclk_d;
    wire cs_n_falledge  = ~cs_n & cs_n_d;
    wire sample_edge = (cpol ^ cpha) ? sclk_negedge_w : sclk_posedge_w;
    wire shift_edge  = (cpol ^ cpha) ? sclk_posedge_w : sclk_negedge_w;

    // =============================================
    // Reset Properties
    // =============================================
    property p_reset_rx_data;
        @(posedge clk) !rst_n |-> ##1 (rx_data == 8'd0);
    endproperty

    property p_reset_rx_valid;
        @(posedge clk) !rst_n |-> ##1 !rx_valid;
    endproperty

    property p_reset_miso;
        @(posedge clk) !rst_n |-> ##1 !miso;
    endproperty

    property p_reset_active;
        @(posedge clk) !rst_n |-> ##1 !active;
    endproperty

    property p_reset_bit_cnt;
        @(posedge clk) !rst_n |-> ##1 (bit_cnt == 3'd0);
    endproperty

    property p_reset_shift_in;
        @(posedge clk) !rst_n |-> ##1 (shift_in == 8'd0);
    endproperty

    property p_reset_shift_out;
        @(posedge clk) !rst_n |-> ##1 (shift_out == 8'd0);
    endproperty

    // =============================================
    // CS_N / Active Properties
    // =============================================
    property p_cs_deassert_inactive;
        @(posedge clk) disable iff (!rst_n)
        cs_n |-> ##1 !active;
    endproperty

    property p_cs_deassert_bit_cnt_reset;
        @(posedge clk) disable iff (!rst_n)
        cs_n |-> ##1 (bit_cnt == 3'd0);
    endproperty

    property p_cs_fall_activates;
        @(posedge clk) disable iff (!rst_n)
        cs_n_falledge |-> ##1 active;
    endproperty

    // =============================================
    // rx_valid Properties
    // =============================================
    property p_rx_valid_pulse;
        @(posedge clk) disable iff (!rst_n)
        rx_valid |-> ##1 !rx_valid;
    endproperty

    property p_rx_valid_on_8bits;
        @(posedge clk) disable iff (!rst_n)
        !cs_n && active && sample_edge && (bit_cnt == 3'd7)
        |-> ##1 rx_valid;
    endproperty

    property p_rx_data_on_valid;
        @(posedge clk) disable iff (!rst_n)
        !cs_n && active && sample_edge && (bit_cnt == 3'd7)
        |-> ##1 (rx_data == {$past(shift_in[6:0]), $past(mosi)});
    endproperty

    // =============================================
    // Bit Counter Properties
    // =============================================
    property p_bit_cnt_inc;
        @(posedge clk) disable iff (!rst_n)
        !cs_n && active && sample_edge && (bit_cnt != 3'd7)
        |-> ##1 (bit_cnt == $past(bit_cnt) + 1'b1);
    endproperty

    property p_bit_cnt_wrap;
        @(posedge clk) disable iff (!rst_n)
        !cs_n && active && sample_edge && (bit_cnt == 3'd7)
        |-> ##1 (bit_cnt == 3'd0);
    endproperty

    // =============================================
    // Shift Register Properties
    // =============================================
    property p_shift_in_sample;
        @(posedge clk) disable iff (!rst_n)
        !cs_n && active && sample_edge
        |-> ##1 (shift_in == {$past(shift_in[6:0]), $past(mosi)});
    endproperty

    property p_miso_on_shift_edge;
        @(posedge clk) disable iff (!rst_n)
        !cs_n && active && shift_edge
        |-> ##1 (miso == $past(shift_out[7]));
    endproperty

    // =============================================
    // Edge Detection Properties
    // =============================================
    property p_sclk_d_follows;
        @(posedge clk) disable iff (!rst_n)
        1'b1 |-> ##1 (sclk_d == $past(sclk));
    endproperty

    property p_cs_n_d_follows;
        @(posedge clk) disable iff (!rst_n)
        1'b1 |-> ##1 (cs_n_d == $past(cs_n));
    endproperty

    // =============================================
    // CPHA=0 First Bit Properties
    // =============================================
    property p_cpha0_first_miso;
        @(posedge clk) disable iff (!rst_n)
        cs_n_falledge && (cpha == 1'b0)
        |-> ##1 (miso == $past(tx_data[7]));
    endproperty

    // =============================================
    // Assertion Instantiations
    // =============================================
    // Reset
    ast_reset_rx_data   : assert property (p_reset_rx_data);
    ast_reset_rx_valid  : assert property (p_reset_rx_valid);
    ast_reset_miso      : assert property (p_reset_miso);
    ast_reset_active    : assert property (p_reset_active);
    ast_reset_bit_cnt   : assert property (p_reset_bit_cnt);
    ast_reset_shift_in  : assert property (p_reset_shift_in);
    ast_reset_shift_out : assert property (p_reset_shift_out);

    // CS_N / Active
    ast_cs_deassert_inactive    : assert property (p_cs_deassert_inactive);
    ast_cs_deassert_bit_cnt     : assert property (p_cs_deassert_bit_cnt_reset);
    ast_cs_fall_activates       : assert property (p_cs_fall_activates);

    // rx_valid
    ast_rx_valid_pulse          : assert property (p_rx_valid_pulse);
    ast_rx_valid_on_8bits       : assert property (p_rx_valid_on_8bits);
    ast_rx_data_on_valid        : assert property (p_rx_data_on_valid);

    // Bit counter
    ast_bit_cnt_inc             : assert property (p_bit_cnt_inc);
    ast_bit_cnt_wrap            : assert property (p_bit_cnt_wrap);

    // Shift register
    ast_shift_in_sample         : assert property (p_shift_in_sample);
    ast_miso_on_shift_edge      : assert property (p_miso_on_shift_edge);

    // Edge detection
    ast_sclk_d_follows          : assert property (p_sclk_d_follows);
    ast_cs_n_d_follows          : assert property (p_cs_n_d_follows);

    // CPHA=0
    ast_cpha0_first_miso        : assert property (p_cpha0_first_miso);

    // Cover properties
    cov_cs_fall_activates       : cover property (p_cs_fall_activates);
    cov_rx_valid_on_8bits       : cover property (p_rx_valid_on_8bits);
    cov_shift_in_sample         : cover property (p_shift_in_sample);
    cov_miso_on_shift_edge      : cover property (p_miso_on_shift_edge);
    cov_cpha0_first_miso        : cover property (p_cpha0_first_miso);
    cov_bit_cnt_wrap            : cover property (p_bit_cnt_wrap);

endmodule
