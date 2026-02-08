`ifndef SPI_BASE_TEST__SV
`define SPI_BASE_TEST__SV

class spi_base_test extends uvm_test;
    spi_env env;

    function new(string name = "spi_base_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        env = spi_env::type_id::create("env", this);
    endfunction

    function void report_phase(uvm_phase phase);
        uvm_report_server server;
        int err_num;
        super.report_phase(phase);
        server = get_report_server();
        err_num = server.get_severity_count(UVM_ERROR);
        if (err_num != 0)
            $display("TEST CASE FAILED");
        else
            $display("TEST CASE PASSED");
    endfunction

    `uvm_component_utils(spi_base_test)
endclass

`endif
