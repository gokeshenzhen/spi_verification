# Extract per-type coverage for all items - SPI Master
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

# Open output file
set fh [open "cov_pertype_extract.txt" w]

# ===== STEP 1: Measure STIMULI only =====
puts $fh "============================================================"
puts $fh "AFTER STIMULI MEASURE"
puts $fh "============================================================"
check_cov -measure -type {stimuli}

set stim_covered 0
set stim_uncovered 0
set stim_unreachable 0
for {set i 1} {$i <= 220} {incr i} {
    if {![catch {set info [check_cov -get_cover_item_info $i]} err]} {
        puts $fh "ITEM $i: $info"
        if {[string match "*Covered*" $info]} {
            incr stim_covered
        } elseif {[string match "*Unreachable*" $info]} {
            incr stim_unreachable
        } else {
            incr stim_uncovered
        }
    }
}
puts $fh ""
puts $fh "STIMULI SUMMARY: covered=$stim_covered uncovered=$stim_uncovered unreachable=$stim_unreachable"
puts $fh ""

# ===== STEP 2: Measure COI (cumulative with stimuli) =====
puts $fh "============================================================"
puts $fh "AFTER COI MEASURE (cumulative)"
puts $fh "============================================================"
check_cov -measure -type {coi}

set coi_covered 0
set coi_uncovered 0
set coi_unreachable 0
for {set i 1} {$i <= 220} {incr i} {
    if {![catch {set info [check_cov -get_cover_item_info $i]} err]} {
        puts $fh "ITEM $i: $info"
        if {[string match "*Covered*" $info]} {
            incr coi_covered
        } elseif {[string match "*Unreachable*" $info]} {
            incr coi_unreachable
        } else {
            incr coi_uncovered
        }
    }
}
puts $fh ""
puts $fh "STIMULI+COI SUMMARY: covered=$coi_covered uncovered=$coi_uncovered unreachable=$coi_unreachable"
puts $fh ""

# ===== STEP 3: Measure PROOF (cumulative with stimuli+coi) =====
puts $fh "============================================================"
puts $fh "AFTER PROOF MEASURE (cumulative)"
puts $fh "============================================================"
check_cov -measure -type {proof}

set proof_covered 0
set proof_uncovered 0
set proof_unreachable 0
for {set i 1} {$i <= 220} {incr i} {
    if {![catch {set info [check_cov -get_cover_item_info $i]} err]} {
        puts $fh "ITEM $i: $info"
        if {[string match "*Covered*" $info]} {
            incr proof_covered
        } elseif {[string match "*Unreachable*" $info]} {
            incr proof_unreachable
        } else {
            incr proof_uncovered
        }
    }
}
puts $fh ""
puts $fh "STIMULI+COI+PROOF SUMMARY: covered=$proof_covered uncovered=$proof_uncovered unreachable=$proof_unreachable"
puts $fh ""

# ===== Overall summary =====
set total [expr {$proof_covered + $proof_uncovered + $proof_unreachable}]
puts $fh "============================================================"
puts $fh "OVERALL SUMMARY"
puts $fh "============================================================"
puts $fh "Total items: $total"
puts $fh "After STIMULI:           covered=$stim_covered uncovered=$stim_uncovered unreachable=$stim_unreachable"
puts $fh "After STIMULI+COI:       covered=$coi_covered uncovered=$coi_uncovered unreachable=$coi_unreachable"
puts $fh "After STIMULI+COI+PROOF: covered=$proof_covered uncovered=$proof_uncovered unreachable=$proof_unreachable"
puts $fh ""
if {$total > 0} {
    set stim_pct [format "%.2f" [expr {100.0 * $stim_covered / $total}]]
    set coi_pct [format "%.2f" [expr {100.0 * $coi_covered / $total}]]
    set proof_pct [format "%.2f" [expr {100.0 * $proof_covered / $total}]]
    set stim_reach_pct [format "%.2f" [expr {100.0 * $stim_covered / ($total - $stim_unreachable)}]]
    set coi_reach_pct [format "%.2f" [expr {100.0 * $coi_covered / ($total - $coi_unreachable)}]]
    set proof_reach_pct [format "%.2f" [expr {100.0 * $proof_covered / ($total - $proof_unreachable)}]]
    puts $fh "STIMULI coverage:           $stim_pct% (total) / $stim_reach_pct% (reachable)"
    puts $fh "STIMULI+COI coverage:       $coi_pct% (total) / $coi_reach_pct% (reachable)"
    puts $fh "STIMULI+COI+PROOF coverage: $proof_pct% (total) / $proof_reach_pct% (reachable)"
}

close $fh

puts "Done! Results written to cov_pertype_extract.txt"

exit -force
