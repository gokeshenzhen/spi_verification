`ifndef SPI_TRANSACTION__SV
`define SPI_TRANSACTION__SV

class spi_transaction extends uvm_sequence_item;

    rand bit [7:0] data;      // data to send
    bit [7:0]      rdata;     // data received
    rand bit       cpol;
    rand bit       cpha;
    rand bit [7:0] clk_div;

    constraint default_cons {
        cpol == 0;
        cpha == 0;
        clk_div inside {[1:4]};
    }

    `uvm_object_utils_begin(spi_transaction)
        `uvm_field_int(data,    UVM_ALL_ON)
        `uvm_field_int(rdata,   UVM_ALL_ON)
        `uvm_field_int(cpol,    UVM_ALL_ON)
        `uvm_field_int(cpha,    UVM_ALL_ON)
        `uvm_field_int(clk_div, UVM_ALL_ON)
    `uvm_object_utils_end

    function new(string name = "spi_transaction");
        super.new(name);
    endfunction

endclass

`endif
