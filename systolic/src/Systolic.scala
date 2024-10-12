package org.chipsalliance.systolic

import chisel3._
import chisel3.experimental.dataview._
import org.chipsalliance.amba.axi4
import chisel3.experimental.SerializableModule
import chisel3.experimental.SerializableModuleParameter
import chisel3.experimental.BundleLiterals.AddBundleLiteralConstructor
import org.chipsalliance.amba._
import chisel3.experimental.hierarchy.Instantiate
import chisel3.experimental.hierarchy.Instance

object SystolicParameter {
  implicit def rwP: upickle.default.ReadWriter[SystolicParameter] =
    upickle.default.macroRW
}

case class SystolicParameter(
  useAsyncReset:   Boolean,
  idWidth:         Int,
  addrWidth:       Int,
  controlBusWidth: Int,
  matrixSize:      Int,
  arrayParameter:  SystolicArrayParameter)
    extends SerializableModuleParameter {
  require(addrWidth >= 16)
  require(matrixSize >= 4 && matrixSize <= 256)
  require(controlBusWidth % 8 == 0)
}

class SystolicInterface(parameter: SystolicParameter) extends Bundle {
  val clock = Input(Clock())
  val reset = Input(if (parameter.useAsyncReset) AsyncReset() else Bool())
  val controlBus = Flipped(
    axi4.bundle.verilog
      .irrevocable(
        axi4.bundle
          .AXI4BundleParameter(
            idWidth = parameter.idWidth,
            dataWidth = parameter.controlBusWidth,
            addrWidth = parameter.addrWidth,
            userReqWidth = 0,
            userDataWidth = 0,
            userRespWidth = 0,
            hasAW = true,
            hasW = true,
            hasAR = true,
            hasR = true,
            hasB = true,
            supportId = true,
            supportRegion = false,
            supportLen = true,
            supportSize = true,
            supportBurst = true,
            supportLock = false,
            supportCache = false,
            supportQos = false,
            supportStrb = true,
            supportResp = false,
            supportProt = false
          )
      )
      .asInstanceOf[axi4.bundle.AXI4RWIrrevocableVerilog]
  )
  val dataBus = Flipped(
    axi4.bundle.verilog
      .irrevocable(
        axi4.bundle.AXI4BundleParameter(
          idWidth = parameter.idWidth,
          dataWidth = parameter.arrayParameter.dataWidth,
          addrWidth = parameter.addrWidth,
          userReqWidth = 0,
          userDataWidth = 0,
          userRespWidth = 0,
          hasAW = true,
          hasW = true,
          hasAR = true,
          hasR = true,
          hasB = true,
          supportId = true,
          supportRegion = false,
          supportLen = true,
          supportSize = true,
          supportBurst = true,
          supportLock = false,
          supportCache = false,
          supportQos = false,
          supportStrb = true,
          supportResp = false,
          supportProt = false
        )
      )
      .asInstanceOf[axi4.bundle.AXI4RWIrrevocableVerilog]
  )
}

class Systolic(val parameter: SystolicParameter)
    extends FixedIORawModule(new SystolicInterface(parameter))
    with SerializableModule[SystolicParameter]
    with ImplicitClock
    with ImplicitReset {
  import org.chipsalliance.amba.axi4.bundle.rwV2C

  override protected def implicitClock: Clock = io.clock
  override protected def implicitReset: Reset = io.reset

  // control bus
  val controlBusOffset = parameter.controlBusWidth / 8

  val ipVersion = 1.U(parameter.controlBusWidth.W)
  val ipType = 1.U(parameter.controlBusWidth.W)

  val arrayWidth = parameter.matrixSize.U(parameter.controlBusWidth.W)
  val arrayHeight = parameter.matrixSize.U(parameter.controlBusWidth.W)

  val Seq(inputNorthAddr, inputWestAddr, outputSouthAddr, outputEastAddr) =
    Seq.tabulate(4)(i => ((i * ((parameter.matrixSize + 0xfff) & 0xfffff000)).U(parameter.controlBusWidth.W)))

  val control = RegInit(new Bundle {
    val enable = Bool()
    val reset = Bool()
  }.Lit(_.enable -> false.B, _.reset -> false.B))

  val matmulMode = RegInit(new Bundle {
    val arrayMode = Bool()
    val transposed = Bool()
  }.Lit(_.arrayMode -> false.B, _.transposed -> false.B))

  RegMapper.regmap(
    io.controlBus.viewAs[axi4.bundle.AXI4RWIrrevocable],
    0,
    false,
    Seq(
      (ipVersion, RegFieldDesc("version", "IP version")),
      (ipType, RegFieldDesc("type", "IP type")),
      (arrayWidth, RegFieldDesc("arrayWidth", "Systolic array width")),
      (arrayHeight, RegFieldDesc("arrayHeight", "Systolic array height")),
      (inputNorthAddr, RegFieldDesc("inputNorthAddr", "Input data from North")),
      (inputWestAddr, RegFieldDesc("inputWestAddr", "Input data from West")),
      (outputSouthAddr, RegFieldDesc("outputSouthAddr", "Output data to South")),
      (outputEastAddr, RegFieldDesc("outputEastAddr", "Output data to East"))
    ).zipWithIndex.map { case ((value, desc), i) =>
      (controlBusOffset * i -> Seq(RegField.r(parameter.controlBusWidth, RegInit(value): UInt, desc)))
    } ++ Seq(
      0x0100 + controlBusOffset * 0 -> Seq(
        RegField(1, control.enable, RegFieldDesc("enable", "Enable IP")),
        RegField.w(1, control.reset, RegFieldDesc("reset", "Reset IP"))
      ),
      0x0100 + controlBusOffset * 1 -> Seq(
        RegField(1, matmulMode.arrayMode, RegFieldDesc("arrayMode", "Mode: 0: DMATMUL, 1: SMATMUL")),
        RegField(1, matmulMode.transposed, RegFieldDesc("transposed", "Output transposed: 0: false, 1: true"))
      )
    ): _*
  )

  // data bus
  val systolicArray = Instantiate(new SystolicArray(parameter.arrayParameter))
  systolicArray.io.clock := implicitClock
  systolicArray.io.reset := implicitReset

  systolicArray.io.inputNorth := 0.U
  systolicArray.io.inputWest := 0.U

  RegMapper.regmap(
    io.dataBus.viewAs[axi4.bundle.AXI4RWIrrevocable],
    0,
    false,
    inputNorthAddr.litValue.toInt -> Seq(
      RegField.w(
        parameter.arrayParameter.dataWidth,
        systolicArray.io.inputNorth,
        RegFieldDesc("inputNorth", "Input data from North")
      )
    ),
    inputWestAddr.litValue.toInt -> Seq(
      RegField.w(
        parameter.arrayParameter.dataWidth,
        systolicArray.io.inputWest,
        RegFieldDesc("inputWest", "Input data from West")
      )
    ),
    outputSouthAddr.litValue.toInt -> Seq(
      RegField.r(
        parameter.arrayParameter.dataWidth,
        systolicArray.io.outputSouth,
        RegFieldDesc("outputSouth", "Output data to South")
      )
    ),
    outputEastAddr.litValue.toInt -> Seq(
      RegField.r(
        parameter.arrayParameter.dataWidth,
        systolicArray.io.outputEast,
        RegFieldDesc("outputEast", "Output data to East")
      )
    )
  )
}
