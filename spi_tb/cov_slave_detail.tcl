# JasperGold COV Detailed Coverage Analysis - SPI Slave
clear -all

# Analyze RTL and property files
analyze -v2k ../spi_demo/spi_slave.v
analyze -sv property/spi_slave_prop.sv
analyze -sv property/spi_slave_bind.sv

# Initialize coverage
check_cov -init -model {statement branch expression toggle functional} -type {stimuli coi proof}

# Elaborate
elaborate -top spi_slave

# Clock and reset
clock clk
reset !rst_n

# Prove all properties
set_engine_mode {Ht Hp B}
set_max_trace_length 200
prove -all

# Run coverage measurement for each type separately
check_cov -measure -type {stimuli}
check_cov -measure -type {coi}
check_cov -measure -type {proof}

# Export detailed reports per type
check_cov -report -type {all} -report_file cov_slave_all_detail.txt -force
check_cov -report -type {reachable} -report_file cov_slave_reachable_detail.txt -force
check_cov -report -type {unreachable} -report_file cov_slave_unreachable_detail.txt -force

# Get the full status with detail flag
check_cov -detail -report_file cov_slave_full_detail.txt -force

exit -force
