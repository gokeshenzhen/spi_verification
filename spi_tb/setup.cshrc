#!/bin/csh
setenv ROOT `pwd`
setenv TB_DIR $ROOT/..
setenv DUT_SRC_DIR $TB_DIR/des_latest/des/trunk/rtl/verilog

#UVM
setenv UVM_HOME /tools/synopsys/vcs_2016.06/etc/uvm
#setenv UVM_HOME /tools/cadence/XCELIUM1710/tools/methodology/UVM/CDNS-1.1d/sv
source tools_setup.cshrc
