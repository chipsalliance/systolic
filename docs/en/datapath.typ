= DATA PATH
<data-path>
The following Datapath discussion focuses on computations involving 4x4
square matrices, for example, take matrix A and matrix B and multiply
them to get matrix C.

$ A = mat(delim: "[", a_00, a_01, a_02, a_03; a_10, a_11, a_12, a_13; a_20, a_21, a_22, a_23; a_30, a_31, a_32, a_33) quad B = mat(delim: "[", b_00, b_01, b_02, b_03; b_10, b_11, b_12, b_13; b_20, b_21, b_22, b_23; b_30, b_31, b_32, b_33) quad C = A dot.op B $

At this point, the result of matrix C should be as follows:

#figure(
  align(center)[#table(
    columns: (0.25fr, 1fr),
    align: (auto,auto,),
    table.header([Element], [Value],),
    table.hline(),
    [c00], [a00⋅b00 + a01⋅b10 + a02⋅b20 + a03⋅b30],
    [c01], [a00⋅b01 + a01⋅b11 + a02⋅b21 + a03⋅b31],
    [c02], [a00⋅b02 + a01⋅b12 + a02⋅b22 + a03⋅b32],
    [c03], [a00⋅b03 + a01⋅b13 + a02⋅b23 + a03⋅b33],
    [c10], [a10⋅b00 + a11⋅b10 + a12⋅b20 + a13⋅b30],
    [c11], [a10⋅b01 + a11⋅b11 + a12⋅b21 + a13⋅b31],
    [c12], [a10⋅b02 + a11⋅b12 + a12⋅b22 + a13⋅b32],
    [c13], [a10⋅b03 + a11⋅b13 + a12⋅b23 + a13⋅b33],
    [c20], [a20⋅b00 + a21⋅b10 + a22⋅b20 + a23⋅b30],
    [c21], [a20⋅b01 + a21⋅b11 + a22⋅b21 + a23⋅b31],
    [c22], [a20⋅b02 + a21⋅b12 + a22⋅b22 + a23⋅b32],
    [c23], [a20⋅b03 + a21⋅b13 + a22⋅b23 + a23⋅b33],
    [c30], [a30⋅b00 + a31⋅b10 + a32⋅b20 + a33⋅b30],
    [c31], [a30⋅b01 + a31⋅b11 + a32⋅b21 + a33⋅b31],
    [c32], [a30⋅b02 + a31⋅b12 + a32⋅b22 + a33⋅b32],
    [c33], [a30⋅b03 + a31⋅b13 + a32⋅b23 + a33⋅b33],
  )]
  , caption: [Matrix C Calculation]
  , kind: table
  )

== DMATMUL DATA PATH
<dmatmul-data-path>
DMATMUL (Dynamic Matrix Multiplication): Represents a MATMUL
implementation where both matrix A and matrix B are changing, suitable
for general calculations.

This is a MATMUL implementation of non-shared parameters, suitable for
situations where both matrix A and matrix B are changing, and is
suitable for general calculations.

When calculating matrix C = A ⋅ B using a systolic array, the data of
matrices A and B need to be padded in a special way before being
sequentially input into the systolic array.

#figure(image("images/dmatmul_datapath_4x4_01.drawio.svg"),
  caption: [
    DMATMUL DATAPATH 4x4 01
  ]
)

At the start of the computation, the first byte of the matrix A buffer
and the matrix B buffer flows into the systolic array.

#figure(image("images/dmatmul_datapath_4x4_02.drawio.svg"),
  caption: [
    DMATMUL DATAPATH 4x4 02
  ]
)

#figure(
  align(center)[#table(
    columns: (0.25fr, 1fr),
    align: (auto,auto,),
    table.header([Element], [Value],),
    table.hline(),
    [t00], [a00⋅b00],
    [t01], [previous round of computation],
    [t02], [previous round of computation],
    [t03], [previous round of computation],
    [t10], [previous round of computation],
    [t11], [previous round of computation],
    [t12], [previous round of computation],
    [t13], [previous round of computation],
    [t20], [previous round of computation],
    [t21], [previous round of computation],
    [t22], [previous round of computation],
    [t23], [previous round of computation],
    [t30], [previous round of computation],
    [t31], [previous round of computation],
    [t32], [previous round of computation],
    [t33], [previous round of computation],
  )]
  , caption: [DMATMUL DATAPATH 4x4 02]
  , kind: table
  )

#figure(image("images/dmatmul_datapath_4x4_03.drawio.svg"),
  caption: [
    DMATMUL DATAPATH 4x4 03
  ]
)

#figure(
  align(center)[#table(
    columns: (0.25fr, 1fr),
    align: (auto,auto,),
    table.header([Element], [Value],),
    table.hline(),
    [t00], [a00⋅b00 + a01⋅b10],
    [t01], [a00⋅b01],
    [t02], [previous round of computation],
    [t03], [previous round of computation],
    [t10], [a10⋅b00],
    [t11], [previous round of computation],
    [t12], [previous round of computation],
    [t13], [previous round of computation],
    [t20], [previous round of computation],
    [t21], [previous round of computation],
    [t22], [previous round of computation],
    [t23], [previous round of computation],
    [t30], [previous round of computation],
    [t31], [previous round of computation],
    [t32], [previous round of computation],
    [t33], [previous round of computation],
  )]
  , caption: [DMATMUL DATAPATH 4x4 03]
  , kind: table
  )

#figure(image("images/dmatmul_datapath_4x4_04.drawio.svg"),
  caption: [
    DMATMUL DATAPATH 4x4 04
  ]
)

#figure(
  align(center)[#table(
    columns: (0.25fr, 1fr),
    align: (auto,auto,),
    table.header([Element], [Value],),
    table.hline(),
    [t00], [a00⋅b00 + a01⋅b10 + a02⋅b20],
    [t01], [a00⋅b01 + a01⋅b11],
    [t02], [a00⋅b02],
    [t03], [previous round of computation],
    [t10], [a10⋅b00 + a11⋅b10],
    [t11], [a10⋅b01],
    [t12], [previous round of computation],
    [t13], [previous round of computation],
    [t20], [a20⋅b00],
    [t21], [previous round of computation],
    [t22], [previous round of computation],
    [t23], [previous round of computation],
    [t30], [previous round of computation],
    [t31], [previous round of computation],
    [t32], [previous round of computation],
    [t33], [previous round of computation],
  )]
  , caption: [DMATMUL DATAPATH 4x4 04]
  , kind: table
  )

At this point, c00​ has already been computed, and the value in t00​
represents c00c00​. Note that the result from the previous computation
may still be present, and this value will enter the ping-pong buffer.

#figure(image("images/dmatmul_datapath_4x4_05.drawio.svg"),
  caption: [
    DMATMUL DATAPATH 4x4 05
  ]
)

#figure(
  align(center)[#table(
    columns: (0.25fr, 1fr),
    align: (auto,auto,),
    table.header([Element], [Value],),
    table.hline(),
    [t00], [a00⋅b00 + a01⋅b10 + a02⋅b20 + a03⋅b30],
    [t01], [a00⋅b01 + a01⋅b11 + a02⋅b21],
    [t02], [a00⋅b02 + a01⋅b12],
    [t03], [a00⋅b03],
    [t10], [a10⋅b00 + a11⋅b10 + a12⋅b20],
    [t11], [a10⋅b01 + a11⋅b11],
    [t12], [a10⋅b02],
    [t13], [previous round of computation],
    [t20], [a20⋅b00+a21⋅b10],
    [t21], [a20⋅b01],
    [t22], [previous round of computation],
    [t23], [previous round of computation],
    [t30], [a30⋅b00],
    [t31], [previous round of computation],
    [t32], [previous round of computation],
    [t33], [previous round of computation],
  )]
  , caption: [DMATMUL DATAPATH 4x4 05]
  , kind: table
  )

#figure(image("images/dmatmul_datapath_4x4_06.drawio.svg"),
  caption: [
    DMATMUL DATAPATH 4x4 06
  ]
)

#figure(
  align(center)[#table(
    columns: (0.25fr, 1fr),
    align: (auto,auto,),
    table.header([Element], [Value],),
    table.hline(),
    [t00], [next round of computation],
    [t01], [a00⋅b01 + a01⋅b11 + a02⋅b21 + a03⋅b31],
    [t02], [a00⋅b02 + a01⋅b12 + a02⋅b22],
    [t03], [a00⋅b03 + a01⋅b13],
    [t10], [a10⋅b00 + a11⋅b10 + a12⋅b20 + a13⋅b30],
    [t11], [a10⋅b01 + a11⋅b11 + a12⋅b21],
    [t12], [a10⋅b02 + a11⋅b12],
    [t13], [a10⋅b03],
    [t20], [a20⋅b00 + a21⋅b10 + a22⋅b20],
    [t21], [a20⋅b01 + a21⋅b11],
    [t22], [a20⋅b02],
    [t23], [previous round of computation],
    [t30], [a30⋅b00 + a31⋅b10],
    [t31], [a30⋅b01],
    [t32], [previous round of computation],
    [t33], [previous round of computation],
  )]
  , caption: [DMATMUL DATAPATH 4x4 06]
  , kind: table
  )

#figure(image("images/dmatmul_datapath_4x4_07.drawio.svg"),
  caption: [
    DMATMUL DATAPATH 4x4 07
  ]
)

#figure(
  align(center)[#table(
    columns: (0.25fr, 1fr),
    align: (auto,auto,),
    table.header([Element], [Value],),
    table.hline(),
    [t00], [next round of computation],
    [t01], [next round of computation],
    [t02], [a00⋅b02 + a01⋅b12 + a02⋅b22 + a03⋅b32],
    [t03], [a00⋅b03 + a01⋅b13 + a02⋅b23],
    [t10], [next round of computation],
    [t11], [a10⋅b01 + a11⋅b11 + a12⋅b21 + a13⋅b31],
    [t12], [a10⋅b02 + a11⋅b12 + a12⋅b22],
    [t13], [a10⋅b03 + a11⋅b13],
    [t20], [a20⋅b00 + a21⋅b10 + a22⋅b20 + a23⋅b30],
    [t21], [a20⋅b01 + a21⋅b11 + a22⋅b21],
    [t22], [a20⋅b02 + a21⋅b12],
    [t23], [a20⋅b03],
    [t30], [a30⋅b00 + a31⋅b10 + a32⋅b20],
    [t31], [a30⋅b01 + a31⋅b11],
    [t32], [a30⋅b02],
    [t33], [previous round of computation],
  )]
  , caption: [DMATMUL DATAPATH 4x4 07]
  , kind: table
  )

#figure(image("images/dmatmul_datapath_4x4_08.drawio.svg"),
  caption: [
    DMATMUL DATAPATH 4x4 08
  ]
)

#figure(
  align(center)[#table(
    columns: (0.25fr, 1fr),
    align: (auto,auto,),
    table.header([Element], [Value],),
    table.hline(),
    [t00], [next round of computation],
    [t01], [next round of computation],
    [t02], [next round of computation],
    [t03], [a00⋅b03 + a01⋅b13 + a02⋅b23 + a03⋅b33],
    [t10], [next round of computation],
    [t11], [next round of computation],
    [t12], [a10⋅b02 + a11⋅b12 + a12⋅b22 + a13⋅b32],
    [t13], [a10⋅b03 + a11⋅b13 + a12⋅b23],
    [t20], [next round of computation],
    [t21], [a20⋅b01 + a21⋅b11 + a22⋅b21 + a23⋅b31],
    [t22], [a20⋅b02 + a21⋅b12 + a22⋅b22],
    [t23], [a20⋅b03 + a21⋅b13],
    [t30], [a30⋅b00 + a31⋅b10 + a32⋅b20 + a33⋅b30],
    [t31], [a30⋅b01 + a31⋅b11 + a32⋅b21],
    [t32], [a30⋅b02 + a31⋅b12],
    [t33], [a30⋅b03],
  )]
  , caption: [DMATMUL DATAPATH 4x4 08]
  , kind: table
  )

#figure(image("images/dmatmul_datapath_4x4_09.drawio.svg"),
  caption: [
    DMATMUL DATAPATH 4x4 09
  ]
)

#figure(
  align(center)[#table(
    columns: (0.25fr, 1fr),
    align: (auto,auto,),
    table.header([Element], [Value],),
    table.hline(),
    [t00], [next round of computation],
    [t01], [next round of computation],
    [t02], [next round of computation],
    [t03], [next round of computation],
    [t10], [next round of computation],
    [t11], [next round of computation],
    [t12], [next round of computation],
    [t13], [a10⋅b03 + a11⋅b13 + a12⋅b23 + a13⋅b33],
    [t20], [next round of computation],
    [t21], [next round of computation],
    [t22], [a20⋅b02 + a21⋅b12 + a22⋅b22 + a23⋅b32],
    [t23], [a20⋅b03 + a21⋅b13 + a22⋅b23],
    [t30], [next round of computation],
    [t31], [a30⋅b01 + a31⋅b11 + a32⋅b21 + a33⋅b31],
    [t32], [a30⋅b02 + a31⋅b12 + a32⋅b22],
    [t33], [a30⋅b03 + a31⋅b13],
  )]
  , caption: [DMATMUL DATAPATH 4x4 09]
  , kind: table
  )

#figure(image("images/dmatmul_datapath_4x4_10.drawio.svg"),
  caption: [
    DMATMUL DATAPATH 4x4 10
  ]
)

#figure(
  align(center)[#table(
    columns: (0.25fr, 1fr),
    align: (auto,auto,),
    table.header([Element], [Value],),
    table.hline(),
    [t00], [next round of computation],
    [t01], [next round of computation],
    [t02], [next round of computation],
    [t03], [next round of computation],
    [t10], [next round of computation],
    [t11], [next round of computation],
    [t12], [next round of computation],
    [t13], [next round of computation],
    [t20], [next round of computation],
    [t21], [next round of computation],
    [t22], [next round of computation],
    [t23], [a20⋅b03 + a21⋅b13 + a22⋅b23 + a23⋅b33],
    [t30], [next round of computation],
    [t31], [next round of computation],
    [t32], [a30⋅b02 + a31⋅b12 + a32⋅b22 + a33⋅b32],
    [t33], [a30⋅b03 + a31⋅b13 + a32⋅b23],
  )]
  , caption: [DMATMUL DATAPATH 4x4 10]
  , kind: table
  )

#figure(image("images/dmatmul_datapath_4x4_11.drawio.svg"),
  caption: [
    DMATMUL DATAPATH 4x4 11
  ]
)

#figure(
  align(center)[#table(
    columns: (0.25fr, 1fr),
    align: (auto,auto,),
    table.header([Element], [Value],),
    table.hline(),
    [t00], [next round of computation],
    [t01], [next round of computation],
    [t02], [next round of computation],
    [t03], [next round of computation],
    [t10], [next round of computation],
    [t11], [next round of computation],
    [t12], [next round of computation],
    [t13], [next round of computation],
    [t20], [next round of computation],
    [t21], [next round of computation],
    [t22], [next round of computation],
    [t23], [next round of computation],
    [t30], [next round of computation],
    [t31], [next round of computation],
    [t32], [next round of computation],
    [t33], [a30⋅b03 + a31⋅b13 + a32⋅b23 + a33⋅b33],
  )]
  , caption: [DMATMUL DATAPATH 4x4 11]
  , kind: table
  )

At this point, all computations have been completed, and the data in the
ping-pong buffer begins to be output. Depending on the need for matrix
transposition, the output direction can be selected, allowing either
matrix C or the transpose of matrix C ($C^T$) to be obtained.

#figure(image("images/dmatmul_datapath_4x4_12.drawio.svg"),
  caption: [
    DMATMUL DATAPATH 4x4 12
  ]
)

#figure(image("images/dmatmul_datapath_4x4_13.drawio.svg"),
  caption: [
    DMATMUL DATAPATH 4x4 13
  ]
)

#figure(image("images/dmatmul_datapath_4x4_14.drawio.svg"),
  caption: [
    DMATMUL DATAPATH 4x4 14
  ]
)

#figure(image("images/dmatmul_datapath_4x4_15.drawio.svg"),
  caption: [
    DMATMUL DATAPATH 4x4 15
  ]
)

== SMATMUL DATA PATH
<smatmul-data-path>
SMATMUL (Static Matrix Multiplication): Represents a MATMUL
implementation where matrix B is fixed and matrix A changes,
particularly suitable for convolutional neural network calculations.

This is a MATMUL implementation of shared matrix B. It is suitable for
calculations where matrix A changes but matrix B is fixed. This
calculation is particularly suitable for matrix multiplication of
convolutional neural networks.

#figure(image("images/smatmul_datapath_4x4_01.drawio.svg"),
  caption: [
    SMATMUL DATAPATH 4x4 01
  ]
)

#figure(image("images/smatmul_datapath_4x4_02.drawio.svg"),
  caption: [
    SMATMUL DATAPATH 4x4 02
  ]
)

#figure(image("images/smatmul_datapath_4x4_03.drawio.svg"),
  caption: [
    SMATMUL DATAPATH 4x4 03
  ]
)

#figure(image("images/smatmul_datapath_4x4_04.drawio.svg"),
  caption: [
    SMATMUL DATAPATH 4x4 04
  ]
)

#figure(image("images/smatmul_datapath_4x4_05.drawio.svg"),
  caption: [
    SMATMUL DATAPATH 4x4 05
  ]
)

#figure(image("images/smatmul_datapath_4x4_06.drawio.svg"),
  caption: [
    SMATMUL DATAPATH 4x4 06
  ]
)

#figure(image("images/smatmul_datapath_4x4_07.drawio.svg"),
  caption: [
    SMATMUL DATAPATH 4x4 07
  ]
)

#figure(image("images/smatmul_datapath_4x4_08.drawio.svg"),
  caption: [
    SMATMUL DATAPATH 4x4 08
  ]
)

#figure(image("images/smatmul_datapath_4x4_09.drawio.svg"),
  caption: [
    SMATMUL DATAPATH 4x4 09
  ]
)

#figure(image("images/smatmul_datapath_4x4_10.drawio.svg"),
  caption: [
    SMATMUL DATAPATH 4x4 10
  ]
)

#figure(image("images/smatmul_datapath_4x4_11.drawio.svg"),
  caption: [
    SMATMUL DATAPATH 4x4 11
  ]
)

#figure(image("images/smatmul_datapath_4x4_12.drawio.svg"),
  caption: [
    SMATMUL DATAPATH 4x4 12
  ]
)

#pagebreak()
