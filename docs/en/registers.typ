= LIST OF REGISTERS
<list-of-registers>
== BASE ADDRESSES
<base-addresses>
The BASE ADDRESS is merely an example for base address mapping and may
not represent the actual address. Since CONTROL and DATA could be two
separate AXI bus interfaces, their base addresses are determined by the
specific bus implementation.

#figure(
  align(center)[#table(
    columns: (0.25fr, 0.25fr, 1fr),
    align: (auto,auto,auto,),
    table.header([BASE ADDRESS], [NAME], [DESCRIPTION],),
    table.hline(),
    [0x0000], [CONTROL], [Control register of this component],
    [0x1000], [DATA], [Data register of this component],
  )]
  , caption: [BASE ADDRESSES]
  , kind: table
  )

== CONTROL
<control>
BASE ADDRESSES = CONTROL

#figure(
  align(center)[#table(
    columns: (0.25fr, 0.25fr, 0.25fr, 1fr),
    align: (auto,auto,auto,auto,),
    table.header([OFFSET], [NAME], [ATTR.], [DESCRIPTION],),
    table.hline(),
    [0x0000], [version], [RO], [IP version],
    [0x0004], [type], [RO], [IP type],
    [0x0008], [arrayWidth], [RO], [Systolic array width],
    [0x000c], [arrayHeight], [RO], [Systolic array height],
    [0x0010], [inputAddr], [RO], [Input data address],
    [0x001c], [outputAddr], [RO], [Output data address],
    [0x0100], [control], [RW], [Basic control register],
    [0x0104], [matmulMode], [RW], [Matmul mode],
  )]
  , caption: [CONTROL REGISTERS]
  , kind: table
  )

#quote(block: true)[
Note that the addresses here are relative addresses, with offset 0
starting from the basic information and metadata of this IP.
Control-related registers will appear in this section. In principle, the
scalar core should have access to the interface where these registers
reside.
]

=== CONTROL REGISTER
<control-register>
#figure(
  align(center)[#table(
    columns: (0.25fr, 0.25fr, 0.25fr, 1fr),
    align: (auto,auto,auto,auto,),
    table.header([BIT], [NAME], [ATTR.], [DESCRIPTION],),
    table.hline(),
    [0], [enable], [RW], [Enable IP],
    [1], [reset], [WO], [Reset IP],
  )]
  , caption: [CONTROL REGISTER]
  , kind: table
  )

=== MATMUL MODE REGISTER
<matmul-mode-register>
#figure(
  align(center)[#table(
    columns: (0.25fr, 0.25fr, 0.25fr, 1fr),
    align: (auto,auto,auto,auto,),
    table.header([BIT], [NAME], [ATTR.], [DESCRIPTION],),
    table.hline(),
    [0], [arrayMode], [RW], [Mode: 0: DMATMUL, 1: SMATMUL],
    [1], [transposed], [RW], [Output transposed: 0: false, 1: true],
  )]
  , caption: [MATMUL MODE REGISTER]
  , kind: table
  )

== DATA
<data>
BASE ADDRESSES = DATA

#figure(
  align(center)[#table(
    columns: (0.25fr, 0.25fr, 0.25fr, 1fr),
    align: (auto,auto,auto,auto,),
    table.header([OFFSET], [NAME], [ATTR.], [DESCRIPTION],),
    table.hline(),
    [0x0000], [inputData], [WO], [Input data],
    [0x1000], [outputData], [RO], [Output data],
  )]
  , caption: [DATA REGISTERS]
  , kind: table
  )

#quote(block: true)[
The inputData and outputData addresses given above are examples only and
are not fixed. They are calculated based on the matrix size (M), with
the result rounded up and aligned to 0x1000, which is described in
detail in the next section. These addresses are preset in the CONTROL
register addresses at the time of IP generation and cannot be changed.
The software determines the data address offsets by reading these
registers.
]

== DATA BUS CONVENTION
<data-bus-convention>
The input data comprises two matrices, one from the north and one from
the west, which are interleaved by 4 bytes with the north in front and
the west in back. Consequently, the offset between inputAddr and
outputAddr is given by the expression `M*M*32/8`, where M is the matrix
size. The interleaving address is designed to match the pattern
generated by segment store instructions. A typical data sequence is
provided below for reference:

a00, b00, a01, b10 … a32, b23, a33, b33

#pagebreak()
