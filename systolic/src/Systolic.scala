package org.chipsalliance.systolic

import chisel3._
import chisel3.experimental.dataview._
import org.chipsalliance.amba.axi4
import chisel3.experimental.SerializableModule
import chisel3.experimental.SerializableModuleParameter
import chisel3.experimental.BundleLiterals.AddBundleLiteralConstructor
import org.chipsalliance.amba._
import chisel3.experimental.hierarchy._
import chisel3.util.DecoupledIO
import chisel3.util.ShiftRegister
import chisel3.util.Decoupled
import chisel3.util.Arbiter

object SystolicParameter {
  implicit def rwP: upickle.default.ReadWriter[SystolicParameter] =
    upickle.default.macroRW
}

case class SystolicParameter(
  useAsyncReset:   Boolean,
  idWidth:         Int,
  addrWidth:       Int,
  controlBusWidth: Int,
  arrayParameter:  SystolicArrayParameter)
    extends SerializableModuleParameter {
  require(addrWidth >= 16)
  require(controlBusWidth % 8 == 0)
}

class SystolicInterface(parameter: SystolicParameter) extends Bundle {
  val clock      = Input(Clock())
  val reset      = Input(if (parameter.useAsyncReset) AsyncReset() else Bool())
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
  val dataBus    = Flipped(
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
  val matrixSize       = parameter.arrayParameter.matrixSize
  val controlBusOffset = parameter.controlBusWidth / 8

  val ipVersion = 1.U(parameter.controlBusWidth.W)
  val ipType    = 1.U(parameter.controlBusWidth.W)

  val arrayWidth  = matrixSize.U(parameter.controlBusWidth.W)
  val arrayHeight = matrixSize.U(parameter.controlBusWidth.W)

  val inputAddr  = 0.U(parameter.controlBusWidth.W)
  val outputAddr =
    ((2 * matrixSize * matrixSize * parameter.arrayParameter.dataWidth / 8 + 0xfff) & 0xfffff000)
      .U(parameter.controlBusWidth.W)

  val control = RegInit(new Bundle {
    val enable = Bool()
    val reset  = Bool()
  }.Lit(_.enable -> false.B, _.reset -> false.B))

  val matmulMode = RegInit(new Bundle {
    val arrayMode  = Bool()
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
      (inputAddr, RegFieldDesc("inputNorthAddr", "Input data address")),
      (outputAddr, RegFieldDesc("outputSouthAddr", "Output data address"))
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

  val inputBufferDef  = Definition(new InputBuffer(parameter.arrayParameter))
  val outputBufferDef = Definition(new OutputBuffer(parameter.arrayParameter))

  val inputWestBuffer   = Instance(inputBufferDef)
  val inputNorthBuffer  = Instance(inputBufferDef)
  val outputSouthBuffer = Instance(outputBufferDef)

  // read data when both the buffers are valid
  val inputValid = inputNorthBuffer.io.sourceVec.valid && inputNorthBuffer.io.sourceVec.valid
  val systole    = RegNext(inputValid)

  systolicArray.io.clock := systole.asClock
  systolicArray.io.reset := implicitReset

  inputWestBuffer.io.clock   := implicitClock
  inputWestBuffer.io.reset   := implicitReset
  inputNorthBuffer.io.clock  := implicitClock
  inputNorthBuffer.io.reset  := implicitReset
  outputSouthBuffer.io.clock := implicitClock
  outputSouthBuffer.io.reset := implicitReset

  inputWestBuffer.io.sourceVec.ready  := inputValid
  inputNorthBuffer.io.sourceVec.ready := inputValid
  systolicArray.io.inputWest          := inputWestBuffer.io.sourceVec.bits
  systolicArray.io.inputNorth         := inputNorthBuffer.io.sourceVec.bits

  // all results will be produced after (2*M-1) + (M-1) cycles
  outputSouthBuffer.io.resultVec.valid := ShiftRegister(inputValid, 3 * matrixSize - 2, systole)
  outputSouthBuffer.io.resultVec.bits  := systolicArray.io.outputSouth

  def mapInputFields(buffer: Vec[Vec[DecoupledIO[UInt]]], direction: String) =
    Seq.tabulate(matrixSize, matrixSize) { case (row, col) =>
      RegField.w(
        parameter.arrayParameter.dataWidth,
        buffer(row)(col),
        RegFieldDesc(
          s"input${direction}_${row}_${col}",
          s"${row + 1}-th row and ${col + 1}-th column input data from ${direction}"
        )
      )
    }

  RegMapper.regmap(
    io.dataBus.viewAs[axi4.bundle.AXI4RWIrrevocable],
    0,
    false,
    inputAddr.litValue.toInt  ->
      // interleaving
      mapInputFields(inputWestBuffer.io.matrixIn, "West").flatten
        .zip(mapInputFields(inputNorthBuffer.io.matrixIn, "North").transpose.flatten)
        .flatMap(x => Seq(x._1) ++ Seq(x._2)),
    outputAddr.litValue.toInt -> Seq
      .tabulate(matrixSize, matrixSize) { case (row, col) =>
        RegField.r(
          parameter.arrayParameter.dataWidth,
          VecInit(outputSouthBuffer.io.matrixOut(row)(col), outputSouthBuffer.io.matrixOut(col)(row))(
            matmulMode.transposed.asUInt
          ),
          RegFieldDesc(
            s"output_${row}_${col}",
            s"${row + 1}-th row and ${col + 1}-th column output data"
          )
        )
      }
      .flatten
  )
}
