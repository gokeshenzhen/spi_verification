# Get per-item coverage info for SPI Master
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

# Get all valid -get subcommands
puts "===== GET SUBCOMMANDS ====="
catch {check_cov -get_target_info} gti_err
puts "get_target_info: $gti_err"

catch {check_cov -get_coverage} gc_err
puts "get_coverage: $gc_err"

catch {check_cov -get_model_info} gmi_err
puts "get_model_info: $gmi_err"

catch {check_cov -get_item_info} gii_err
puts "get_item_info: $gii_err"

# Try get_target_info for all items
puts "===== GET TARGET INFO ALL ====="
catch {set gti_all [check_cov -get_target_info -silent]} gti_all_err
puts "Result: $gti_all_err"

# Try with specific cover item
puts "===== GET TARGET INFO ITEM 1 ====="
catch {set gti1 [check_cov -get_target_info 1]} gti1_err
puts "Item 1: $gti1_err"

puts "===== GET TARGET INFO ITEM 1 COI ====="
catch {set gti1c [check_cov -get_target_info 1 -coi]} gti1c_err
puts "Item 1 COI: $gti1c_err"

puts "===== GET TARGET INFO ITEM 1 PROOF ====="
catch {set gti1p [check_cov -get_target_info 1 -proof_core]} gti1p_err
puts "Item 1 Proof: $gti1p_err"

# Try a few more items
puts "===== ITEMS 53 73 179 ====="
catch {set r53 [check_cov -get_target_info 53]} r53e
puts "Item 53 (clk toggle): $r53e"
catch {set r179 [check_cov -get_target_info 179]} r179e
puts "Item 179 (cov_rx_data_capture): $r179e"

exit -force
