# Get per-type coverage percentages for SPI Master
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

# Capture return values from each measure type
puts "===== STIMULI MEASURE ====="
set stim_result [check_cov -measure -type {stimuli}]
puts "Stimuli return: $stim_result"

puts "===== COI MEASURE ====="
set coi_result [check_cov -measure -type {coi}]
puts "COI return: $coi_result"

puts "===== PROOF MEASURE ====="
set proof_result [check_cov -measure -type {proof}]
puts "Proof return: $proof_result"

# Get help for check_cov to find all valid options
puts "===== CHECK_COV HELP ====="
help check_cov

# Try to get coverage summary/percentage
puts "===== TRYING SUMMARY ====="
catch {check_cov -summary} summary_err
puts "Summary result: $summary_err"

puts "===== TRYING GET ====="
catch {check_cov -get} get_err
puts "Get result: $get_err"

puts "===== TRYING QUERY ====="
catch {check_cov -query} query_err
puts "Query result: $query_err"

puts "===== TRYING COVERAGE_INFO ====="
catch {check_cov -coverage_info} info_err
puts "Coverage info result: $info_err"

# Also try get_coverage_info
puts "===== TRYING GET_COVERAGE_INFO ====="
catch {get_coverage_info} gci_err
puts "get_coverage_info result: $gci_err"

exit -force
