#import "datasheet.typ": datasheet

#datasheet(
  metadata: (
    organization: [CHIPS Alliance],
    logo: "./images/chips_alliance.svg",
    website_url: "https://www.chipsalliance.org",
    title: [Systolic MATMUL],
    product: [Systolic MATMUL],
    product_url: "https://github.com/chipsalliance/systolic",
    revision: [v1.0.0],
    publish_date: [2024-12-21],
  ),
  features: [
    - Configurable systolic array sizes from 4x4 to 256x256
    - High throughput and low-latency computation
    - Memory-Mapped I/O (MMIO) design with AXI slave interface
    - Integrated control, status, and data input/output registers
    - Scalable and efficient architecture for matrix multiplication
    - Optimized for deep learning and scientific computing applications
    - Easy integration with existing systems
    - Low power consumption suitable for edge and embedded systems
  ],
  applications: [
    - Artificial Intelligence (AI) acceleration
    - Machine Learning (ML) model training and inference
    - High-performance scientific computing
    - Real-time image and video processing
    - Signal processing and communications systems
    - Edge computing and IoT devices
    - Autonomous systems and robotics
    - High-performance data centers
  ],
  description: [
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
    handling large-scale matrix operations, allowing for high throughput and
    low-latency computation through parallel processing.

    The operation of the accelerator is managed via control registers, where
    users can configure the array's mode, initiate operations, and control
    data flow. Input data is fed through data registers, and results are
    retrieved via output registers. Status registers provide feedback on
    operation progress and completion.

    By offloading matrix multiplication tasks to this accelerator, the
    computational burden on the main processor is significantly reduced,
    improving overall system performance. This MMIO-based design also
    simplifies integration into existing systems, ensuring compatibility.
  ],
  document: [
    #include "about.typ"
    #include "overview.typ"
    #include "system.typ"
    #include "registers.typ"
    #include "datapath.typ"
  ],
  backcover: [
    #align(center)[
      #heading(level: 1, outlined: false)[ACKNOWLEDGEMENTS]
    ]

    Thank you for your interest in the Systolic MATMUL IP. We value your time spent reviewing this document and welcome your valuable feedback and suggestions for improvement. Your insights are crucial to the continued development and refinement of this technology. Please feel free to share your comments through our project repository or contact channels.
  ]
)
