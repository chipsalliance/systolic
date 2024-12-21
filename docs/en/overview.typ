= OVERVIEW
<overview>
The matrix multiplication accelerator is designed as a Memory-Mapped I/O
(MMIO) device with an AXI slave interface, incorporating control,
status, and data input/output registers. The core of this accelerator is
a systolic array, which is configurable from sizes ranging between 4x4
and 256x256, providing scalability based on the application
requirements.

This accelerator facilitates the acceleration of matrix multiplication
operations, a fundamental computational task in many high-performance
applications such as deep learning and scientific computing. The
systolic array architecture is specifically chosen for its efficiency in
handling large-scale matrix operations, as it allows for high throughput
and low-latency computation by leveraging the parallel processing
capabilities inherent in the systolic design.

The operation of the accelerator is managed via control registers, where
users can configure the systolic array’s mode, initiate operations, and
control data flow. Input data is fed into the systolic array through the
data input registers, and the results are retrieved via the data output
registers. Status registers provide real-time feedback on the progress
and completion of operations, enabling efficient monitoring and
management of the computation process.

By offloading matrix multiplication tasks to this accelerator, the
computational burden on the main processor is significantly reduced,
allowing it to focus on other tasks, thereby improving the overall
system performance. This MMIO-based design also simplifies the
integration of the accelerator into existing systems, ensuring
compatibility and ease of use.

== TERMINOLOGY
<terminology>
The following terms are used in system descriptions.

#figure(
  align(center)[#table(
    columns: (0.25fr, 1fr),
    align: (auto,auto,),
    table.header([Terminology], [Description],),
    table.hline(),
    [MATMUL], [Matrix multiplication, often denoted as matmul],
    [DMATMUL], [Dynamic Matrix Multiplication],
    [SMATMUL], [Static Matrix Multiplication],
    [GEMM], [General matrix multiplication],
    [CONV], [Convolution operation, commonly used in CNNs],
    [IM2COL], [Image to column transformation for convolution],
  )]
  , caption: [TERMINOLOGY OF SYSTEM]
  , kind: table
  )

The following terms are used in register descriptions.

#figure(
  align(center)[#table(
    columns: (16.18%, 83.82%),
    align: (auto,auto,),
    table.header([Terminology], [Description],),
    table.hline(),
    [RO], [W: no effect, R: no effect],
    [RW], [W: as-is, R: no effect],
    [RC], [W: no effect, R: clears all bits],
    [RS], [W: no effect, R: sets all bits],
    [WRC], [W: as-is, R: clears all bits],
    [WRS], [W: as-is, R: sets all bits],
    [WC], [W: clears all bits, R: no effect],
    [WS], [W: sets all bits, R: no effect],
    [WSRC], [W: sets all bits, R: clears all bits],
    [WCRS], [W: clears all bits, R: sets all bits],
    [W1C], [W: 1/0 clears/no effect on matching bit, R: no effect],
    [W1S], [W: 1/0 sets/no effect on matching bit, R: no effect],
    [W1T], [W: 1/0 toggles/no effect on matching bit, R: no effect],
    [W0C], [W: 1/0 no effect on/clears matching bit, R: no effect],
    [W0S], [W: 1/0 no effect on/sets matching bit, R: no effect],
    [W0T], [W: 1/0 no effect on/toggles matching bit, R: no effect],
    [W1SRC], [W: 1/0 sets/no effect on matching bit, R: clears all
    bits],
    [W1CRS], [W: 1/0 clears/no effect on matching bit, R: sets all
    bits],
    [W0SRC], [W: 1/0 no effect on/sets matching bit, R: clears all
    bits],
    [W0CRS], [W: 1/0 no effect on/clears matching bit, R: sets all
    bits],
    [WO], [W: as-is, R: error],
    [WOC], [W: clears all bits, R: error],
    [WOS], [W: sets all bits, R: error],
    [W1], [W: keep first W after HARD reset, R: no effect],
    [WO1], [W: keep first W after HARD reset, R: error],
  )]
  , caption: [TERMINOLOGY OF REGISTERS]
  , kind: table
  )

== MATMUL
<matmul>
The MATMUL unit is mainly used for general matrix multiplication (GEMM).

#quote(block: true)[
MATMUL is suitable for matrix computations. However, if you want to use
MATMUL to compute convolutions, an additional IM2COL operation needs to
be performed externally, which will consume extra storage space, data
rearrangement time, and lead to IO wait. Therefore, it is recommended to
use implicit GEMM convolution.
]

#pagebreak()
