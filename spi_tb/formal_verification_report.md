# SPI Formal Verification Report

| Field | Value |
|-------|-------|
| **Project** | SPI Master/Slave Formal Verification |
| **Date** | 2026-02-07 |
| **Tool** | Cadence JasperGold 2019.03 |
| **Platform** | Linux 2.6.32 (node1) |
| **Methodology** | FPV (Formal Property Verification) + COV (Coverage Analysis) |

---

## 1. Design Under Verification

| Module | File | Lines | Description |
|--------|------|-------|-------------|
| `spi_master` | `spi_demo/spi_master.v` | 94 | SPI Master with configurable CPOL/CPHA, 8-bit transfers, programmable clock divider |
| `spi_slave` | `spi_demo/spi_slave.v` | 88 | SPI Slave with configurable CPOL/CPHA, 8-bit transfers, edge detection |

### Design Features
- **SPI Master**: 4-state FSM (IDLE, LEADING, TRAILING, DONE), configurable clock polarity (cpol) and phase (cpha), 8-bit programmable clock divider (clk_div), full-duplex MOSI/MISO
- **SPI Slave**: Event-driven architecture, SCLK/CS_N edge detection, automatic shift register operation, rx_valid pulse on 8-bit reception, CPHA=0 first-bit loading

---

## 2. Formal Environment Setup

### Clock and Reset
- **Clock**: `clk` (posedge)
- **Reset**: `!rst_n` (active-low, synchronous release)

### Assumptions

| Assumption | Module | Purpose |
|------------|--------|---------|
| `asm_cpol_stable` | Master, Slave | CPOL is a configuration parameter; must remain stable during operation |
| `asm_cpha_stable` | Master, Slave | CPHA is a configuration parameter; must remain stable during operation |
| `clk_div <= 8'd3` | Master (COV only) | Constrains clock divider to exercisable range for coverage analysis |

### Engine Configuration
- **Engine Mode**: `{Ht Hp B}` (Hybrid trace, Hybrid proof, BMC)
- **Max Trace Length**: 200 cycles

---

## 3. FPV Results

### 3.1 SPI Master FPV

**Summary**: 29 of 29 assertions proven (100%)

| Category | Count | Status |
|----------|-------|--------|
| Assertions | 29 | 29 proven (100%) |
| Cover Properties | 7 | 7 covered (100%) |
| Assertion Preconditions | 29 | 23 covered, 6 unreachable |
| Assumptions | 2 | Active |

#### Proven Assertions (29/29)

| # | Assertion | Property | Engine | Bound |
|---|-----------|----------|--------|-------|
| 1 | `ast_reset_state` | After reset release, state == IDLE | PRE | Infinite |
| 2 | `ast_reset_cs_n` | After reset release, cs_n == 1 | PRE | Infinite |
| 3 | `ast_reset_done` | After reset release, done == 0 | PRE | Infinite |
| 4 | `ast_reset_bit_cnt` | After reset release, bit_cnt == 0 | PRE | Infinite |
| 5 | `ast_reset_clk_cnt` | After reset release, clk_cnt == 0 | PRE | Infinite |
| 6 | `ast_reset_rx_data` | After reset release, rx_data == 0 | PRE | Infinite |
| 7 | `ast_idle_to_leading` | IDLE + start -> LEADING | Hp | Infinite |
| 8 | `ast_idle_stay` | IDLE + !start -> IDLE | Hp | Infinite |
| 9 | `ast_leading_to_trailing` | LEADING + clk_cnt match -> TRAILING | Hp | Infinite |
| 10 | `ast_leading_stay` | LEADING + clk_cnt mismatch -> LEADING | Hp | Infinite |
| 11 | `ast_trailing_to_done` | TRAILING + last bit -> DONE | Hp | Infinite |
| 12 | `ast_trailing_to_leading` | TRAILING + more bits -> LEADING | Hp | Infinite |
| 13 | `ast_trailing_stay` | TRAILING + clk_cnt mismatch -> TRAILING | Hp | Infinite |
| 14 | `ast_done_to_idle` | DONE -> IDLE | Hp | Infinite |
| 15 | `ast_cs_n_idle` | CS_N high when idle and not starting | Hp | Infinite |
| 16 | `ast_cs_n_active` | CS_N low during LEADING/TRAILING | Hp | Infinite |
| 17 | `ast_cs_n_deassert_done` | CS_N deasserts after DONE | Hp | Infinite |
| 18 | `ast_done_pulse` | Done is single-cycle pulse | Hp | Infinite |
| 19 | `ast_done_in_done_st` | Done asserted in DONE state | PRE | Infinite |
| 20 | `ast_no_done_outside` | Done deasserted outside DONE state | PRE | Infinite |
| 21 | `ast_bit_cnt_init` | Bit counter initialized to 7 on start | Hp | Infinite |
| 22 | `ast_bit_cnt_dec` | Bit counter decrements on trailing edge | Hp | Infinite |
| 23 | `ast_clk_cnt_reset` | Clock counter resets on match | Hp | Infinite |
| 24 | `ast_clk_cnt_inc` | Clock counter increments | Hp | Infinite |
| 25 | `ast_mosi_init` | MOSI initialized with tx_data[7] on start | Hp | Infinite |
| 26 | `ast_rx_data_capture` | rx_data captures shift_in on last bit | Hp | Infinite |
| 27 | `ast_sclk_idle` | IDLE -> sclk == $past(cpol) (next cycle) | Hp | Infinite |
| 28 | `ast_sclk_leading_toggle` | LEADING + clk_cnt match -> sclk toggled | Hp | Infinite |
| 29 | `ast_sclk_trailing_toggle` | TRAILING + clk_cnt match -> sclk == $past(cpol) | Hp | Infinite |

#### Cover Properties (7/7 covered)

| # | Cover Property | Trace Depth |
|---|---------------|-------------|
| 1 | `cov_idle_to_leading` | 2 cycles |
| 2 | `cov_leading_to_trailing` | 3 cycles |
| 3 | `cov_trailing_to_done` | 18 cycles |
| 4 | `cov_trailing_to_leading` | 4 cycles |
| 5 | `cov_done_to_idle` | 19 cycles |
| 6 | `cov_done_pulse` | 20 cycles |
| 7 | `cov_rx_data_capture` | 18 cycles |

---

### 3.2 SPI Slave FPV

**Summary**: 20 of 20 assertions proven (100%)

| Category | Count | Status |
|----------|-------|--------|
| Assertions | 20 | 20 proven (100%) |
| Cover Properties | 6 | 6 covered (100%) |
| Assertion Preconditions | 18 | 11 covered, 7 unreachable |
| Assumptions | 2 | Active |

#### Proven Assertions (20/20)

| # | Assertion | Property | Engine | Bound |
|---|-----------|----------|--------|-------|
| 1 | `ast_reset_rx_data` | After reset, rx_data == 0 | PRE | Infinite |
| 2 | `ast_reset_rx_valid` | After reset, rx_valid == 0 | PRE | Infinite |
| 3 | `ast_reset_miso` | After reset, miso == 0 | PRE | Infinite |
| 4 | `ast_reset_active` | After reset, active == 0 | PRE | Infinite |
| 5 | `ast_reset_bit_cnt` | After reset, bit_cnt == 0 | PRE | Infinite |
| 6 | `ast_reset_shift_in` | After reset, shift_in == 0 | PRE | Infinite |
| 7 | `ast_reset_shift_out` | After reset, shift_out == 0 | PRE | Infinite |
| 8 | `ast_cs_deassert_inactive` | CS_N high -> active deasserted | PRE | Infinite |
| 9 | `ast_cs_deassert_bit_cnt` | CS_N high -> bit_cnt reset | Hp | Infinite |
| 10 | `ast_cs_fall_activates` | CS_N falling edge -> active | PRE | Infinite |
| 11 | `ast_rx_valid_pulse` | rx_valid is single-cycle pulse | Hp | Infinite |
| 12 | `ast_rx_valid_on_8bits` | rx_valid after 8 sample edges | Hp | Infinite |
| 13 | `ast_rx_data_on_valid` | rx_data correct on valid | Hp | Infinite |
| 14 | `ast_bit_cnt_inc` | Bit counter increments on sample | Hp | Infinite |
| 15 | `ast_bit_cnt_wrap` | Bit counter wraps at 7 | Hp | Infinite |
| 16 | `ast_shift_in_sample` | Shift register samples MOSI | Hp | Infinite |
| 17 | `ast_miso_on_shift_edge` | MISO driven from shift_out[7] | Hp | Infinite |
| 18 | `ast_sclk_d_follows` | sclk_d tracks previous sclk | Ht | Infinite |
| 19 | `ast_cs_n_d_follows` | cs_n_d tracks previous cs_n | PRE | Infinite |
| 20 | `ast_cpha0_first_miso` | CPHA=0: MISO loads on CS_N fall | Hp | Infinite |

#### Cover Properties (6/6 covered)

| # | Cover Property | Trace Depth |
|---|---------------|-------------|
| 1 | `cov_cs_fall_activates` | 2 cycles |
| 2 | `cov_rx_valid_on_8bits` | 17 cycles |
| 3 | `cov_shift_in_sample` | 3 cycles |
| 4 | `cov_miso_on_shift_edge` | 3 cycles |
| 5 | `cov_cpha0_first_miso` | 2 cycles |
| 6 | `cov_bit_cnt_wrap` | 17 cycles |

---

## 4. Coverage Analysis (COV) Results

### 4.1 Coverage Models
Coverage was measured across five models:
- **Statement**: Executable statement reachability
- **Branch**: Decision branch (if/else, case) reachability
- **Expression**: Sub-expression evaluation coverage
- **Toggle**: Signal bit-level toggle (0->1, 1->0) reachability
- **Functional**: Cover property (SVA cover) reachability

### 4.2 Coverage Measurement Types
- **Stimuli**: Input stimulus-based coverage analysis
- **COI**: Cone-of-influence structural analysis
- **Proof**: Proof-based coverage from assertion engines

---

### 4.3 SPI Master Coverage

| Metric | Value |
|--------|-------|
| **Total Cover Items** | 212 |
| **Reachable** | 175 |
| **Unreachable (Waived)** | 37 |
| **Reachable Covered** | **175 / 175 (100.0%)** |

#### Unreachable Items Breakdown (37 items, all waived)

| Category | IDs | Count | Waiver Justification |
|----------|-----|-------|---------------------|
| Reset if-branch | 6 | 1 | Reset branch unreachable after formal reset release; reset behavior verified by 6 proven FPV reset assertions |
| Reset assignments | 8-17 | 10 | Reset path assignments unreachable under formal reset semantics; verified by FPV |
| Clock toggle (RTL) | 53 | 1 | Clock driven by formal infrastructure, not toggleable by design |
| Clock toggle (prop) | 116 | 1 | Property module clock port mirrors RTL clock |
| Reset toggle (RTL) | 54 | 1 | Reset driven by formal infrastructure after initial release |
| Reset toggle (prop) | 117 | 1 | Property module reset port mirrors RTL reset |
| cpol toggle (RTL+prop) | 73, 136 | 2 | Constrained stable by `asm_cpol_stable` assumption |
| cpha toggle (RTL+prop) | 74, 137 | 2 | Constrained stable by `asm_cpha_stable` assumption |
| clk_div[7:2] toggle (RTL) | 75-80 | 6 | Constrained to <=3 by `clk_div <= 8'd3` assumption; bits [7:2] cannot toggle |
| clk_div[7:2] toggle (prop) | 138-143 | 6 | Property module clk_div port mirrors RTL constraint |
| Reset preconditions | 197-202 | 6 | Reset assertion preconditions unreachable under formal reset semantics |

---

### 4.4 SPI Slave Coverage

| Metric | Value |
|--------|-------|
| **Total Cover Items** | 184 |
| **Reachable** | 158 |
| **Unreachable (Waived)** | 26 |
| **Reachable Covered** | **158 / 158 (100.0%)** |

#### Unreachable Items Breakdown (26 items, all waived)

| Category | IDs | Count | Waiver Justification |
|----------|-----|-------|---------------------|
| Reset assignments (always@1) | 11-12 | 2 | Reset path in first always block; verified by FPV |
| Reset if-branch (always@1) | 15 | 1 | Reset branch in first always block; verified by FPV |
| Reset assignments (always@2) | 21-27 | 7 | Reset path in second always block; verified by FPV |
| Reset if-branch (always@2) | 51 | 1 | Reset branch in second always block; verified by FPV |
| Clock toggle (RTL+prop) | 57, 109 | 2 | Clock driven by formal infrastructure |
| Reset toggle (RTL+prop) | 58, 110 | 2 | Reset driven by formal infrastructure |
| cpol toggle (RTL+prop) | 80, 132 | 2 | Constrained stable by `asm_cpol_stable` assumption |
| cpha toggle (RTL+prop) | 81, 133 | 2 | Constrained stable by `asm_cpha_stable` assumption |
| Reset preconditions | 175-181 | 7 | Reset assertion preconditions unreachable under formal reset semantics |

---

## 5. Waiver Summary

All unreachable items have been formally waived with documented justifications. Waivers are exported to:
- `cov_master_waivers.txt` (37 waivers)
- `cov_slave_waivers.txt` (26 waivers)

### Waiver Categories

| Category | Master | Slave | Justification |
|----------|--------|-------|---------------|
| Reset paths (statement/branch) | 11 | 11 | Formal reset mechanism releases reset before property evaluation begins. Reset behavior independently verified by FPV reset assertions (all proven). |
| Clock/reset toggle | 4 | 4 | Clock and reset signals are part of the formal verification infrastructure. Their toggle behavior is controlled by the `clock` and `reset` JasperGold commands, not by design logic. |
| Constrained signal toggle | 16 | 4 | Configuration signals (cpol, cpha) are constrained stable by SVA assumptions reflecting real usage. Master additionally constrains clk_div to <=3, making upper bits untoggleable. |
| Reset assertion preconditions | 6 | 7 | The `disable iff (!rst_n)` / reset antecedent `!rst_n |->` pattern generates precondition covers that are unreachable after formal reset release. |
| **Total** | **37** | **26** | |

---

## 6. Verification Completeness Assessment

### 6.1 Property Coverage by Design Feature

#### SPI Master

| Design Feature | Assertions | Status | Cover Props |
|---------------|------------|--------|-------------|
| Reset behavior | 6 | 6/6 proven | N/A (verified by proof) |
| FSM transitions (IDLE/LEADING/TRAILING/DONE) | 8 | 8/8 proven | 5 covered |
| CS_N control | 3 | 3/3 proven | N/A |
| SCLK generation | 3 | 3/3 proven | N/A |
| Done signal | 3 | 3/3 proven | 1 covered |
| Bit counter | 2 | 2/2 proven | N/A |
| Clock counter | 2 | 2/2 proven | N/A |
| Data path (MOSI/rx_data) | 2 | 2/2 proven | 1 covered |

#### SPI Slave

| Design Feature | Assertions | Status | Cover Props |
|---------------|------------|--------|-------------|
| Reset behavior | 7 | 7/7 proven | N/A (verified by proof) |
| CS_N / active control | 3 | 3/3 proven | 1 covered |
| rx_valid / rx_data | 3 | 3/3 proven | 1 covered |
| Bit counter | 2 | 2/2 proven | 1 covered |
| Shift register | 2 | 2/2 proven | 2 covered |
| Edge detection | 2 | 2/2 proven | N/A |
| CPHA=0 first bit | 1 | 1/1 proven | 1 covered |

### 6.2 Structural Coverage Completeness

| Module | Statement | Branch | Toggle | Expression | Functional | Overall Reachable |
|--------|-----------|--------|--------|------------|------------|-------------------|
| Master | 100% | 100% | 100% | 100% | 100% | **175/175 (100%)** |
| Slave | 100% | 100% | 100% | 100% | 100% | **158/158 (100%)** |

---

## 7. Files and Artifacts

### Property Files
| File | Assertions | Covers | Assumptions |
|------|------------|--------|-------------|
| `property/spi_master_prop.sv` | 29 | 7 | 2 (cpol/cpha stability) |
| `property/spi_master_bind.sv` | - | - | Bind to spi_master |
| `property/spi_slave_prop.sv` | 20 | 6 | 2 (cpol/cpha stability) |
| `property/spi_slave_bind.sv` | - | - | Bind to spi_slave |

### TCL Scripts
| Script | Purpose |
|--------|---------|
| `fpv_run.tcl` | Master FPV: prove all assertions |
| `fpv_slave_run.tcl` | Slave FPV: prove all assertions |
| `cov_run.tcl` | Master COV: coverage measurement + waivers + reporting |
| `cov_slave_run.tcl` | Slave COV: coverage measurement + waivers + reporting |

### Generated Reports
| Report | Content |
|--------|---------|
| `fpv_master_results.txt` | Master FPV detailed results (65 entries) |
| `fpv_master_summary.txt` | Master FPV summary statistics |
| `fpv_slave_results.txt` | Slave FPV detailed results (44 entries) |
| `fpv_slave_summary.txt` | Slave FPV summary statistics |
| `cov_master_results.txt` | Master COV full coverage report (212 items) |
| `cov_master_reachable.txt` | Master COV reachable items (175 items) |
| `cov_master_unreachable.txt` | Master COV unreachable items (37 items) |
| `cov_master_waivers.txt` | Master COV exported waivers (37 waivers) |
| `cov_slave_results.txt` | Slave COV full coverage report (184 items) |
| `cov_slave_reachable.txt` | Slave COV reachable items (158 items) |
| `cov_slave_unreachable.txt` | Slave COV unreachable items (26 items) |
| `cov_slave_waivers.txt` | Slave COV exported waivers (26 waivers) |

---

## 8. Conclusion

| Criterion | Master | Slave | Status |
|-----------|--------|-------|--------|
| FPV Assertions Proven | 29/29 (100%) | 20/20 (100%) | PASS |
| FPV Cover Properties Hit | 7/7 (100%) | 6/6 (100%) | PASS |
| COV Reachable Coverage | 175/175 (100%) | 158/158 (100%) | PASS |
| All Unreachable Items Waived | 37/37 | 26/26 | PASS |
| Waivers Documented & Exported | Yes | Yes | PASS |

**SPI Master**: Fully verified. All 29 assertions proven with infinite bound. 100% reachable coverage achieved with all unreachable items properly waived. **Sign-off: PASS**.

**SPI Slave**: Fully verified. All 20 assertions proven with infinite bound. 100% reachable coverage achieved with all unreachable items properly waived. **Sign-off: PASS**.
