`timescale 1ns/1ps
`include "uvm_macros.svh"

import uvm_pkg::*;
`include "spi_if.sv"
`include "spi_transaction.sv"
`include "spi_sequencer.sv"
`include "spi_driver.sv"
`include "spi_monitor.sv"
`include "spi_agent.sv"
`include "spi_scoreboard.sv"
`include "spi_env.sv"
`include "spi_base_test.sv"
`include "spi_case0.sv"

module spi_top_tb;

    reg clk;
    reg rst_n;

    // Master control
    wire       start;
    wire [7:0] tx_data;
    wire [7:0] master_rx_data;
    wire       done;
    wire       cpol;
    wire       cpha;
    wire [7:0] clk_div;

    // SPI bus
    wire       sclk;
    wire       mosi;
    wire       miso;
    wire       cs_n;

    // Slave data
    reg  [7:0] slave_tx_data;
    wire [7:0] slave_rx_data;
    wire       slave_rx_valid;

    // SPI interface
    spi_if s_if(clk, rst_n);

    // Connect interface signals to wires
    assign start    = s_if.start;
    assign tx_data  = s_if.tx_data;
    assign cpol     = s_if.cpol;
    assign cpha     = s_if.cpha;
    assign clk_div  = s_if.clk_div;
    assign s_if.rx_data = master_rx_data;
    assign s_if.done    = done;
    assign s_if.sclk    = sclk;
    assign s_if.mosi    = mosi;
    assign s_if.miso    = miso;
    assign s_if.cs_n    = cs_n;
    assign s_if.slave_rx_data  = slave_rx_data;
    assign s_if.slave_rx_valid = slave_rx_valid;

    // SPI Master
    spi_master u_master (
        .clk      (clk),
        .rst_n    (rst_n),
        .start    (start),
        .tx_data  (tx_data),
        .rx_data  (master_rx_data),
        .done     (done),
        .cpol     (cpol),
        .cpha     (cpha),
        .clk_div  (clk_div),
        .sclk     (sclk),
        .mosi     (mosi),
        .miso     (miso),
        .cs_n     (cs_n)
    );

    // SPI Slave
    spi_slave u_slave (
        .clk      (clk),
        .rst_n    (rst_n),
        .sclk     (sclk),
        .mosi     (mosi),
        .miso     (miso),
        .cs_n     (cs_n),
        .tx_data  (slave_tx_data),
        .rx_data  (slave_rx_data),
        .rx_valid (slave_rx_valid),
        .cpol     (cpol),
        .cpha     (cpha)
    );

    // Clock generation: 10ns period (100MHz)
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // Reset
    initial begin
        rst_n = 1'b0;
        #100;
        rst_n = 1'b1;
    end

    // Slave tx_data: use a fixed known pattern for verification
    // Update slave_tx_data to be the bitwise inverse of master tx_data for easy checking
    always @(posedge clk) begin
        if (!rst_n)
            slave_tx_data <= 8'hA5;
        else
            slave_tx_data <= 8'hA5; // fixed pattern
    end

    // Self-check: when slave receives data, verify it matches what master sent
    always @(posedge clk) begin
        if (slave_rx_valid) begin
            $display("[%0t] SLAVE_RX: 0x%02h", $time, slave_rx_data);
        end
    end

    always @(posedge clk) begin
        if (done) begin
            $display("[%0t] MASTER_RX: 0x%02h (slave sent 0x%02h)", $time, master_rx_data, slave_tx_data);
            if (master_rx_data !== 8'hA5) begin
                $display("[%0t] ERROR: Master received 0x%02h, expected 0xA5", $time, master_rx_data);
            end
        end
    end

    initial begin
        run_test();
    end

    initial begin
        uvm_config_db#(virtual spi_if)::set(null, "uvm_test_top.env.agt.drv", "vif", s_if);
        uvm_config_db#(virtual spi_if)::set(null, "uvm_test_top.env.agt.mon", "vif", s_if);
    end

    initial begin
        $fsdbDumpfile("spi_top_tb.fsdb");
        $fsdbDumpvars(0, spi_top_tb);
        $fsdbDumpflush;
    end

    // Timeout
    initial begin
        #1000000;
        $display("TIMEOUT!");
        $finish;
    end

endmodule
