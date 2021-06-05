# Sireum: A High Assurance System Engineering Platform

| [![Actions Status](https://github.com/sireum/kekinian/workflows/CI/badge.svg)](https://github.com/sireum/kekinian/actions) | [![](https://jitpack.io/v/org.sireum/kekinian.svg)](https://jitpack.io/#org.sireum/kekinian) |
| :---: | :---: |
| <sub><sup>amd64: mac, linux, windows</sup></sub> | <sub><sup>maven: `org.sireum.kekinian:cli_2.13:<tag-or-hash>`</sup></sub> |

## Overview

Sireum Kekinian is the most recent evolution of the Sireum platform whose 
core components are being built using the Sireum programming language -- Slang.

Slang is an OO/FP programming language with contract and proof languages
designed for formal verification and analyses; that is, it serves as the basis for the next generation
[Logika](http://logika.sireum.org) verifier and proof checker, as well as for other
formal method-based analysis techniques.
It is currently a subset of Scala 2.13 with tailored semantics 
enabled via Scala's 
[macro](https://github.com/sireum/runtime/blob/master/macros/shared/src/main/scala/org/sireum/%24internal/Macro.scala) 
and  [compiler plugin](https://github.com/sireum/scalac-plugin) 
facilities, supported with a customized version of IntelliJ -- 
Sireum IVE, and an accompanying build tool -- Proyek.

With the exception of a small part of its 
[runtime library](https://github.com/sireum/runtime) and its
parser that uses [scalameta](http://scalameta.org), 
the runtime library and the Slang [codebase](https://github.com/sireum/slang) 
itself (and analyses on top of it) are written using Slang.

Slang programs run on the JVM (Java 8+), in the browser or Node.js 
(via [Scala.js](http://scala-js.org) Javascript translation), and natively
via [Graal](http://graalvm.org) targeting macOS, Linux, and Windows on amd64, and
Linux on aarch64.

In addition, the Slang-to-C [transpiler](https://github.com/sireum/transpilers)
can compile a subset of Slang -- Slang Embedded (which excludes, e.g., closures and 
recursive types), to C99 without garbage-collection at runtime. 
The generated C code is both Slang source-traceable and 
in the form that is structurally close to the Slang source; 
in addition to `gcc` and `clang`, it can also be compiled using the 
[CompCert](http://compcert.inria.fr/) Verified C Compiler 
to provide a high-assurance toolchain for program correctness down to machine code.

On all compilation targets (e.g., JVM, C, Javascript, etc.), Slang provides extension
method facilities that can extend its language features and integrate with other 
programming languages, platform-specific libraries, and existing/legacy code.

Furthermore, Slang can also be used as a universal shell scripting language 
-- [Slash](https://github.com/sireum/slang-by-examples), which can run
on macOS, Linux, Windows, and others where a JVM runtime is available.
Slash powers many of the shell scripts for developing Kekinian itself.
As Slash is Slang, Slash scripts can be compiled to native via Graal, which speeds 
things up by virtue of having no JVM boot up time.

## Available Products

* [HAMR](http://hamr.sireum.org): A **H**igh **A**ssurance **M**odel-based **R**apid Engineering of Embedded Systems

## Installing

Sireum is available as pre-built binaries/installers or from source.
The main advantage of using the source distribution is that updates
can be done incrementally while the binary distribution requires complete
re-installation. On the other hand, source distribution requires more setup.
As Sireum is currently in its early active development phase, it is highly
recommended to use the source distribution.

### Binary Distributions

Sireum binary distribution files are [7z](https://www.7-zip.org/7z.html) 
[self-extracting archives (SFX)](https://en.wikipedia.org/wiki/Self-extracting_archive) 
with command-line installers to (optionally) configure where Sireum should be 
installed.
 
Below are the installation instructions for 64-bit (amd64) macOS, Linux, and 
Windows (or, one can simply download the distribution files from the
[GitHub releases page](https://github.com/sireum/kekinian/releases)
and extract them  using a program capable of uncompressing `7z` archive).

* **macOS**: run the following command in a terminal:

  ```bash
  (sd=sireum-dev-mac.sfx && curl -JLo $sd -c /dev/null http://mac.distro.sireum.org && chmod +x $sd && p=$(pwd) && cd /tmp && $p/$sd)
  ```

* **Linux**: download and run [sireum-dev-linux.sfx](http://linux.distro.sireum.org), 
  or run the following command in a terminal if you have `curl` installed:

  ```bash
  (sd=sireum-dev-linux.sfx && curl -JLo $sd -c /dev/null http://linux.distro.sireum.org && chmod +x $sd && p=$(pwd) && cd /tmp && $p/$sd)
  ```

* **Windows**: download and run [sireum-dev-win.exe](http://win.distro.sireum.org)

If you want to ensure that the downloaded files are genuine, download 
the appropriate [Minisign](https://jedisct1.github.io/minisign/) signature files 
for the specific platforms for [macOS](http://minisig.mac.distro.sireum.org), 
[Linux](http://minisig.linux.distro.sireum.org), and 
[Windows](http://minisig.win.distro.sireum.org), then run:

```console
minisign -P RWShRZe/1tMRHAcQ2162Wq5FhU2ptktJdQxzUxvK0MwVjDYRC4JY87Fb -Vm <installer-file>
```

Alternatively, you can also use a port of [OpenBSD's signify](https://man.openbsd.org/signify) for your
operating system (e.g., `signify-openbsd` in Ubuntu) instead of `minisign` as follows:

```console
signify-openbsd -V -p sireum.pub -x <installer-file>.minisig -m <installer-file>
```

where `sireum.pub`'s content is:

```
untrusted comment: Sireum
RWShRZe/1tMRHAcQ2162Wq5FhU2ptktJdQxzUxvK0MwVjDYRC4JY87Fb
```


### Git Source Distribution

#### Requirements:

* **macOS**: `curl` and `git`

* **Linux** (amd64, aarch64): `curl` and `git`

  * [Docker](resources/docker): [sireum/ci:latest](https://hub.docker.com/r/sireum/ci)

* **Windows**, either: 
  
  * [Developer Mode enabled](https://docs.microsoft.com/en-us/windows/uwp/get-started/enable-your-device-for-development) and `git` ([Git For Windows](https://git-scm.com/download/win), [MSYS2](https://www.msys2.org/), or [Cygwin](https://www.cygwin.com)); or
  
  * [WSL2](https://docs.microsoft.com/en-us/windows/wsl/wsl2-index) (Linux requirements apply)

#### Setup

In a console terminal:

* **macOS/Linux**:

  ```bash
  git clone --recursive https://github.com/sireum/kekinian
  kekinian/bin/build.cmd setup  # for non-POSIX shell, prefix with sh
  ```

* **Windows**:

  ```cmd
  git clone --recursive https://github.com/sireum/kekinian
  kekinian\bin\build.cmd setup
  ```

Set the `SIREUM_HOME` env var to the `kekinian` path above.

To update later on, simply do a `git pull --recurse-submodules` and re-run 
`build.cmd setup` (or simply `build.cmd` to rebuild Sireum CLI tools).
Note that after a `setup` update, it is best to invalidate IntelliJ's cache files 
and restart by using IntelliJ's `File -> Invalidate Caches/Restart...` 
menu item.

Occasionally, there might be new API used in `build.cmd` that is available 
in the pre-built binary online but not in your local copy.
This issue happens because `build.cmd` uses Sireum itself, hence it is a
bootstraping issue.
This issue typically manifests by `build.cmd` failing to compile/execute 
due to missing methods/classes.
In that case, first delete your local `sireum.jar` in the `bin` directory and 
then re-run `build.cmd setup`.

If rebuilding Sireum somehow failed still, try cleaning the repo:

* **macOS/Linux**:

  ```bash
  ${SIREUM_HOME}/bin/clean.sh
  ```

* **Windows**:

  ```cmd
  %SIREUM_HOME%\bin\clean.bat
  ```
  
The clean scripts remove all Sireum-related cache directories and revert any changes and delete new files in 
the local git repository.

After cleaning, re-run `git pull --recurse-submodules` and `build.cmd setup`.


#### Using Vagrant and VirtualBox

By using [Vagrant](https://www.vagrantup.com/), you can automatically provision a 
[VirtualBox](https://www.virtualbox.org) [Xubuntu](https://xubuntu.org/) 
virtual machine (VM) with Sireum set up as follows:

1. Download the [resources/vagrant](resources/vagrant) folder as an archive
   ([link](https://downgit.github.io/#/home?url=https://github.com/sireum/kekinian/tree/master/resources/vagrant&fileName=sireum-vagrant&rootDirectory=sireum-vagrant)) 
   and uncompress it.

2. If desired, modify the [Vagrantfile](resources/vagrant/Vagrantfile) to customize the number of CPUs (default: 4),
   RAM (default: 16GB), and VRAM (default: 64MB).
   Note that the disk size defaults to 64GB, which is derived from the [bento/ubuntu](https://app.vagrantup.com/bento)
   base box.
   Moreover, it installs
   [FMW](https://github.com/loonwerks/formal-methods-workbench), 
   [CLion](https://www.jetbrains.com/clion), and 
   [CompCert](http://compcert.inria.fr) by default.
   These can be adjusted by commenting out lines that start with `bin/install/` in the [Vagrantfile](resources/vagrant/Vagrantfile).
  
3. Run the following in a terminal console inside the uncompressed directory:

   * **macOS/Linux**:
   
     ```bash
     bash setup.sh
     ```
   
   * **Windows**:

     ```cmd
     setup.bat
     ```
   
Once the VM has been provisioned successfully, you can log in as the user `vagrant` with default password `vagrant`.
Sireum is installed in `/home/vagrant/Sireum`, which the `SIREUM_HOME` environment variable is set to.

## Using Sireum 

Please read the quick tutorial at: https://github.com/sireum/proyek-example


## Learning Slang by Examples

If you would like to learn Slang quickly, you can read and use [Sireum IVE](#using-sireum-ive)
to experiment with several examples designed to highlight various Slang language features:

https://github.com/sireum/slang-by-examples

## Sireum Development

Sireum is best developed (browsed/edited) by using Sireum IVE itself. 
The `build.cmd setup` command above setup IVE for Sireum development.
If you want to re-run just the IVE project re-generation (e.g., when 
there are upgrades to some library dependencies), do the following in 
a terminal:

* **macOS/Linux**:

  ```bash
  ${SIREUM_HOME}/bin/build.cmd project
  ```

* **Windows**:

  ```cmd
  %SIREUM_HOME%\bin\build.cmd project
  ```

Then open the `SIREUM_HOME` directory as a project in Sireum IVE.

To have the codebase and its test suites recompiled upon changes, run:

* **macOS/Linux**:

  ```bash
  cd ${SIREUM_HOME} && bin/mill -w cli.tests.compile
  ```

  and to build its assembly/CLI tool:

  ```bash
  ${SIREUM_HOME}/bin/build.cmd
  ```

* **Windows**:

  ```cmd
  cd %SIREUM_HOME% && bin\mill.bat -w cli.tests.compile
  ```

  and to build its assembly/CLI tool:

  ```cmd
  %SIREUM_HOME%\bin\build.cmd
  ```

## Sireum Native Executable

It is recommended to compile Sireum (and Slash build scripts) to native as it removes JVM boot up time.

First, install [GraalVM](http://graalvm.org) [`native-image`'s prerequisites](https://www.graalvm.org/reference-manual/native-image/#prerequisites)
(note: `native-image` for Windows requires Visual Studio Community 2017 or 2019); 
then, to build Sireum native executable:

* **macOS/Linux**:

  ```bash
  ${SIREUM_HOME}/bin/build.cmd native
  ```

* **Windows**:

  * Visual Studio 2017 Community
  
    ```cmd
    call "C:\Program Files (x86)\Microsoft Visual Studio\2017\Community\VC\Auxiliary\Build\vcvars64.bat"
    %SIREUM_HOME%\bin\build.cmd native
    ```

  * Visual Studio 2019 Community
  
    ```cmd
    call "C:\Program Files (x86)\Microsoft Visual Studio\2019\Community\VC\Auxiliary\Build\vcvars64.bat"
    %SIREUM_HOME%\bin\build.cmd native
    ```
  
To run:

* **macOS**:

  ```bash
  ${SIREUM_HOME}/bin/mac/sireum
  ```
  
* **Linux**:

  ```bash
  ${SIREUM_HOME}/bin/linux/sireum
  ```
  
* **Windows**:
  
  ```cmd
  %SIREUM_HOME%\bin\win\sireum.exe
  ```
  
Note that once the native version is available (and has a newer timestamp),
`sireum` and `sireum.bat` in `bin` call the native version. 
 This is also similar for `build.cmd` in `bin`.
