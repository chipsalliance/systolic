package org.chipsalliance.systolic

import chisel3._
import chisel3.experimental.SerializableModule
import chisel3.experimental.SerializableModuleParameter

object SystolicArrayParameter {
  implicit def rwP: upickle.default.ReadWriter[SystolicArrayParameter] =
    upickle.default.macroRW
}

case class SystolicArrayParameter(
  useAsyncReset: Boolean,
  matrixSize:    Int,
  dataWidth:     Int)
    extends SerializableModuleParameter {
  require(matrixSize >= 4 && matrixSize <= 256)
  require(dataWidth == 32)

  val bufferSize = 2 * matrixSize - 1
}

class ElementTag(parameter: SystolicArrayParameter) extends Bundle {
  val valid = Bool()
}

class DataElement(parameter: SystolicArrayParameter) extends Bundle {
  val data = UInt(parameter.dataWidth.W)
  val tag  = new ElementTag(parameter)
}

object DataVec {
  def apply(parameter: SystolicArrayParameter) = Vec(parameter.matrixSize, new DataElement(parameter))
}

class SystolicArrayInterface(parameter: SystolicArrayParameter) extends Bundle {
  val clock       = Input(Clock())
  val reset       = Input(if (parameter.useAsyncReset) AsyncReset() else Bool())
  val inputNorth  = Input(DataVec(parameter))
  val inputWest   = Input(DataVec(parameter))
  val outputSouth = Output(DataVec(parameter))
  val outputEast  = Output(DataVec(parameter))
}

class SystolicArray(val parameter: SystolicArrayParameter)
    extends FixedIORawModule(new SystolicArrayInterface(parameter))
    with SerializableModule[SystolicArrayParameter]
    with ImplicitClock
    with ImplicitReset {
  override protected def implicitClock: Clock = io.clock
  override protected def implicitReset: Reset = io.reset

  io.outputSouth := io.inputNorth
  io.outputEast  := io.inputWest
}
