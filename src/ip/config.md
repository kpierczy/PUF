# AnalogSequencerReaderXadc

1. Basic
    - Interface: `DRP`
    - Timing mode: `Event mode`
    - Startup channel selection: `Channel sequencer`
    - DCLK Frequency: `200 MHz`
    - ADC Conversion Rate: `50 KSPS`
    - Constrol/StatusPorts: `convst in`
    - Sim File Selection: `Default`
    - Analog Stimulus File: `xadc-analog-input`
2. ADC Setup
    - Sequencer Mode: `Continuous`
    - Channel Averaging: `None`
    - External Multiplexer: `VAUXP0 VAUXN0`
3. Alarms: all `off`
4. Channel Sequencer:
    - vauxp0/vauxn0 - vauxp8/vauxn0 (all bipolar)

# QuadrupletGeneratorTbBram

1. Basic:
    - Interface type: `Native`
    - Memory type: `Single Port RAM`
2. Port A Options:
    - Read/Write Width: `16`
    - Read/Write Depth: `65`
    - Operating Mode: `Read First`
    - Core Output Register: `Enabled`
    - RSTA Pin (set/reset pin): `Enabled`
    - Enable port type: `Use ENA Pin`
    * Rest options: `Disabled`
3. Other Options:
    - Load Init File: `Enabled`

# TremoloEffectBram

1. Basic:
    - Interface type: `Native`
    - Memory type: `Single Port RAM`
2. Port A Options:
    - Read/Write Width: `16`
    - Read/Write Depth: `129`
    - Operating Mode: `Read First`
    - Core Output Register: `Enabled`
    - RSTA Pin (set/reset pin): `Enabled`
    - Enable port type: `Use ENA Pin`
    * Rest options: `Disabled`
3. Other Options:
    - Load Init File: `Enabled`

# DelayLineTbBram

1. Basic:
    - Interface type: `Native`
    - Memory type: `Single Port RAM`
2. Port A Options:
    - Read/Write Width: `16`
    - Read/Write Depth: `128`
    - Operating Mode: `No change`
    - Core Output Register: `Enabled`
    - RSTA Pin (set/reset pin): `Enabled`
    - Enable port type: `Use ENA Pin`
    * Rest options: `Disabled`
3. Other Options:
    - Load Init File: `Disabled`

# DelayEffectBram

1. Basic:
    - Interface type: `Native`
    - Memory type: `Single Port RAM`
2. Port A Options:
    - Read/Write Width: `16`
    - Read/Write Depth: `44100`
    - Operating Mode: `No change`
    - Core Output Register: `Enabled`
    - RSTA Pin (set/reset pin): `Enabled`
    - Enable port type: `Use ENA Pin`
    * Rest options: `Disabled`
3. Other Options:
    - Load Init File: `Disabled`

# ChorusEffectBram

1. Basic:
    - Interface type: `Native`
    - Memory type: `Single Port RAM`
2. Port A Options:
    - Read/Write Width: `16`
    - Read/Write Depth: `44100`
    - Operating Mode: `No change`
    - Core Output Register: `Enabled`
    - RSTA Pin (set/reset pin): `Enabled`
    - Enable port type: `Use ENA Pin`
    * Rest options: `Disabled`
3. Other Options:
    - Load Init File: `Disabled`

# ChorusEffectGeneratorBram

1. Basic:
    - Interface type: `Native`
    - Memory type: `Single Port RAM`
2. Port A Options:
    - Read/Write Width: `16`
    - Read/Write Depth: `129`
    - Operating Mode: `Read First`
    - Core Output Register: `Enabled`
    - RSTA Pin (set/reset pin): `Enabled`
    - Enable port type: `Use ENA Pin`
    * Rest options: `Disabled`
3. Other Options:
    - Load Init File: `Enabled`
