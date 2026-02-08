`ifndef SPI_DRIVER__SV
`define SPI_DRIVER__SV

class spi_driver extends uvm_driver #(spi_transaction);

    virtual spi_if vif;

    `uvm_component_utils(spi_driver)

    function new(string name = "spi_driver", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (!uvm_config_db#(virtual spi_if)::get(this, "", "vif", vif))
            `uvm_fatal("spi_driver", "virtual interface must be set for vif!!!")
    endfunction

    extern task run_phase(uvm_phase phase);
    extern task drive_one_pkt(spi_transaction tr);
endclass

task spi_driver::run_phase(uvm_phase phase);
    vif.start   <= 1'b0;
    vif.tx_data <= 8'h0;
    vif.cpol    <= 1'b0;
    vif.cpha    <= 1'b0;
    vif.clk_div <= 8'd1;
    while (!vif.rst_n)
        @(posedge vif.clk);
    while (1) begin
        seq_item_port.get_next_item(req);
        drive_one_pkt(req);
        seq_item_port.item_done();
    end
endtask

task spi_driver::drive_one_pkt(spi_transaction tr);
    `uvm_info("spi_driver", $sformatf("Driving SPI tx=0x%02h cpol=%0b cpha=%0b div=%0d",
              tr.data, tr.cpol, tr.cpha, tr.clk_div), UVM_MEDIUM)

    @(posedge vif.clk);
    vif.cpol    <= tr.cpol;
    vif.cpha    <= tr.cpha;
    vif.clk_div <= tr.clk_div;
    vif.tx_data <= tr.data;

    @(posedge vif.clk);
    vif.start <= 1'b1;
    @(posedge vif.clk);
    vif.start <= 1'b0;

    // Wait for master done
    @(posedge vif.done);
    @(posedge vif.clk);

    tr.rdata = vif.rx_data;
    `uvm_info("spi_driver", $sformatf("SPI done. master_rx=0x%02h", tr.rdata), UVM_MEDIUM)
endtask

`endif
