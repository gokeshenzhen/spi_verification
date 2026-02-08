`ifndef SPI_ENV__SV
`define SPI_ENV__SV

class spi_env extends uvm_env;
    spi_agent      agt;
    spi_scoreboard scb;

    uvm_tlm_analysis_fifo #(spi_transaction) agt_scb_fifo;

    function new(string name = "spi_env", uvm_component parent);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        agt = spi_agent::type_id::create("agt", this);
        agt.is_active = UVM_ACTIVE;
        scb = spi_scoreboard::type_id::create("scb", this);
        agt_scb_fifo = new("agt_scb_fifo", this);
    endfunction

    virtual function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        agt.ap.connect(agt_scb_fifo.analysis_export);
        scb.act_port.connect(agt_scb_fifo.blocking_get_export);
    endfunction

    `uvm_component_utils(spi_env)
endclass

`endif
