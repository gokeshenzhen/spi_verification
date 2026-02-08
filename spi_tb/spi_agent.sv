`ifndef SPI_AGENT__SV
`define SPI_AGENT__SV

class spi_agent extends uvm_agent;
    spi_sequencer sqr;
    spi_driver    drv;
    spi_monitor   mon;

    uvm_analysis_port #(spi_transaction) ap;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    extern virtual function void build_phase(uvm_phase phase);
    extern virtual function void connect_phase(uvm_phase phase);

    `uvm_component_utils(spi_agent)
endclass

function void spi_agent::build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (is_active == UVM_ACTIVE) begin
        sqr = spi_sequencer::type_id::create("sqr", this);
        drv = spi_driver::type_id::create("drv", this);
    end
    mon = spi_monitor::type_id::create("mon", this);
endfunction

function void spi_agent::connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    if (is_active == UVM_ACTIVE) begin
        drv.seq_item_port.connect(sqr.seq_item_export);
    end
    ap = mon.ap;
endfunction

`endif
