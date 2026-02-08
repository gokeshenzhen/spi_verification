### verification Tu ####
### verification Tu ####
UVM_HOME = /tools/synopsys/vcs_2016.06/etc/uvm
VCS = vcs
JASPER = jg

VFLAGS = +define+VCS \
         -timescale=1ns/1ns \
         -full64 -sverilog +v2k \
         -lca \
         -debug -debug_pp -debug_access+all \
         +incdir+$(UVM_HOME)/src \
         $(UVM_HOME)/src/uvm.sv \
         $(UVM_HOME)/src/dpi/uvm_dpi.cc \
         -CFLAGS -DVCS

DFILES = ../spi_demo/spi_master.v \
         ../spi_demo/spi_slave.v

TBFILES = spi_top_tb.sv

.PHONY: comp run clean all fpv fpv_master fpv_slave cov cov_master cov_slave formal_clean

all: comp run

comp:
	$(VCS) $(VFLAGS) $(DFILES) $(TBFILES) \
	    -o simv -l comp.log

run:
	./simv +UVM_TESTNAME=spi_case0 +UVM_VERBOSITY=UVM_MEDIUM -l run.log

wave:
	verdi $(DEFINES) +v2k -sverilog +incdir+$(UVM_HOME)/src $(UVM_HOME)/src/uvm.sv $(UVM_HOME)/src/dpi/uvm_dpi.cc \
	-f filelist.f -ntb_opts uvm +systemverilogext+sv +verilog2001ext+sv +verilog2001ext+v -syntaxerrormax 1000000 &

fpv: fpv_master fpv_slave

fpv_master:
	$(JASPER) -batch fpv_run.tcl | tee fpv_master_run.log

fpv_slave:
	$(JASPER) -batch fpv_slave_run.tcl | tee fpv_slave_run.log

cov: cov_master cov_slave

cov_master:
	$(JASPER) -cov cov_run.tcl | tee cov_master_run.log

cov_slave:
	$(JASPER) -batch cov_slave_run.tcl | tee cov_slave_run.log

clean:
	rm -rf simv simv.daidir csrc *.log *.fsdb *.vpd ucli.key vc_hdrs.h DVEfiles novas.* verdiLog

formal_clean:
	rm -rf jgproject *.log fpv_*_results.txt fpv_*_summary.txt cov_*_results.txt cov_*_detail.txt
