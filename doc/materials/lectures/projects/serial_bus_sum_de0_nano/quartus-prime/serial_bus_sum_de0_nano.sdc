create_clock -name "DE0_CLK" -period 20.000ns [get_ports {CLK}]
derive_pll_clocks
derive_clock_uncertainty
