<!---

This file is used to generate your project datasheet. Please fill in the information below and delete any unused
sections.

You can also include images in this folder and reference them in the markdown. Each image must be less than
512 kb in size, and the combined size of all images must be less than 1 MB.
-->

## Project: TinyTapeout Traffic Light Controller

A compact Verilog implementation of a traffic light controller that uses a 1-second timebase to sequence two directions (north-south and east-west).

### How it works

- `timebase_1s` generates a `sec_tick` pulse once per second from the FPGA clock (`CLK_FREQ` parameter in Hz).
- `traffic_light_controller` consumes `sec_tick` and two duration inputs (`green_duration`, `yellow_duration`) to drive the light outputs.
- The top-level `tt_um_example` interface exposes 8 dedicated inputs (`ui_in`) and outputs (`uo_out`), plus 8 bidirectional IOs (`uio_*`). In this repo `top_module.v` adapts the traffic controller to the `tt_um_example` pin conventions.

### Pin mapping (project defaults)

- `uo[0]` → `ns_red`
- `uo[1]` → `ns_yellow`
- `uo[2]` → `ns_green`
- `uo[3]` → `ew_red`
- `uo[4]` → `ew_yellow`
- `uo[5]` → `ew_green`
- `ui[0..7]` → 8-bit `green_duration` (MSB=ui[7])
- `uio[0..7]` → 8-bit `yellow_duration` (MSB=uio[7])

If you need a different mapping, edit `src/top_module.v` and `info.yaml` accordingly.

### How to test

1. Run the included testbench/simulation (see `test/`): compile `src/*.v` and `test/tb.v` with your simulator (Icarus Verilog, Verilator, etc.).

Example with Icarus Verilog:

```bash
iverilog -g2012 -o tb.vvp src/*.v test/tb.v
vvp tb.vvp
```

2. Inspect `tb.gtkw` with GTKWave to view signals and verify `sec_tick` and light sequencing.

### External hardware

None required for simulation. On real hardware, ensure the `CLK_FREQ` parameter in `timebase_1s.v` matches your board's clock frequency.

