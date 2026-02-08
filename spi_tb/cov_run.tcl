# JasperGold COV TCL Script for SPI Master Coverage

clear -all

# Analyze RTL design files
analyze -v2k ../spi_demo/spi_master.v

# Analyze property files
analyze -sv property/spi_master_prop.sv
analyze -sv property/spi_master_bind.sv

# Initialize coverage before elaborate
check_cov -init -model {statement branch expression toggle functional} -type {stimuli coi proof}

# Elaborate
elaborate -top spi_master

# Clock and reset
clock clk
reset !rst_n

# Constrain clk_div
assume {clk_div <= 8'd3}

# Prove all properties first
set_engine_mode {Ht Hp B}
set_max_trace_length 200
prove -all

# Run coverage measurement
check_cov -measure -type {stimuli coi proof}

# Waive unreachable items due to formal environment constraints
# Category 1: Reset path - verified by FPV reset assertions (all proven)
check_cov -waivers -add -comment "Reset if-branch unreachable after formal reset release - verified by FPV" -cover_item_id {6}
check_cov -waivers -add -comment "Reset assignments unreachable after formal reset release - verified by FPV" -cover_item_id {8 9 10 11 12 13 14 15 16 17}

# Category 2: Clock/reset toggle - formal infrastructure
check_cov -waivers -add -comment "Clock signal toggle unreachable - formal clock infrastructure" -cover_item_id {53 116}
check_cov -waivers -add -comment "Reset signal toggle unreachable - formal reset infrastructure" -cover_item_id {54 117}

# Category 3: Constrained signal toggle
check_cov -waivers -add -comment "cpol toggle unreachable - constrained stable by assumption" -cover_item_id {73 136}
check_cov -waivers -add -comment "cpha toggle unreachable - constrained stable by assumption" -cover_item_id {74 137}
check_cov -waivers -add -comment "clk_div upper bits toggle unreachable - constrained to <=3 by assumption" -cover_item_id {75 76 77 78 79 80 138 139 140 141 142 143}

# Category 4: Reset assertion preconditions
check_cov -waivers -add -comment "Reset assertion preconditions unreachable - formal reset mechanism" -cover_item_id {197 198 199 200 201 202}

# Export waivers for documentation
check_cov -waivers -export -file_name cov_master_waivers.txt -force

# Report coverage
check_cov -report -type {all} -report_file cov_master_results.txt -force
check_cov -report -type {reachable} -report_file cov_master_reachable.txt -force
check_cov -report -type {unreachable} -report_file cov_master_unreachable.txt -force
