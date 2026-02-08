// Bind formal property modules to RTL modules

bind spi_master spi_master_prop u_spi_master_prop (
    .clk       (clk),
    .rst_n     (rst_n),
    .start     (start),
    .tx_data   (tx_data),
    .rx_data   (rx_data),
    .done      (done),
    .cpol      (cpol),
    .cpha      (cpha),
    .clk_div   (clk_div),
    .sclk      (sclk),
    .mosi      (mosi),
    .miso      (miso),
    .cs_n      (cs_n),
    .state     (state),
    .shift_out (shift_out),
    .shift_in  (shift_in),
    .bit_cnt   (bit_cnt),
    .clk_cnt   (clk_cnt)
);

bind spi_slave spi_slave_prop u_spi_slave_prop (
    .clk       (clk),
    .rst_n     (rst_n),
    .sclk      (sclk),
    .mosi      (mosi),
    .miso      (miso),
    .cs_n      (cs_n),
    .tx_data   (tx_data),
    .rx_data   (rx_data),
    .rx_valid  (rx_valid),
    .cpol      (cpol),
    .cpha      (cpha),
    .sclk_d    (sclk_d),
    .cs_n_d    (cs_n_d),
    .shift_out (shift_out),
    .shift_in  (shift_in),
    .bit_cnt   (bit_cnt),
    .active    (active)
);
