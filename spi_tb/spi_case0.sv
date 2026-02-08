`ifndef SPI_CASE0__SV
`define SPI_CASE0__SV

// Basic loopback test: send random data, slave echoes back known pattern
class spi_basic_sequence extends uvm_sequence #(spi_transaction);
    spi_transaction m_trans;

    function new(string name = "spi_basic_sequence");
        super.new(name);
    endfunction

    virtual task body();
        if (starting_phase != null)
            starting_phase.raise_objection(this);
        #200; // wait for reset
        repeat (20) begin
            `uvm_do_with(m_trans, { cpol == 0; cpha == 0; clk_div == 2; })
        end
        #1000;
        if (starting_phase != null)
            starting_phase.drop_objection(this);
    endtask

    `uvm_object_utils(spi_basic_sequence)
endclass

class spi_case0 extends spi_base_test;

    function new(string name = "spi_case0", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        uvm_config_db#(uvm_object_wrapper)::set(this,
            "env.agt.sqr.main_phase",
            "default_sequence",
            spi_basic_sequence::type_id::get());
    endfunction

    `uvm_component_utils(spi_case0)
endclass

`endif
