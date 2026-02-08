`ifndef SPI_SCOREBOARD__SV
`define SPI_SCOREBOARD__SV

class spi_scoreboard extends uvm_scoreboard;
    uvm_blocking_get_port #(spi_transaction) act_port;

    int pass_cnt;
    int fail_cnt;

    `uvm_component_utils(spi_scoreboard)

    function new(string name, uvm_component parent = null);
        super.new(name, parent);
        pass_cnt = 0;
        fail_cnt = 0;
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        act_port = new("act_port", this);
    endfunction

    task run_phase(uvm_phase phase);
        spi_transaction tr;
        while (1) begin
            act_port.get(tr);
            if (tr.rdata == 8'hA5) begin
                `uvm_info("spi_scb", $sformatf("PASS: tx=0x%02h rx=0x%02h", tr.data, tr.rdata), UVM_MEDIUM)
                pass_cnt++;
            end else begin
                `uvm_error("spi_scb", $sformatf("FAIL: tx=0x%02h rx=0x%02h (expected 0xA5)", tr.data, tr.rdata))
                fail_cnt++;
            end
        end
    endtask

    function void report_phase(uvm_phase phase);
        `uvm_info("spi_scb", $sformatf("Scoreboard: %0d passed, %0d failed", pass_cnt, fail_cnt), UVM_LOW)
    endfunction

endclass

`endif
