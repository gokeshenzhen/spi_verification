module spi_slave (
    input  wire        clk,
    input  wire        rst_n,
    input  wire        sclk,
    input  wire        mosi,
    output reg         miso,
    input  wire        cs_n,
    input  wire [7:0]  tx_data,
    output reg  [7:0]  rx_data,
    output reg         rx_valid,
    input  wire        cpol,
    input  wire        cpha
);

    // Since master generates sclk synchronous to clk,
    // we only need 1-stage delay for edge detection
    reg       sclk_d;
    reg       cs_n_d;
    wire      sclk_posedge_w, sclk_negedge_w;
    wire      cs_n_falledge;

    reg [7:0] shift_out;
    reg [7:0] shift_in;
    reg [2:0] bit_cnt;
    reg       active;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            sclk_d <= 1'b0;
            cs_n_d <= 1'b1;
        end else begin
            sclk_d <= sclk;
            cs_n_d <= cs_n;
        end
    end

    assign sclk_posedge_w = sclk & ~sclk_d;
    assign sclk_negedge_w = ~sclk & sclk_d;
    assign cs_n_falledge  = ~cs_n & cs_n_d;

    // Mode 0 (CPOL=0,CPHA=0): sample on posedge, shift on negedge
    wire sample_edge = (cpol ^ cpha) ? sclk_negedge_w : sclk_posedge_w;
    wire shift_edge  = (cpol ^ cpha) ? sclk_posedge_w : sclk_negedge_w;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            shift_out <= 8'd0;
            shift_in  <= 8'd0;
            bit_cnt   <= 3'd0;
            rx_data   <= 8'd0;
            rx_valid  <= 1'b0;
            miso      <= 1'b0;
            active    <= 1'b0;
        end else begin
            rx_valid <= 1'b0;

            if (cs_n) begin
                // CS deasserted - idle
                bit_cnt <= 3'd0;
                active  <= 1'b0;
            end else if (cs_n_falledge) begin
                // CS just asserted
                active    <= 1'b1;
                shift_out <= tx_data;
                bit_cnt   <= 3'd0;
                if (cpha == 1'b0) begin
                    miso <= tx_data[7];
                    shift_out <= {tx_data[6:0], 1'b0};
                end
            end else if (active) begin
                if (sample_edge) begin
                    shift_in <= {shift_in[6:0], mosi};
                    if (bit_cnt == 3'd7) begin
                        rx_data  <= {shift_in[6:0], mosi};
                        rx_valid <= 1'b1;
                        bit_cnt  <= 3'd0;
                    end else begin
                        bit_cnt <= bit_cnt + 1'b1;
                    end
                end
                if (shift_edge) begin
                    miso      <= shift_out[7];
                    shift_out <= {shift_out[6:0], 1'b0};
                end
            end
        end
    end
endmodule
