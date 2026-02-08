# JasperGold FPV TCL Script for SPI Slave Formal Verification

clear -all

# Analyze RTL design files
analyze -v2k ../spi_demo/spi_slave.v

# Analyze property files
analyze -sv property/spi_slave_prop.sv
analyze -sv property/spi_slave_bind.sv

# Elaborate
elaborate -top spi_slave

# Clock and reset
clock clk
reset !rst_n

# Set engine options for better convergence
set_engine_mode {Ht Hp B}
set_max_trace_length 200

# Prove all properties
prove -all

# Report results
report -results -file fpv_slave_results.txt -force
report -summary -file fpv_slave_summary.txt -force
