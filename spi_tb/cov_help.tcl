# Get check_cov help and try various status commands
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

# Measure all types
check_cov -measure -type {stimuli coi proof}

# Try to get per-type status
puts "=== STIMULI STATUS ==="
check_cov -status -type {stimuli}
puts "=== COI STATUS ==="
check_cov -status -type {coi}
puts "=== PROOF STATUS ==="
check_cov -status -type {proof}
puts "=== ALL STATUS ==="
check_cov -status

# Try per-type reports
puts "=== STIMULI REPORT ==="
check_cov -report -type {stimuli} -report_file cov_master_stimuli.txt -force
puts "=== COI REPORT ==="
check_cov -report -type {coi} -report_file cov_master_coi.txt -force
puts "=== PROOF REPORT ==="
check_cov -report -type {proof} -report_file cov_master_proof.txt -force

# Try list command
puts "=== LIST ==="
check_cov -list

exit -force
