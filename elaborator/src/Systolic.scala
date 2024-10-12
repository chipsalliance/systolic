// SPDX-License-Identifier: Unlicense
// SPDX-FileCopyrightText: 2024 Jiuyang Liu <liu@jiuyang.me>
package org.chipsalliance.systolic.elaborator

import mainargs._
import org.chipsalliance.systolic._
import chisel3.experimental.util.SerializableModuleElaborator

object SystolicMain extends SerializableModuleElaborator {
  val topName = "Systolic"

  implicit object PathRead extends TokensReader.Simple[os.Path] {
    def shortName = "path"
    def read(strs: Seq[String]) = Right(os.Path(strs.head, os.pwd))
  }

  @main
  case class SystolicParameterMain(
    @arg(name = "useAsyncReset") useAsyncReset:     Boolean,
    @arg(name = "idWidth") idWidth:                 Int,
    @arg(name = "addrWidth") addrWidth:             Int,
    @arg(name = "controlBusWidth") controlBusWidth: Int,
    @arg(name = "matrixSize") matrixSize:           Int) {
    def convert =
      SystolicParameter(
        useAsyncReset,
        idWidth,
        addrWidth,
        controlBusWidth,
        matrixSize,
        SystolicArrayParameter(useAsyncReset, 32)
      )
  }

  implicit def SystolicParameterMainParser: ParserForClass[SystolicParameterMain] =
    ParserForClass[SystolicParameterMain]

  @main
  def config(
    @arg(name = "parameter") parameter:  SystolicParameterMain,
    @arg(name = "target-dir") targetDir: os.Path = os.pwd
  ) =
    os.write.over(targetDir / s"${topName}.json", configImpl(parameter.convert))

  @main
  def design(
    @arg(name = "parameter") parameter:  os.Path,
    @arg(name = "target-dir") targetDir: os.Path = os.pwd
  ) = {
    val (firrtl, annos) = designImpl[Systolic, SystolicParameter](os.read.stream(parameter))
    os.write.over(targetDir / s"${topName}.fir", firrtl)
    os.write.over(targetDir / s"${topName}.anno.json", annos)
  }

  def main(args: Array[String]): Unit = ParserForMethods(this).runOrExit(args)
}
