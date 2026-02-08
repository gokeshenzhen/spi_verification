`ifndef SPI_IF__SV
`define SPI_IF__SV

interface spi_if(input clk, input rst_n);
    // Master control signals
    logic       start;
    logic [7:0] tx_data;
    logic [7:0] rx_data;
    logic       done;
    logic       cpol;
    logic       cpha;
    logic [7:0] clk_div;
    // SPI bus signals
    logic       sclk;
    logic       mosi;
    logic       miso;
    logic       cs_n;
    // Slave side
    logic [7:0] slave_tx_data;
    logic [7:0] slave_rx_data;
    logic       slave_rx_valid;
endinterface

`endif
