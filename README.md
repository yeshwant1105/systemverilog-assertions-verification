# SystemVerilog Assertions + Formal Verification

A SystemVerilog-based verification project demonstrating concurrent assertions, simulation-based assertion checking, bounded model checking, temporal induction, and formal counterexample generation on a synchronous FIFO.

## Project Overview

This project verifies a parameterized synchronous FIFO using two complementary approaches:

1. SystemVerilog Assertions (SVA) with Verilator
2. Formal verification using Yosys, SMT2, and the Z3 solver

The project demonstrates both simulation-time and mathematically driven verification techniques.

## Design Under Verification

The design is an 8-bit, 8-entry synchronous FIFO.

### Parameters

- Data width: 8 bits
- FIFO depth: 8 entries
- Clock: synchronous
- Reset: synchronous
- Write interface: `wr_en`, `wr_data`
- Read interface: `rd_en`, `rd_data`
- Status: `full`, `empty`
- Occupancy: `count`

## Verification Architecture

    systemverilog-assertions-verification/
    ├── assertions/
    │   └── fifo_assertions.sv
    ├── formal/
    │   └── fifo_formal.sv
    ├── images/
    │   └── sva-verification-waveform.png
    ├── rtl/
    │   └── synchronous_fifo.sv
    ├── sim/
    │   └── .gitkeep
    ├── tb/
    │   └── sva_testbench.sv
    ├── .gitignore
    ├── LICENSE
    └── README.md

## SystemVerilog Assertions

The assertion module checks FIFO safety and state consistency properties including:

- FIFO becomes empty after reset
- Empty implies count is zero
- Full implies count equals FIFO depth
- Count never exceeds FIFO depth
- No write is accepted while FIFO is full
- No read is accepted while FIFO is empty
- A valid write increments count
- A valid read decrements count
- Simultaneous valid read/write preserves count
- Empty transition occurs only at count zero
- Full transition occurs only at maximum count
- Count remains stable without FIFO access

## Simulation-Based SVA Verification

The SVA environment was executed using Verilator with SystemVerilog-2017 support.

Build:

    verilator --binary --language 1800-2017 --timing --trace --Wall --Wno-fatal \
    --top-module sva_testbench \
    rtl/synchronous_fifo.sv \
    assertions/fifo_assertions.sv \
    tb/sva_testbench.sv

Run:

    ./obj_dir/Vsva_testbench

The final simulation completed without assertion failures.

## Assertion Failure Demonstration

The verification environment was intentionally modified to create an illegal read while the FIFO was empty.

The assertion correctly detected the violation:

    Assertion failed: READ attempted while FIFO is empty

This demonstrates that the SVA environment is actively checking design behavior rather than producing only successful results.

## Formal Verification

The FIFO was also analyzed using Yosys and the Z3 SMT solver.

The formal environment models:

- Arbitrary reset behavior
- Arbitrary write enable
- Arbitrary read enable
- Arbitrary write data
- Sequential FIFO state transitions

The formal model verifies the following invariants:

    count <= DEPTH
    empty == (count == 0)
    full == (count == DEPTH)
    !(full && empty)

## Formal Model Generation

Generate the SMT2 model with:

    yosys -p "read_verilog -sv rtl/synchronous_fifo.sv formal/fifo_formal.sv; prep -top fifo_formal; clk2fflogic; write_smt2 -wires formal/fifo.smt2"

## Bounded Model Checking

A 50-step bounded model check was executed using Z3:

    yosys-smtbmc -s z3 -t 50 formal/fifo.smt2

Result:

    Status: PASSED

The design properties were checked across 50 sequential formal steps.

## Temporal Induction

The same formal model was subjected to temporal induction:

    yosys-smtbmc -s z3 -t 50 -i formal/fifo.smt2

Result:

    Temporal induction successful.
    Status: PASSED

This provides stronger evidence than a finite bounded search because the properties were successfully established through the induction procedure.

## Formal Counterexample Demonstration

To verify that the formal environment can actually detect an incorrect property, the assertion:

    assert(count <= DEPTH);

was temporarily replaced with the intentionally incorrect property:

    assert(count == 0);

The formal engine detected the violation at step 2:

    BMC failed!
    Assert failed in fifo_formal
    Status: FAILED

A formal counterexample VCD was generated during this experiment.

The incorrect assertion was then removed and the original verified formal model was restored.

## Waveform

The SVA simulation waveform is included in:

    images/sva-verification-waveform.png

The waveform demonstrates clock, reset, FIFO controls, occupancy, and status behavior during verification.

## Tools Used

- SystemVerilog
- Verilator 5.050
- Yosys 0.68
- Yosys SMTBMC
- Z3 5.1.0
- GTKWave
- Icarus Verilog

## Verification Results

| Verification Method | Result |
|---|---|
| SVA simulation | PASS |
| Intentional SVA failure detection | PASS |
| Formal BMC — 50 steps | PASS |
| Temporal induction | PASS |
| Intentional formal failure detection | PASS |
| Formal counterexample generation | PASS |

## Key Learning Outcomes

This project demonstrates practical experience with:

- Concurrent SystemVerilog Assertions
- Property-based verification
- Assertion-driven simulation
- Formal verification
- Bounded Model Checking
- Temporal induction
- SMT-based verification
- Counterexample analysis
- Yosys formal flows
- Z3 solver integration
- FIFO safety and state invariants
- GTKWave waveform analysis

## Why This Project Matters

Traditional simulation can only explore the scenarios that are explicitly generated.

Formal verification instead explores possible state transitions symbolically and can automatically search for violations of specified properties.

Combining SVA simulation with formal verification provides a stronger verification methodology for RTL designs.

## Author

Yeshwant Chintakindi

ECE | VLSI | RTL Design | Design Verification

## License

This project is licensed under the MIT License.
