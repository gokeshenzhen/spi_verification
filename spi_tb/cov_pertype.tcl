# Per-type coverage measurement for SPI Master
clear -all

analyze -v2k ../spi_demo/spi_master.v
analyze -sv property/spi_master_prop.sv
analyze -sv property/spi_master_bind.sv

check_cov -init -model {statement branch expression toggle functional} -type {stimuli coi proof}
elaborate -top spi_master
clock clk
reset !rst_n
assume {clk_div <= 8'd3}

set_engine_mode {Ht Hp B}
set_max_trace_length 200
prove -all

# Measure stimuli only
puts "========== STIMULI MEASURE =========="
check_cov -measure -type {stimuli}
puts "========== STIMULI REPORT ALL =========="
check_cov -report -type {all} -report_file cov_master_stimuli_all.txt -force
puts "========== STIMULI REPORT REACHABLE =========="
check_cov -report -type {reachable} -report_file cov_master_stimuli_reachable.txt -force
puts "========== STIMULI REPORT UNREACHABLE =========="
check_cov -report -type {unreachable} -report_file cov_master_stimuli_unreachable.txt -force

# Now measure coi (cumulative)
puts "========== COI MEASURE =========="
check_cov -measure -type {coi}
puts "========== STIMULI+COI REPORT REACHABLE =========="
check_cov -report -type {reachable} -report_file cov_master_stimuli_coi_reachable.txt -force
puts "========== STIMULI+COI REPORT UNREACHABLE =========="
check_cov -report -type {unreachable} -report_file cov_master_stimuli_coi_unreachable.txt -force

# Now measure proof (cumulative)
puts "========== PROOF MEASURE =========="
check_cov -measure -type {proof}
puts "========== ALL THREE REPORT REACHABLE =========="
check_cov -report -type {reachable} -report_file cov_master_all_reachable.txt -force
puts "========== ALL THREE REPORT UNREACHABLE =========="
check_cov -report -type {unreachable} -report_file cov_master_all_unreachable.txt -force

# Try status
puts "========== STATUS =========="
check_cov -status

exit -force
