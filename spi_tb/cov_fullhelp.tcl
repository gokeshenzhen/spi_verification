# Dump full check_cov help to file
clear -all
analyze -v2k ../spi_demo/spi_master.v
analyze -sv property/spi_master_prop.sv
analyze -sv property/spi_master_bind.sv
check_cov -init -model {statement branch expression toggle functional} -type {stimuli coi proof}
elaborate -top spi_master
clock clk
reset !rst_n

# Redirect full help to file
set fh [open "cov_help_full.txt" w]
puts $fh [help check_cov]
close $fh

exit -force
