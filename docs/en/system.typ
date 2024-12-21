= SYSTEM DESCRIPTION
<system-description>
#figure(image("images/matmul_system_description.drawio.svg"),
  caption: [
    SYSTEM DESCRIPTION
  ]
)

== VARIABLE
<variable>
#figure(
  align(center)[#table(
    columns: (0.25fr, 0.25fr, 1fr),
    align: (auto,auto,auto,),
    table.header([VAR.], [DESCRIPTION], [RANGE],),
    table.hline(),
    [M], [Matrix size], [\[4,256\]],
  )]
  , caption: [VARIABLES]
  , kind: table
  )

== DESIGN PARAMETERS
<design-parameters>
#figure(
  align(center)[#table(
    columns: (0.25fr, 1fr),
    align: (auto,auto,),
    table.header([PARAMETER], [TYP],),
    table.hline(),
    [Array shape], [Square],
    [Array size], [M, MIN:4×4, TYP:16×16, MAX: 256×256],
    [Array mode], [DMATMUL, SMATMUL],
    [Data type], [FP32],
    [Buffer size], [2×M-1, MIN:7, TYP:31, MAX: 511],
  )]
  , caption: [DESIGN PARAMETERS]
  , kind: table
  )

#pagebreak()
