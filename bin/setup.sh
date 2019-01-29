#!/bin/bash -e
#
# Copyright (c) 2019, Robby, Kansas State University
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#
# 1. Redistributions of source code must retain the above copyright notice, this
#    list of conditions and the following disclaimer.
# 2. Redistributions in binary form must reproduce the above copyright notice,
#    this list of conditions and the following disclaimer in the documentation
#    and/or other materials provided with the distribution.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
# ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
# WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR
# ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
# (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
# LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
# ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
# (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
# SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#
export SIREUM_HOME=$( cd "$( dirname "$0" )"/.. &> /dev/null && pwd )
cd ${SIREUM_HOME}
git submodule update --init --recursive --remote
git pull --recurse-submodules
export SIREUM_SOURCE_BUILD=true
rm -fR out
bin/build.sh
source bin/platform.sh
bin/mill IVE
case ${PLATFORM} in
    win) echo "Sireum-dev IVE can now be launched by running ${SIREUM_HOME}/bin/win/idea/bin/IVE.exe"
         echo "Java Development Kit (JDK) is available at ${SIREUM_HOME}/bin/win/java"
         echo "Scala is available at ${SIREUM_HOME}/bin/scala"
         echo "Mill can be found at ${SIREUM_HOME}/bin/mill.bat";;
  linux) echo "Sireum-dev IVE can now be launched by running ${SIREUM_HOME}/bin/linux/idea/bin/IVE.sh"
         echo "Java Development Kit (JDK) is available at ${SIREUM_HOME}/bin/linux/java"
         echo "Scala is available at ${SIREUM_HOME}/bin/scala"
         echo "Mill can be found at ${SIREUM_HOME}/bin/mill";;
    mac) echo "Sireum-dev IVE can now be launched by opening ${SIREUM_HOME}/bin/mac/idea/IVE.app"
         echo "Java Development Kit (JDK) is available at ${SIREUM_HOME}/bin/mac/java"
         echo "Scala is available at ${SIREUM_HOME}/bin/scala"
         echo "Mill can be found at ${SIREUM_HOME}/bin/mill";;
esac
