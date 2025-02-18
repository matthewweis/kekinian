::/*#! 2> /dev/null                                                                                         #
@ 2>/dev/null # 2>nul & echo off & goto BOF                                                                 #
export SIREUM_HOME=$(cd -P $(dirname "$0")/.. && pwd -P)                                                    #
if [ ! -z ${SIREUM_PROVIDED_SCALA++} ]; then                                                                #
  SIREUM_PROVIDED_JAVA=true                                                                                 #
fi                                                                                                          #
"${SIREUM_HOME}/bin/init.sh" || exit $?                                                                     #
if [ -n "$COMSPEC" -a -x "$COMSPEC" ]; then                                                                 #
  export SIREUM_HOME=$(cygpath -C OEM -w -a ${SIREUM_HOME})                                                 #
  if [ -z ${SIREUM_PROVIDED_JAVA++} ]; then                                                                 #
    export PATH="${SIREUM_HOME}/bin/win/java":"${SIREUM_HOME}/bin/win/z3":"$PATH"                           #
    export PATH="$(cygpath -C OEM -w -a ${JAVA_HOME}/bin)":"$(cygpath -C OEM -w -a ${Z3_HOME}/bin)":"$PATH" #
  fi                                                                                                        #
elif [ "$(uname)" = "Darwin" ]; then                                                                        #
  if [ -z ${SIREUM_PROVIDED_JAVA++} ]; then                                                                 #
    export PATH="${SIREUM_HOME}/bin/mac/java/bin":"${SIREUM_HOME}/bin/mac/z3/bin":"$PATH"                   #
  fi                                                                                                        #
elif [ "$(expr substr $(uname -s) 1 5)" = "Linux" ]; then                                                   #
  if [ -z ${SIREUM_PROVIDED_JAVA++} ]; then                                                                 #
    if [ "$(uname -m)" = "aarch64" ]; then                                                                  #
      export PATH="${SIREUM_HOME}/bin/linux/arm/java/bin":"$PATH"                                           #
    else                                                                                                    #
      export PATH="${SIREUM_HOME}/bin/linux/java/bin":"${SIREUM_HOME}/bin/linux/z3/bin":"$PATH"             #
    fi                                                                                                      #
  fi                                                                                                        #
fi                                                                                                          #
if [ -f "$0.com" ] && [ "$0.com" -nt "$0" ]; then                                                           #
  exec "$0.com" "$@"                                                                                        #
else                                                                                                        #
  rm -fR "$0.com"                                                                                           #
  exec "${SIREUM_HOME}/bin/sireum" slang run -n "$0" "$@"                                                   #
fi                                                                                                          #
:BOF
setlocal
set SIREUM_HOME=%~dp0../
call "%~dp0init.bat" || exit /B %errorlevel%
if defined SIREUM_PROVIDED_SCALA set SIREUM_PROVIDED_JAVA=true
if not defined SIREUM_PROVIDED_JAVA set PATH=%~dp0win\java\bin;%~dp0win\z3\bin;%PATH%
set NEWER=False
if exist %~dpnx0.com for /f %%i in ('powershell -noprofile -executionpolicy bypass -command "(Get-Item %~dpnx0.com).LastWriteTime -gt (Get-Item %~dpnx0).LastWriteTime"') do @set NEWER=%%i
if "%NEWER%" == "True" goto native
del "%~dpnx0.com" > nul 2>&1
"%~dp0sireum.bat" slang run -n "%0" %*
exit /B %errorlevel%
:native
%~dpnx0.com %*
exit /B %errorlevel%
::!#*/
// #Sireum

import org.sireum._
import org.sireum.project.DependencyManager

def usage(): Unit = {
  println(
    st"""Sireum /build
        |Usage: ( setup[-ultimate  | -server]          | project[-ultimate | -server]
        |       | jar              | fresh             | uber
        |       | tipe             | compile[-js]      | native
        |       | test             | verify            | test-verify
        |       | regen-project    | regen-presentasi  | regen-slang
        |       | regen-logika     | regen-air         | regen-act
        |       | regen-slang-ll2  | regen-parser      | regen-parser-antlr3
        |       | regen-server     | regen-cliopt      | regen-cli
        |       | regen-fmide-cli  | regen-json        | regen-slang-tt
        |       | alt-ergo-open    | cvc               | z3
        |       | mill             | jitpack           | ghpack
        |       | m2[-lib[-js]]    | ram
        |       | distro ( --linux | --linux-arm       | --mac             | --win
        |                | --sfx   | --ultimate        | --server                  )*  )*
        |""".render)
}

val proyekName: String = "sireum-proyek"
val jarName: String = "sireum"

object Versions {

  val homeBin: Os.Path = Os.slashDir
  val home: Os.Path = homeBin.up.canon

  @memoize def versions: Map[String, String] = {
    return (home / "versions.properties").properties
  }
}

import Versions._

val sireumJar = homeBin / s"$jarName.jar"
val sireum = homeBin / (if (Os.isWin) "sireum.bat" else "sireum")

def platformKind(kind: Os.Kind.Type): String = {
  kind match {
    case Os.Kind.Win => return "win"
    case Os.Kind.Linux => return "linux"
    case Os.Kind.LinuxArm => return "linux/arm"
    case Os.Kind.Mac => return "mac"
    case _ => return "unsupported"
  }
}

def platform: String = {
  return platformKind(Os.kind)
}

def installZ3(kind: Os.Kind.Type): Unit = {
  Init(home, kind, versions).installZ3()
}


def z3(): Unit = {
  println("Installing Z3 for macOS ...")
  println()
  installZ3(Os.Kind.Mac)
  println()

  println("Installing Z3 for Linux ...")
  println()
  installZ3(Os.Kind.Linux)
  println()

  println("Installing Z3 for Windows ...")
  println()
  installZ3(Os.Kind.Win)
  println()
}


def installCVC(kind: Os.Kind.Type): Unit = {
  Init(home, kind, versions).installCVC()
}


def cvc(): Unit = {
  println("Installing CVC for macOS ...")
  println()
  installCVC(Os.Kind.Mac)
  println()

  println("Installing CVC for Linux ...")
  println()
  installCVC(Os.Kind.Linux)
  println()

  println("Installing CVC for Windows ...")
  println()
  installCVC(Os.Kind.Win)
  println()
}


def installAltErgoOpen(kind: Os.Kind.Type): Unit = {
  Init(home, kind, versions).installAltErgoOpen()
}


def altErgoOpen(): Unit = {
  println("Installing Alt-Ergo for macOS ...")
  println()
  installAltErgoOpen(Os.Kind.Mac)
  println()

  println("Installing Alt-Ergo for Linux ...")
  println()
  installAltErgoOpen(Os.Kind.Linux)
  println()
}


def buildMill(): Unit = {
  def copyIfNewer(from: Os.Path, to: Os.Path): Unit = {
    if (!to.exists || from.lastModified > to.lastModified) {
      from.copyOverTo(to)
    }
  }

  def symlink(p: Os.Path, target: Os.Path): Unit = {
    if (Os.isWin) {
      copyIfNewer(target, p)
    } else if (!p.isSymLink) {
      if (p.exists) {
        p.removeAll()
      }
      p.up.mkdirAll()
      p.mklink(target)
    }
  }

  val millBuild = home / "mill"
  if (millBuild.exists) {
    proc"git pull".at(millBuild).console.runCheck()
  } else {
    proc"git clone https://github.com/sireum/mill ${millBuild.name}".at(home).console.runCheck()
  }
  symlink(millBuild / "versions.properties", home / "versions.properties")
  val millBuildBin = millBuild / "bin"
  symlink(millBuildBin / sireumJar.name, homeBin / sireumJar.name)
  symlink(millBuildBin / sireum.name, sireum)
  symlink(millBuildBin / "scala", homeBin / "scala")
  symlink(millBuildBin / "prelude.sh", homeBin / "init.sh")
  symlink(millBuildBin / "prelude.ps1", homeBin / "init.ps1")
  val millBuildBinPlatform = millBuildBin / platform
  symlink(millBuildBinPlatform / "java", homeBin / platform / "java")
  if ((homeBin / platform / "z3").exists) {
    symlink(millBuildBinPlatform / "z3", homeBin / platform / "z3")
  }
  val millBuildLib = millBuild / "lib"
  for (p <- (home / "lib").list) {
    symlink(millBuildLib / p.name, p)
  }
  val homeBinMill = homeBin / "mill"
  val homeBinMillBat = homeBin / "mill.bat"
  (millBuildBin / "build.cmd").slash(ISZ())
  copyIfNewer(millBuild / "mill-standalone", homeBinMill)
  copyIfNewer(millBuild / "mill-standalone.bat", homeBinMillBat)
}


def build(fresh: B, isNative: B, isUber: B): Unit = {
  println("Building ...")

  val recompile: String = if (fresh) {
    " -f"
  } else {
    var r: String = ""
    val pr = proc"git status --porcelain".at(home).run()
    if (ops.StringOps(s"${pr.out}${pr.err}").trim == "") {
      val vOutOps = ops.StringOps(proc"$sireum -v".run().out)
      if (vOutOps.contains("*") ||
        !vOutOps.contains(ops.StringOps(proc"git log -n 1 --date=format:%Y%m%d --pretty=format:4.%cd.%h".run().out).trim)) {
        r = " --recompile cli"
      }
    }
    r
  }
  val nativ: String = if (isNative) " --native" else ""
  val uber: String = if (isUber) " --uber" else ""

  val r = Sireum.proc(proc"$sireum proyek assemble -n $proyekName -j $jarName -m org.sireum.Sireum --par --sha3 --ignore-runtime --include-tests$recompile$nativ$uber $home".console,
    message.Reporter.create)
  if (r.exitCode == 0) {
    (home / "out" / proyekName / "assemble" / sireumJar.name).copyOverTo(sireumJar)
    if (isUber) {
      val uberJar = homeBin / s"${sireumJar.name}.bat"
      (home / "out" / proyekName / "assemble" / uberJar.name).copyOverTo(uberJar)
    }
    if (isNative) {
      val exePath: Os.Path = Os.kind match {
        case Os.Kind.Win => homeBin / "win" / s"$jarName.exe"
        case Os.Kind.Linux => homeBin / "linux" / jarName
        case Os.Kind.LinuxArm => homeBin / "linux" / "arm" / jarName
        case Os.Kind.Mac => homeBin / "mac" / jarName
        case _ => halt("Infeasible")
      }
      (home / "out" / proyekName / "assemble" / exePath.name).copyOverTo(exePath)
    }
  } else {
    Os.exit(r.exitCode)
  }
  println()
}


def tipe(): Unit = {
  println("Slang type checking ...")
  Os.proc(ISZ(sireum.string, "proyek", "tipe", "--par", "--strict-aliasing", home.string)).console.runCheck()
  println()
}


def compile(isJs: B): Unit = {
  tipe()
  println("Compiling ...")
  proc"$sireum proyek compile -n $proyekName --par --sha3 --ignore-runtime${if (isJs) " --js" else ""} $home".console.runCheck()
  println()
}


def test(): Unit = {
  tipe()

  println("Testing ...")
  val packageNames = ISZ[String](
    "org.sireum"
  )
  val names = ISZ[String](
    "org.sireum.lang",
    "org.sireum.tools",
    "org.sireum.logika",
    "org.sireum.proyek"
    //"org.sireum.hamr.codegen.test.expensive"
  )
  proc"$sireum proyek test -n $proyekName --par --sha3 --ignore-runtime --packages ${st"${(packageNames, ",")}".render} $home ${st"${(names, " ")}".render}".
    console.echo.runCheck()
  println()
}


def verifyRuntime(): Unit = {
  proc"$sireum proyek logika --all --par --par-branch --slice library-shared --timeout 5 --sat $home".console.echo.runCheck()
  println()
}


def regenProject(): Unit = {
  val projectPackagePath = home / "runtime" / "library" / "shared" / "src" / "main" / "scala" / "org" / "sireum" / "project"
  Sireum.procCheck(Os.proc(ISZ(sireum.string, "tools", "sergen", "-p", "org.sireum.project", "-l", s"${home / "license.txt"}",
    "-m", "json", "-o", projectPackagePath.string, s"${projectPackagePath / "Project.scala"}")).console,
    message.Reporter.create)
}


def regenPresentasi(): Unit = {
  val presentasiPackagePath = home / "runtime" / "library" / "shared" / "src" / "main" / "scala" / "org" / "sireum" / "presentasi"
  Sireum.procCheck(Os.proc(ISZ(sireum.string, "tools", "sergen", "-p", "org.sireum.presentasi", "-l",
    s"${home / "license.txt"}", "-m", "json", "-o", presentasiPackagePath.string,
    s"${presentasiPackagePath / "Presentation.scala"}")).console, message.Reporter.create)
}


def regenCliOpt(): Unit = {
  val cliPackagePath = home / "runtime" / "library" / "shared" / "src" / "main" / "scala" / "org" / "sireum" / "cli"
  Sireum.procCheck(Os.proc(ISZ(sireum.string, "tools", "sergen", "-p", "org.sireum.cli", "-l", s"${home / "license.txt"}",
    "-m", "json", "-o", cliPackagePath.string, s"${cliPackagePath / "CliOpt.scala"}")).console, message.Reporter.create)
}


def regenSlang(): Unit = {
  val astPackagePath = home / "slang" / "ast" / "shared" / "src" / "main" / "scala" / "org" / "sireum" / "lang" / "ast"
  val slangPackagePath = home / "slang" / "tipe" / "shared" / "src" / "main" / "scala" / "org" / "sireum" / "lang"
  Sireum.procCheck(Os.proc(ISZ(sireum.string, "tools", "trafo", "-l", s"${home / "license.txt"}", "-m",
    "immutable,mutable", "-o", astPackagePath.string, s"${astPackagePath / "AST.scala"}",
    s"${astPackagePath / "Typed.scala"}")).console, message.Reporter.create)
  Sireum.procCheck(Os.proc(ISZ(sireum.string, "tools", "sergen", "-p", "org.sireum.lang.tipe", "-l",
    s"${home / "license.txt"}", "-m", "json,msgpack", "-o", (slangPackagePath / "tipe").string,
    s"${slangPackagePath / "symbol" / "Info.scala"}", s"${astPackagePath / "AST.scala"}",
    s"${astPackagePath / "Typed.scala"}")).console, message.Reporter.create)
}


def regenSlangLl2(): Unit = {
  val parserPackagePath = home / "slang" / "parser" / "shared" / "src" / "main" / "scala" / "org" / "sireum" / "lang" / "parser"
  val parserResourcesPackagePath = home / "slang" / "parser" / "shared" / "src" / "main" / "resources"
  val parserInput = parserResourcesPackagePath / "SlangLl2.g"
  Sireum.procCheck(proc"$sireum parser gen -l ${home / "license.txt"} -p org.sireum.lang.parser -m slang -n SlangLl2 --no-backtracking -o $parserPackagePath $parserInput".console,
    message.Reporter.create)
}


def regenSlangTTLl1(): Unit = {
  val parserPackagePath = home / "slang" / "parser" / "shared" / "src" / "main" / "scala" / "org" / "sireum" / "lang" / "parser"
  val parserResourcesPackagePath = home / "slang" / "parser" / "shared" / "src" / "main" / "resources"
  val parserInput = parserResourcesPackagePath / "SlangTruthTable.g"
  Sireum.procCheck(proc"$sireum parser gen -l ${home / "license.txt"} -p org.sireum.lang.parser -m slang -n SlangTruthTableLl1 --no-backtracking -o $parserPackagePath $parserInput".console,
    message.Reporter.create)
}


def regenLogika(): Unit = {
  val logikaPackagePath = home / "logika" / "shared" / "src" / "main" / "scala" / "org" / "sireum" / "logika"
  Sireum.procCheck(Os.proc(ISZ(sireum.string, "tools", "trafo", "-l", s"${home / "license.txt"}", "-e", "Composite",
    "-m", "immutable,mutable", "-n", "State", "-o", logikaPackagePath.string,
    s"${logikaPackagePath / "State.scala"}")).console, message.Reporter.create)
}


def regenAir(): Unit = {
  val airRootPath = home / "hamr" / "air"
  val airPath = airRootPath / "shared" / "src" / "main" / "scala" / "org" / "sireum" / "hamr" / "ir"
  val airAsts: ISZ[String] = ISZ[String]("AadlAST.scala", "BlessAST.scala", "Emv2AST.scala", "GumboAST.scala", "SmfAST.scala").map((m: String) => (airPath / m).value)

  val slangPath = home / "slang" / "ast" / "shared" / "src" / "main" / "scala" / "org" / "sireum" / "lang" / "ast"
  val slangAsts = ISZ[String]("AST.scala", "Typed.scala").map((m: String) => (slangPath / m).value)

  Sireum.procCheck(Os.proc(ISZ[String](sireum.string, "tools", "trafo", "-l", s"${airRootPath / "license.txt"}",
    "-m", "immutable,mutable", "-o", airPath.string) ++ airAsts ++ slangAsts).console, message.Reporter.create)
  Sireum.procCheck(Os.proc(ISZ[String](sireum.string, "tools", "sergen", "-p", "org.sireum.hamr.ir", "-l",
    s"${airRootPath / "license.txt"}", "-m", "json,msgpack", "-o", airPath.string) ++ airAsts ++ slangAsts).console,
    message.Reporter.create)
}


def regenAct(): Unit = {
  val actPackagePath = home / "hamr" / "codegen" / "act" / "jvm" / "src" / "main" / "scala" / "org" / "sireum" / "hamr" / "act" / "ast"
  Sireum.procCheck(Os.proc(ISZ(sireum.string, "tools", "trafo", "-l", s"${home / "license.txt"}", "-m",
    "immutable,mutable", "-o", actPackagePath.string, s"${actPackagePath / "ActAst.scala"}")).console,
    message.Reporter.create)
}


def regenServer(): Unit = {
  val protocolPackagePath = home / "server" / "shared" / "src" / "main" / "scala" / "org" / "sireum" / "server" / "protocol"
  val logikaPackagePath = home / "logika" / "shared" / "src" / "main" / "scala" / "org" / "sireum" / "logika"
  val astPackagePath = home / "slang" / "ast" / "shared" / "src" / "main" / "scala" / "org" / "sireum" / "lang" / "ast"
  Sireum.procCheck(Os.proc(ISZ(sireum.string, "tools", "sergen", "-p", "org.sireum.server.protocol", "-l",
    s"${home / "license.txt"}", "-m", "msgpack,json", "-o", protocolPackagePath.string,
    s"${protocolPackagePath / "Message.scala"}",
    s"${logikaPackagePath / "Config.scala"}",
    s"${logikaPackagePath / "Smt2Query.scala"}",
    s"${astPackagePath / "Typed.scala"}"
  )).console, message.Reporter.create)
  val logikaOptionsPackagePath = logikaPackagePath / "options"
  Sireum.procCheck(Os.proc(ISZ(sireum.string, "tools", "cligen", "-p", "org.sireum.logika.options", "-l",
    s"${home / "license.txt"}", "-o", logikaOptionsPackagePath.string, "-n", "OptionsCli", "-r",
    (logikaOptionsPackagePath / "options.sc").string
  )).console, message.Reporter.create)
}

def regenParser(isSlang: B): Unit = {
  val parserPackagePath = home / "parser" / "shared" / "src" / "main" / "scala" / "org" / "sireum" / "parser"
  val parserResourcesPackagePath = home / "parser" / "jvm" / "src" / "main" / "resources"
  val license = home / "license.txt"
  val input = parserResourcesPackagePath / "SireumAntlr3.g"
  val mode: String = if (isSlang) "slang" else "antlr3"
  Sireum.procCheck(proc"$sireum parser gen -l $license -p org.sireum.parser -m $mode -n SireumGrammar --no-backtracking -o $parserPackagePath $input".console,
    message.Reporter.create)
}

def regenCli(): Unit = {
  val sireumPackagePath = home / "cli" / "jvm" / "src" / "main" / "scala" / "org" / "sireum"
  Sireum.procCheck(Os.proc(ISZ(sireum.string, "tools", "cligen", "-p", "org.sireum", "-l", s"${home / "license.txt"}",
    "-o", sireumPackagePath.string, s"${sireumPackagePath / "cli.sc"}")).console, message.Reporter.create)
}

def regenFmideCli(): Unit = {
  val installPath = homeBin / "install"
  Sireum.procCheck(Os.proc(ISZ(sireum.string, "tools", "cligen", "-s", "fmide.cmd", "-o", installPath.string,
    s"${installPath / "fmide-cli.sc"}")).console, message.Reporter.create)
}


def regenJson(): Unit = {
  val jsonPackagePath = home / "runtime" / "library" / "shared" / "src" / "main" / "scala" / "org" / "sireum" / "parser"
  val parserResourcesPackagePath = home / "runtime" / "library" / "shared" / "src" / "main" / "resources"
  val license = home / "license.txt"
  val input = parserResourcesPackagePath / "JSON.g"
  Sireum.procCheck(proc"$sireum parser gen -l $license -p org.sireum.parser -m slang -n Json --no-backtracking -o $jsonPackagePath $input".console,
    message.Reporter.create)
}


def m2(): Os.Path = {
  val repository = Os.home / ".m2" / "repository"
  val kekinianRepo = repository / "org" / "sireum" / "kekinian"
  kekinianRepo.removeAll()
  Sireum.procCheck(proc"$sireum proyek publish -n $proyekName --par --sha3 --ignore-runtime --m2 ${repository.up.canon} $home org.sireum.kekinian".console,
    message.Reporter.create)
  return kekinianRepo
}

def m2Lib(isJs: B): Unit = {
  val repository = Os.home / ".m2" / "repository"

  def version: String = {
    for (line <- ops.StringOps(proc"$sireum --version".runCheck().out).split((c: C) => c == '\n')) {
      val lineOps = ops.StringOps(line)
      if (lineOps.contains(DependencyManager.libraryKey)) {
        val i = lineOps.stringIndexOf("->")
        val j: Z = lineOps.lastIndexOf(',')
        return ops.StringOps(lineOps.substring(i + 2, if (j >= 0) j else line.size)).trim
      }
    }
    halt("Could not detect Slang library version")
  }

  val target: String = if (isJs) "--target js" else "--target jvm"
  Sireum.procCheck(proc"$sireum proyek publish -n $proyekName --par --sha3 --ignore-runtime --slice library --m2 ${repository.up.canon} $target --version $version $home org.sireum.kekinian".console,
    message.Reporter.create)
}

def jitpack(): Unit = {
  val ver = ops.StringOps(proc"git log -n 1 --pretty=format:%H".at(home).runCheck().out).substring(0, 10)
  val scalaVer = versions.get(DependencyManager.scalaKey).get
  val sc = Os.tempFix("", ".sc")
  sc.writeOver(
    st"""import org.sireum._
        |Coursier.setScalaVersion("$scalaVer")
        |for (cif <- Coursier.fetch(ISZ(s"org.sireum.kekinian::cli:$ver"))) {
        |  println(cif.path)
        |}""".render
  )
  sc.removeOnExit()
  Sireum.procCheck(proc"$sireum slang run $sc".console, message.Reporter.create)
}

def ghpack(): Unit = {
  val repository = m2()
  for (p <- Os.Path.walk(repository, F, F, (f: Os.Path) => ops.StringOps(f.name).endsWith("pom"))) {
    val d = p.up.canon
    val pom = d / "pom.xml"
    p.copyOverTo(pom)
    val pops = ops.StringOps(pom.read)
    val i = pops.stringIndexOf("</project>")
    pom.writeOver(pops.substring(0, i))
    pom.writeAppend(
      st"""    <distributionManagement>
          |        <repository>
          |            <id>github</id>
          |            <name>GitHub Sireum Apache Maven Packages</name>
          |            <url>https://maven.pkg.github.com/sireum/kekinian</url>
          |        </repository>
          |    </distributionManagement>
          |""".render
    )
    pom.writeAppend(pops.substring(i, pops.size))
    Os.proc(ISZ("mvn", "--settings", (home / "distro" / "mvn-settings.xml").string, "deploy")).at(d).console.runCheck()
  }
}

def setup(fresh: B, isUltimate: B, isServer: B): Unit = {
  println("Setup ...")
  build(fresh, F, F)
  val init = Init(home, Os.kind, versions)
  init.deps()
  init.distro(isDev = T, buildSfx = F, isUltimate = isUltimate, isServer = isServer)
  val suffix: String = if (isUltimate) "-ultimate" else if (isServer) "-server" else ""
  project(T, isUltimate, isServer)
  Os.kind match {
    case Os.Kind.Win =>
      println(s"Sireum-dev IVE can now be launched by running ${homeBin / "win" / s"idea$suffix" / "bin" / "IVE.exe"}")
      println(s"Java Development Kit (JDK) is available at ${homeBin / "win" / "java"}")
      println(s"Scala is available at ${homeBin / "scala"}")
    case Os.Kind.Linux =>
      println(s"Sireum-dev IVE can now be launched by running ${homeBin / "linux" / s"idea$suffix" / "bin" / (if (isServer) "idea.sh" else "IVE.sh")}")
      println(s"Java Development Kit (JDK) is available at ${homeBin / "linux" / "java"}")
      println(s"Scala is available at ${homeBin / "scala"}")
    case Os.Kind.LinuxArm =>
      println(s"Sireum-dev IVE can now be launched by running ${homeBin / "linux" / "arm" / s"idea$suffix" / "bin" / "IVE.sh"}")
      println(s"Java Development Kit (JDK) is available at ${homeBin / "linux" / "arm" / "java"}")
      println(s"Scala is available at ${homeBin / "scala"}")
    case Os.Kind.Mac =>
      println(s"Sireum-dev IVE can now be launched by running ${homeBin / "mac" / s"idea$suffix" / "IVE.app"}")
      println(s"Java Development Kit (JDK) is available at ${homeBin / "mac" / "java"}")
      println(s"Scala is available at ${homeBin / "scala"}")
    case _ =>
  }
}

def project(skipBuild: B, isUltimate: B, isServer: B): Unit = {
  if (!skipBuild) {
    build(F, F, F)
  }
  println("Generating IVE project ...")
  proc"$sireum proyek ive --force${if (isUltimate) " --edition ultimate" else if (isServer) " --edition server" else ""} $home".console.runCheck()
}

def ram(): Unit = {
  def mac(): Unit = {
    val ramdisk = Os.path("/Volumes") / "RAM"
    val ramdiskHome = ramdisk / home.name
    if (!(homeBin / "mac" / "idea" / "IVE.app").exists) {
      setup(F, F, F)
    }
    if (ramdisk.exists) {
      proc"launchctl remove org.sireum.ram.rsync".echo.console.run()
      proc"rsync -a --exclude .idea --exclude project.json --exclude out --exclude '*.cmd.com' $ramdiskHome ${home.up.canon}".echo.console.runCheck()
      proc"hdiutil eject $ramdisk".echo.console.runCheck()
    } else {
      val disk = ops.StringOps(proc"hdiutil attach -nomount ram://${8 * 1024 * 2048}".echo.console.runCheck().out).trim
      proc"diskutil erasevolume HFS+ ${ramdisk.name} $disk".echo.console.runCheck()
      proc"rsync -a --exclude .idea --exclude project.json --exclude out --exclude '*.cmd.com' $home $ramdisk".echo.console.runCheck()
      val plist = ramdisk / "rsync.plist"
      plist.writeOver(
        st"""<?xml version="1.0" encoding="UTF-8"?>
            |<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
            |<plist version="1.0">
            |<dict>
            |  <key>Label</key>
            |  <string>org.sireum.ram.rsync</string>
            |  <key>ProgramArguments</key>
            |  <array>
            |    <string>/usr/bin/rsync</string>
            |    <string>-av</string>
            |    <string>--exclude</string>
            |    <string>project.json</string>
            |    <string>--exclude</string>
            |    <string>.idea</string>
            |    <string>--exclude</string>
            |    <string>out</string>
            |    <string>--exclude</string>
            |    <string>*.cmd.com</string>
            |    <string>$ramdiskHome</string>
            |    <string>${home.up.canon}</string>
            |  </array>
            |  <key>Nice</key>
            |  <integer>1</integer>
            |  <key>StartInterval</key>
            |  <integer>150</integer>
            |  <key>RunAtLoad</key>
            |  <true/>
            |  <key>StandardErrorPath</key>
            |  <string>${plist.up.canon / s"${plist.name}.err.txt"}</string>
            |  <key>StandardOutPath</key>
            |  <string>${plist.up.canon / s"${plist.name}.out.txt"}</string>
            |</dict>
            |</plist>
            | """.render)
      println(s"""Wrote $plist""")
      proc"launchctl load $plist".echo.console.runCheck()
      println()
      val ive = ramdiskHome / "bin" / "mac" / "idea" / "IVE.app"
      proc"${ramdiskHome / "bin" / "build.cmd"} project".echo.console.runCheck()
      proc"open --env SIREUM_HOME=$ramdiskHome $ive".echo.console.runCheck()
    }
  }

  Os.kind match {
    case Os.Kind.Mac => mac()
    case _ =>
      eprintln("This utility is only available in macOS")
      Os.exit(-1)
  }
}

@pure def builtIn: Os.Path = {
  return home / "runtime" / "library" / "shared" / "src" / "main" / "scala" / "org" / "sireum" / "BuiltInTypes.slang"
}

if (!builtIn.exists) {
  eprintln("Some sub-modules are not present; please clone recursively or run:")
  eprintln("git submodule update --init --recursive --remote")
  Os.exit(-1)
}

if (Os.cliArgs.isEmpty) {
  val fresh: B = sireumJar.exists && builtIn.lastModified > sireumJar.lastModified
  val idea = homeBin / platform / "idea"
  val ideaUlt = homeBin / platform / "idea-ultimate"
  val ideaServer = homeBin / platform / "idea-server"
  val version: B = sireumJar.exists && (home / "versions.properties").lastModified > sireumJar.lastModified
  val isCommunity: B = (fresh | version) & idea.exists
  val isUltimate: B = (fresh | version) & ideaUlt.exists
  val isServer: B = (fresh | version) & ideaServer.exists

  if (fresh) {
    println(s"Modifications to ${builtIn.name} detected ... ")
    println()
  } else if (version & (isCommunity | isUltimate | isServer)) {
    println(s"Modifications to version.properties detected ... ")
    println()
  }
  if (fresh || version) {
    (isCommunity, isUltimate, isServer) match {
      case (T, T, T) => println(s"Rebuilding IVE, IVE Server, and IVE Ultimate  ...")
      case (T, T, F) => println(s"Rebuilding IVE and IVE Ultimate ...")
      case (T, F, T) => println(s"Rebuilding IVE and IVE Server ...")
      case (T, F, F) => println(s"Rebuilding IVE ...")
      case (F, T, T) => println(s"Rebuilding IVE Server and IVE Ultimate ...")
      case (F, T, F) => println(s"Rebuilding IVE Ultimate ...")
      case (F, F, T) => println(s"Rebuilding IVE Server ...")
      case (F, F, F) => println(s"Forcing fresh compilation ...")
    }
    println()
  }
  if (isCommunity || isUltimate || isServer) {
    if (isCommunity) {
      setup(fresh, F, F)
    }
    if (isUltimate) {
      if (isCommunity) {
        println()
      }
      setup(!isCommunity && fresh, T, F)
    }
    if (isServer) {
      if (isCommunity || isUltimate) {
        println()
      }
      setup(!isCommunity && !isUltimate && fresh, F, T)
    }
  } else {
    build(fresh, F, F)
  }
} else {
  val cliArgs = Os.cliArgs
  val size = cliArgs.size
  var i = 0
  while (i < size) {
    cliArgs(i) match {
      case string"jar" => build(F, F, F)
      case string"fresh" => build(T, F, F)
      case string"uber" => build(F, F, T)
      case string"native" => build(F, T, F)
      case string"setup" => setup(F, F, F)
      case string"setup-ultimate" => setup(F, T, F)
      case string"setup-server" => setup(F, F, T)
      case string"project" => project(F, F, F)
      case string"project-ultimate" => project(F, T, F)
      case string"project-server" => project(F, F, T)
      case string"tipe" => tipe()
      case string"compile" => compile(F)
      case string"compile-js" => compile(T)
      case string"test" => test()
      case string"verify" => verifyRuntime()
      case string"test-verify" => test(); verifyRuntime()
      case string"mill" => buildMill()
      case string"regen-slang" => regenSlang()
      case string"regen-slang-ll2" => regenSlangLl2()
      case string"regen-logika" => regenLogika()
      case string"regen-project" => regenProject()
      case string"regen-presentasi" => regenPresentasi()
      case string"regen-cliopt" => regenCliOpt()
      case string"regen-air" => regenAir()
      case string"regen-act" => regenAct()
      case string"regen-server" => regenServer()
      case string"regen-parser" => regenParser(T)
      case string"regen-parser-antlr3" => regenParser(F)
      case string"regen-cli" => regenCli()
      case string"regen-fmide-cli" => regenFmideCli()
      case string"regen-json" => regenJson()
      case string"regen-slang-tt" => regenSlangTTLl1()
      case string"m2" => m2()
      case string"m2-lib" => m2Lib(F)
      case string"m2-lib-js" => m2Lib(T)
      case string"jitpack" => jitpack()
      case string"ghpack" => ghpack()
      case string"ram" => ram()
      case string"alt-ergo-open" => altErgoOpen()
      case string"cvc" => cvc()
      case string"z3" => z3()
      case string"-h" => usage()
      case string"--help" => usage()
      case string"distro" =>
        var isSfx: B = F
        var isUltimate: B = F
        var isServer: B = F
        var kinds = ISZ[Os.Kind.Type]()
        i = i + 1
        while (i < size && ops.StringOps(cliArgs(i)).startsWith("--")) {
          cliArgs(i) match {
            case string"--linux" => kinds = kinds :+ Os.Kind.Linux
            case string"--linux-arm" => kinds = kinds :+ Os.Kind.LinuxArm
            case string"--mac" => kinds = kinds :+ Os.Kind.Mac
            case string"--win" => kinds = kinds :+ Os.Kind.Win
            case string"--sfx" => isSfx = T
            case opt =>
              usage()
              eprintln(s"Unrecognized distro command option: $opt")
              Os.exit(-1)
          }
          i = i + 1
        }
        i = i - 1
        if (kinds.isEmpty) {
          kinds = kinds :+ Os.kind
        }
        for (kind <- kinds) {
          Init(home, kind, versions).distro(T, isSfx, isUltimate, isServer)
          println()
        }
      case cmd =>
        usage()
        eprintln(s"Unrecognized command: $cmd")
        Os.exit(-1)
    }
    i = i + 1
  }
}
