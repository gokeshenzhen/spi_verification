# JasperGold FPV TCL Script for SPI Master Formal Verification

clear -all

# Analyze RTL design files
analyze -v2k ../spi_demo/spi_master.v

# Analyze property files
analyze -sv property/spi_master_prop.sv
analyze -sv property/spi_master_bind.sv

# Elaborate
elaborate -top spi_master

# Clock and reset
clock clk
reset !rst_n

# Constrain clk_div to small range for convergence
assume {clk_div <= 8'd3}

# Set engine options for better convergence
set_engine_mode {Ht Hp B}
set_max_trace_length 200

# Prove all properties
prove -all

# Report results
report -results -file fpv_master_results.txt -force
report -summary -file fpv_master_summary.txt -force
