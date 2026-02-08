# Per-type coverage detail extraction for SPI Master
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

# Measure each type separately and capture output
puts "========== STIMULI MEASURE =========="
set stim [check_cov -measure -type {stimuli}]
puts "Stimuli result: $stim"

puts "========== STIMULI REPORT COVERED =========="
catch {check_cov -report -type {covered} -report_file cov_stim_covered.txt -force} e1
puts "covered: $e1"

puts "========== STIMULI REPORT UNCOVERED =========="
catch {check_cov -report -type {uncovered} -report_file cov_stim_uncovered.txt -force} e2
puts "uncovered: $e2"

puts "========== COI MEASURE =========="
set coi [check_cov -measure -type {coi}]
puts "COI result: $coi"

puts "========== COI REPORT COVERED =========="
catch {check_cov -report -type {covered} -report_file cov_coi_covered.txt -force} e3
puts "covered: $e3"

puts "========== COI REPORT UNCOVERED =========="
catch {check_cov -report -type {uncovered} -report_file cov_coi_uncovered.txt -force} e4
puts "uncovered: $e4"

puts "========== PROOF MEASURE =========="
set prf [check_cov -measure -type {proof}]
puts "Proof result: $prf"

puts "========== PROOF REPORT COVERED =========="
catch {check_cov -report -type {covered} -report_file cov_proof_covered.txt -force} e5
puts "covered: $e5"

puts "========== PROOF REPORT UNCOVERED =========="
catch {check_cov -report -type {uncovered} -report_file cov_proof_uncovered.txt -force} e6
puts "uncovered: $e6"

# Try report -type with stimuli/coi/proof directly
puts "========== REPORT TYPE STIMULI =========="
catch {check_cov -report -type {stimuli} -report_file cov_rpt_stimuli.txt -force} e7
puts "type stimuli: $e7"

puts "========== REPORT TYPE COI =========="
catch {check_cov -report -type {coi} -report_file cov_rpt_coi.txt -force} e8
puts "type coi: $e8"

puts "========== REPORT TYPE PROOF =========="
catch {check_cov -report -type {proof} -report_file cov_rpt_proof.txt -force} e9
puts "type proof: $e9"

# Try check_cov -status after all measurements
puts "========== CHECK_COV STATUS =========="
catch {check_cov -status} e10
puts "status: $e10"

# Get detailed results using -get_cover_item_info with just IDs
puts "========== GET COVER ITEM INFO =========="
catch {check_cov -get_cover_item_info 1} e11
puts "item 1: $e11"

catch {check_cov -get_cover_item_info -id 1} e12
puts "item -id 1: $e12"

catch {check_cov -get_cover_item_info -item 1} e13
puts "item -item 1: $e13"

# Try help for get_cover_item_info
puts "========== HELP =========="
catch {help check_cov -get_cover_item_info} e14
puts "help: $e14"

catch {help check_cov} e15
puts "help check_cov: $e15"

# Also try check_cov -list to see all cover items with status
puts "========== LIST =========="
catch {check_cov -list} e16
puts "list: $e16"

catch {check_cov -list_cover_items} e17
puts "list_cover_items: $e17"

# Try to get the percentages summary
puts "========== PERCENTAGES =========="
catch {check_cov -measure -type {stimuli} -report} e18
puts "stimuli measure report: $e18"

catch {check_cov -measure -type {coi} -report} e19
puts "coi measure report: $e19"

catch {check_cov -measure -type {proof} -report} e20
puts "proof measure report: $e20"

exit -force
