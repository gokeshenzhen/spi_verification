`ifndef SPI_MONITOR__SV
`define SPI_MONITOR__SV

class spi_monitor extends uvm_monitor;

    virtual spi_if vif;
    uvm_analysis_port #(spi_transaction) ap;

    `uvm_component_utils(spi_monitor)

    function new(string name = "spi_monitor", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (!uvm_config_db#(virtual spi_if)::get(this, "", "vif", vif))
            `uvm_fatal("spi_monitor", "virtual interface must be set for vif!!!")
        ap = new("ap", this);
    endfunction

    extern task run_phase(uvm_phase phase);
endclass

task spi_monitor::run_phase(uvm_phase phase);
    spi_transaction tr;
    while (1) begin
        // Wait for a transaction to complete (done pulse)
        @(posedge vif.done);
        tr = spi_transaction::type_id::create("tr");
        tr.data  = vif.tx_data;
        tr.rdata = vif.rx_data;
        tr.cpol  = vif.cpol;
        tr.cpha  = vif.cpha;
        `uvm_info("spi_monitor", $sformatf("Collected: tx=0x%02h rx=0x%02h", tr.data, tr.rdata), UVM_MEDIUM)
        ap.write(tr);
    end
endtask

`endif
