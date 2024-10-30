package org.chipsalliance.systolic

import chisel3._
import chisel3.util._
import chisel3.experimental.SerializableModule
import chisel3.experimental.hierarchy.Instantiate
import scala.util.chaining._
import org.chipsalliance.dwbb.stdlib.queue.{Queue, QueueIO}

object MatrixInterface {
  def apply(parameter: SystolicArrayParameter) =
    Vec(parameter.matrixSize, Vec(parameter.matrixSize, Decoupled(UInt(parameter.dataWidth.W))))
}

object MatrixBuffer {
  def apply(parameter: SystolicArrayParameter) = Wire(
    Vec(
      parameter.matrixSize,
      new QueueIO(new DataElement(parameter), parameter.bufferSize)
    )
  ).tap {
    _.foreach { queue =>
      queue <> Queue.io(chiselTypeOf(queue.enq.bits), parameter.bufferSize, flow = true)
    }
  }
}

class InputBufferInterface(parameter: SystolicArrayParameter) extends Bundle {
  val clock     = Input(Clock())
  val reset     = Input(if (parameter.useAsyncReset) AsyncReset() else Bool())
  val matrixIn  = Flipped(MatrixInterface(parameter))
  // output streamingly to systolic array
  val sourceVec = Decoupled(DataVec(parameter))
}

class InputBuffer(val parameter: SystolicArrayParameter)
    extends FixedIORawModule(new InputBufferInterface(parameter))
    with SerializableModule[SystolicArrayParameter]
    with ImplicitClock
    with ImplicitReset {
  override protected def implicitClock: Clock = io.clock
  override protected def implicitReset: Reset = io.reset

  val buffer = MatrixBuffer(parameter)

  // reset
  val resetCounter = RegInit(1.U(log2Ceil(parameter.matrixSize).W))
  val inReset      = resetCounter =/= 0.U
  resetCounter := Mux(inReset, resetCounter + 1.U, 0.U)

  // scan input and write to buffer
  val writePtr = RegInit(VecInit.fill(parameter.matrixSize)(0.U(log2Ceil(parameter.matrixSize).W)))

  buffer.zip(io.matrixIn).zip(writePtr).zipWithIndex.foreach { case (((queue, line), ptr), i) =>
    line.zipWithIndex.foreach { case (element, j) =>
      element.ready := Mux(ptr === j.U, queue.enq.ready, false.B)
    }
    val in = line(ptr)
    ptr := Mux(in.fire, Mux(ptr === (parameter.bufferSize - 1).U, 0.U, ptr + 1.U), ptr)

    queue.enq.valid          := Mux(inReset, i.U >= resetCounter, in.fire)
    queue.enq.bits.data      := in.bits
    queue.enq.bits.tag.valid := in.fire
  }

  // read a row from buffer
  io.sourceVec.valid := buffer.map(_.deq.valid).reduce(_ && _)
  io.sourceVec.bits.zip(buffer).foreach { case (element, queue) =>
    queue.deq.ready := Mux(inReset, false.B, io.sourceVec.ready)
    element         := Mux(buffer.map(_.deq.fire).reduce(_ && _), queue.deq.bits, 0.U.asTypeOf(element))
  }
}

class OutputBufferInterface(parameter: SystolicArrayParameter) extends Bundle {
  val clock     = Input(Clock())
  val reset     = Input(if (parameter.useAsyncReset) AsyncReset() else Bool())
  val resultVec = Flipped(Decoupled(DataVec(parameter)))
  val matrixOut = MatrixInterface(parameter)
}

class OutputBuffer(val parameter: SystolicArrayParameter)
    extends FixedIORawModule(new OutputBufferInterface(parameter))
    with SerializableModule[SystolicArrayParameter]
    with ImplicitClock
    with ImplicitReset {
  override protected def implicitClock: Clock = io.clock
  override protected def implicitReset: Reset = io.reset

  val buffer = MatrixBuffer(parameter)

}
