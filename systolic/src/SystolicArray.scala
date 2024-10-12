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
  dataWidth:     Int)
    extends SerializableModuleParameter { require(dataWidth == 32) }

class SystolicArrayInterface(parameter: SystolicArrayParameter) extends Bundle {
  val clock = Input(Clock())
  val reset = Input(if (parameter.useAsyncReset) AsyncReset() else Bool())
  val inputNorth = Input(UInt(parameter.dataWidth.W))
  val inputWest = Input(UInt(parameter.dataWidth.W))
  val outputSouth = Output(UInt(parameter.dataWidth.W))
  val outputEast = Output(UInt(parameter.dataWidth.W))
}

class SystolicArray(val parameter: SystolicArrayParameter)
    extends FixedIORawModule(new SystolicArrayInterface(parameter))
    with SerializableModule[SystolicArrayParameter]
    with ImplicitClock
    with ImplicitReset {
  override protected def implicitClock: Clock = io.clock
  override protected def implicitReset: Reset = io.reset

  io.outputSouth := io.inputNorth
  io.outputEast := io.inputWest
}
