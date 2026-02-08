`ifndef SPI_SEQUENCER__SV
`define SPI_SEQUENCER__SV

class spi_sequencer extends uvm_sequencer #(spi_transaction);

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    `uvm_component_utils(spi_sequencer)
endclass

`endif
