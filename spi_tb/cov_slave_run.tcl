# JasperGold COV TCL Script for SPI Slave Coverage

clear -all

# Analyze RTL design files
analyze -v2k ../spi_demo/spi_slave.v

# Analyze property files
analyze -sv property/spi_slave_prop.sv
analyze -sv property/spi_slave_bind.sv

# Initialize coverage before elaborate
check_cov -init -model {statement branch expression toggle functional} -type {stimuli coi proof}

# Elaborate
elaborate -top spi_slave

# Clock and reset
clock clk
reset !rst_n

# Prove all properties first
set_engine_mode {Ht Hp B}
set_max_trace_length 200
prove -all

# Run coverage measurement
check_cov -measure -type {stimuli coi proof}

# Waive unreachable items due to formal environment constraints
# Category 1: Reset path - verified by FPV reset assertions (all proven)
check_cov -waivers -add -comment "Reset assignments (always@1) unreachable - formal reset - verified by FPV" -cover_item_id {11 12}
check_cov -waivers -add -comment "Reset if-branch (always@1) unreachable - formal reset - verified by FPV" -cover_item_id {15}
check_cov -waivers -add -comment "Reset assignments (always@2) unreachable - formal reset - verified by FPV" -cover_item_id {21 22 23 24 25 26 27}
check_cov -waivers -add -comment "Reset if-branch (always@2) unreachable - formal reset - verified by FPV" -cover_item_id {51}

# Category 2: Clock/reset toggle - formal infrastructure
check_cov -waivers -add -comment "Clock signal toggle unreachable - formal clock infrastructure" -cover_item_id {57 109}
check_cov -waivers -add -comment "Reset signal toggle unreachable - formal reset infrastructure" -cover_item_id {58 110}

# Category 3: Constrained signal toggle
check_cov -waivers -add -comment "cpol toggle unreachable - constrained stable by assumption" -cover_item_id {80 132}
check_cov -waivers -add -comment "cpha toggle unreachable - constrained stable by assumption" -cover_item_id {81 133}

# Category 4: Reset assertion preconditions
check_cov -waivers -add -comment "Reset assertion preconditions unreachable - formal reset mechanism" -cover_item_id {175 176 177 178 179 180 181}

# Export waivers for documentation
check_cov -waivers -export -file_name cov_slave_waivers.txt -force

# Report coverage
check_cov -report -type {all} -report_file cov_slave_results.txt -force
check_cov -report -type {reachable} -report_file cov_slave_reachable.txt -force
check_cov -report -type {unreachable} -report_file cov_slave_unreachable.txt -force
