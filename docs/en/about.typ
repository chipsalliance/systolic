= About This Guide
<about>
This MATMUL architecture includes the ability to configure certain matrix
operations to efficiently utilize hardware resources, managed by the MATMUL
controller. Essentially, this feature allows us to perform matrix multiplication
with optimized data flow and storage, enabling dynamic or static configurations
for different computational scenarios.

The MATMUL controller can independently manage various aspects of matrix
operations, such as input buffering, output buffering, data padding, scheduling
of systolic array units, partial sum accumulation, precision control, data
format conversion, and overflow/underflow handling. It can also be integrated
into general-purpose computation workflows in some scenarios.

== Disclaimer
<disclaimer>
Information in this document, including URL references, is subject to change
without notice. *This document is provided as is with no warranties whatsoever,
including any warranty of merchantability, non-infringement, fitness for any
particular purpose, or any warranty otherwise arising out of any proposal,
specification or sample.*

All liability, including liability for infringement of any proprietary rights,
relating to use of information in this document is disclaimed. No licenses
express or implied, by estoppel or otherwise, to any intellectual property
rights are granted herein.

All trade names, trademarks, and registered trademarks mentioned in this
document are property of their respective owners, and are hereby acknowledged.

== Revision History

#figure(
  align(center)[#table(
    columns: (0.25fr, 0.25fr,0.25fr, 1fr),
    align: (auto,auto,auto,auto,),
    table.header([Revision], [Date], [Author], [Description],),
    table.hline(),
    [1.0.0], [2024-12-21], [Huang Rui], [Initial release of systolic MATMUL],
  )]
  , kind: table
  )

#pagebreak()
