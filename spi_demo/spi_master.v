module spi_master (
    input  wire        clk,
    input  wire        rst_n,
    input  wire        start,
    input  wire [7:0]  tx_data,
    output reg  [7:0]  rx_data,
    output reg         done,
    input  wire        cpol,
    input  wire        cpha,
    input  wire [7:0]  clk_div,
    output reg         sclk,
    output reg         mosi,
    input  wire        miso,
    output reg         cs_n
);

    localparam IDLE    = 2'd0;
    localparam LEADING = 2'd1;
    localparam TRAILING= 2'd2;
    localparam DONE_ST = 2'd3;

    reg [1:0]  state;
    reg [7:0]  shift_out;
    reg [7:0]  shift_in;
    reg [2:0]  bit_cnt;
    reg [7:0]  clk_cnt;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state     <= IDLE;
            sclk      <= 1'b0;
            mosi      <= 1'b0;
            cs_n      <= 1'b1;
            done      <= 1'b0;
            rx_data   <= 8'd0;
            shift_out <= 8'd0;
            shift_in  <= 8'd0;
            bit_cnt   <= 3'd0;
            clk_cnt   <= 8'd0;
        end else begin
            done <= 1'b0;
            case (state)
                IDLE: begin
                    sclk <= cpol;
                    cs_n <= 1'b1;
                    if (start) begin
                        shift_out <= tx_data;
                        shift_in  <= 8'd0;
                        bit_cnt   <= 3'd7;
                        clk_cnt   <= 8'd0;
                        cs_n      <= 1'b0;
                        state     <= LEADING;
                        mosi      <= tx_data[7];
                    end
                end
                LEADING: begin
                    if (clk_cnt == clk_div) begin
                        clk_cnt <= 8'd0;
                        sclk <= cpol ^ 1'b1; // rising edge for mode 0
                        // Sample MISO on leading (rising) edge
                        shift_in <= {shift_in[6:0], miso};
                        state <= TRAILING;
                    end else begin
                        clk_cnt <= clk_cnt + 1'b1;
                    end
                end
                TRAILING: begin
                    if (clk_cnt == clk_div) begin
                        clk_cnt <= 8'd0;
                        sclk <= cpol; // falling edge for mode 0
                        shift_out <= {shift_out[6:0], 1'b0};
                        if (bit_cnt == 3'd0) begin
                            // All 8 bits sampled in shift_in
                            rx_data <= shift_in;
                            state   <= DONE_ST;
                        end else begin
                            mosi    <= shift_out[6];
                            bit_cnt <= bit_cnt - 1'b1;
                            state   <= LEADING;
                        end
                    end else begin
                        clk_cnt <= clk_cnt + 1'b1;
                    end
                end
                DONE_ST: begin
                    cs_n  <= 1'b1;
                    done  <= 1'b1;
                    sclk  <= cpol;
                    state <= IDLE;
                end
            endcase
        end
    end
endmodule
