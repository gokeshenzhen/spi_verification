# Get full help and per-item coverage info
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
check_cov -measure -type {stimuli coi proof}

# Get per-cover-item info using -get_cover_info
catch {check_cov -get_cover_info} err1
puts "get_cover_info: $err1"

# Try -get_cover_item_info
catch {check_cov -get_cover_item_info} err2
puts "get_cover_item_info: $err2"

# Try -get with various sub args
catch {check_cov -get_data} err3
puts "get_data: $err3"

# Try report with -format
catch {check_cov -report -type {all} -format csv -report_file cov_master_csv.txt -force} err4
puts "report csv: $err4"

# Try report with -stimuli / -coi / -proof_core
catch {check_cov -report -stimuli -report_file cov_master_stimuli_rpt.txt -force} err5
puts "report -stimuli: $err5"

catch {check_cov -report -coi -report_file cov_master_coi_rpt.txt -force} err6
puts "report -coi: $err6"

catch {check_cov -report -proof_core -report_file cov_master_proof_rpt.txt -force} err7
puts "report -proof_core: $err7"

# Try -get_cover_item_info with item ID
catch {check_cov -get_cover_item_info -cover_item_id {1 2 3}} err8
puts "get_cover_item_info with ids: $err8"

# Try check_cov without any switch to see error listing valid switches
catch {check_cov} err9
puts "no args: $err9"

exit -force
