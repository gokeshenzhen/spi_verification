// Bind formal property module to SPI Slave RTL

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
