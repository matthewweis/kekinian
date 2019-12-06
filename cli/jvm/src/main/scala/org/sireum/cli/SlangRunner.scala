/*
 Copyright (c) 2019, Robby, Kansas State University
 All rights reserved.

 Redistribution and use in source and binary forms, with or without
 modification, are permitted provided that the following conditions are met:

 1. Redistributions of source code must retain the above copyright notice, this
    list of conditions and the following disclaimer.
 2. Redistributions in binary form must reproduce the above copyright notice,
    this list of conditions and the following disclaimer in the documentation
    and/or other materials provided with the distribution.

 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR
 ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

package org.sireum.cli

import org.sireum._
import org.sireum.Cli._
import org.sireum.Sireum._
import org.sireum.eprintln

object SlangRunner {

  val HomeNotFound: Z = -1
  val NativeUnavailable: Z = -2
  val InvalidOutput: Z = -3
  val GraalError: Z = -4

  def run(o: SlangRunOption): Z = {
    if (o.args.isEmpty) {
      println(o.help)
      println()
      return 0
    }
    val scalaExe: Os.Path = scalaHomeOpt match {
      case Some(scalaHome) => scalaHome / "bin" / (if (Os.isWin) "scala.bat" else "scala")
      case _ => Os.Path.Impl(if (Os.isWin) "scala.bat" else "scala")
    }
    val inputOpt = path2fileOpt("input", o.input, T)
    var outputOpt: Option[Os.Path] = None()
    val isConsole: B =
      path2fileOpt("output", o.output, F) match {
        case Some(path) =>
          outputOpt = Some(path)
          if (path == Os.Path.Kind.Dir) {
            eprintln(s"Output $path cannot be a directory")
            eprintln()
            return InvalidOutput
          } else {
            val d = path.up
            if (!d.exists) {
              d.mkdirAll()
            }
            if (!d.exists) {
              eprintln(s"Could not create parent directory of $path")
              eprintln()
              return InvalidOutput
            } else {
              F
            }
          }
        case _ => T
      }
    val script = path2fileOpt("Slang script", Some(o.args(0).value), T).get
    val wd = script.up
    val sJar: Os.Path =
      if (Os.isWin && (sireumJar.up / ".sireum-win.jar").exists) sireumJar.up / ".sireum-win.jar"
      else sireumJar
    var command: ISZ[String] = ISZ(
      scalaExe.string,
      "-bootclasspath",
      sJar.string,
      s"-Xplugin:$scalacPluginJar",
      "-classpath",
      s"$wd${Os.pathSep}$sJar",
      "-sourcepath",
      wd.string,
      "-unchecked",
      "-feature",
      "-howtorun:script"
    )
    if (o.nativ) {
      command = command :+ "-save"
    }
    if (o.transformed) {
      command = command :+ "-Xprint:sireum"
    }
    if (o.server) {
      command = command :+ "-nc"
    }
    command = command :+ script.string
    for (i <- 1 until o.args.size) {
      command :+= o.args(i)
    }
    val inOpt: Option[String] = inputOpt match {
      case Some(f) => Some(f.read)
      case _ =>
        val p = wd / s"${script.name}.txt"
        if (p.exists) Some(p.read) else None()
    }
    val jarFile = wd / s"${script.name}.jar"
    var env = ISZ("SLASH_DIR" ~> wd.string)
    val nativeImage: Os.Path = {
      val niName: String = if (Os.isWin) "native-image.cmd" else "native-image"
      homeOpt match {
        case Some(home) =>
          val p = home / "bin" / platform / "graal" / "bin" / niName
          if (p.isFile) p else Os.path(niName)
        case _ => Os.path(niName)
      }
    }
    scalaHomeOpt match {
      case Some(scalaHome) => env = env :+ "SCALA_HOME" ~> scalaHome.string
      case _ =>
    }
    var p = Os.proc(command).at(Os.cwd).env(env)
    if (jarFile.exists) {
      jarFile.removeOnExit()
    }
    if (isConsole) {
      p = p.console
    } else {
      p = p.redirectErr
    }
    inOpt match {
      case Some(in) => p.input(in)
      case _ =>
    }
    var r = p.runCheck()
    outputOpt match {
      case Some(path) => path.writeOver(r.out)
      case _ =>
    }
    if (o.nativ) {
      val nativeName = s"${script.name}.com"
      val nativ = wd / nativeName
      if (nativ.exists && nativ.lastModified > script.lastModified) {
        return 0
      }
      r = Os.proc(ISZ(nativeImage.string, "--version")).env(env).standard.run()
      if (!(r.ok && ops.StringOps(r.out).contains("GraalVM"))) {
        return 0
      }
      println(s"Generating native image $nativ ...")
      val flags: ISZ[String] = Os.kind match {
        case Os.Kind.Mac => ISZ("--no-server")
        case Os.Kind.Linux => ISZ("--no-server", "--static")
        case Os.Kind.Win => ISZ("--static")
        case _ => return 0
      }
      command = (nativeImage.string +: flags) ++ ISZ("--initialize-at-build-time",
        "--no-fallback", "-cp", sJar.string, "-jar", jarFile.name, nativeName)
      r = Os.proc(command).at(jarFile.up).console.bufferErr.run()
      if (r.exitCode != 0) {
        for (line <- ops.StringOps(r.err).split((c: C) => c === '\n') if !ops.StringOps(line).startsWith("warning: unknown anonymous info")) {
          eprintln(line)
        }
      }
      for (f <- wd.list if ops.StringOps(f.name).startsWith(s"$nativeName.") && !ops.StringOps(f.name).endsWith(".exe")) {
        f.removeAll()
      }
      (wd / s"$nativeName.o").removeAll()
      if ((wd / s"$nativeName.exe").exists) {
        (wd / s"$nativeName.exe").moveOverTo(wd / nativeName)
      }
      if ((wd / s"${script.name}.jar").exists) {
        (wd / s"${script.name}.jar").removeAll()
      }
      if (r.ok) {
        return 0
      } else {
        (wd / s"$nativeName.exe").removeAll()
        eprintln(s"Failed to generate native executable $nativ, exit code: ${r.exitCode}")
        eprint(r.err)
        return GraalError
      }
    } else {
      return 0
    }
  }
}
