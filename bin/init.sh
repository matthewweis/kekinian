#!/bin/bash -e
#
# Copyright (c) 2017-2023, Robby, Kansas State University
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

: ${SIREUM_V:=master}
if [[ "${SIREUM_V}" == "master" ]]; then
  : ${SIREUM_INIT_V:=latest}
else
  if [[ -z "${SIREUM_INIT_V}" ]]; then
    if [[ ${SIREUM_V} == 4.* ]]; then
      SIREUM_INIT_V=${SIREUM_V}
    else
      SIREUM_INIT_V=4.${SIREUM_V}
    fi
  fi
fi

: ${SIREUM_CACHE:="$( cd ~ &> /dev/null && pwd )/Downloads/sireum"}
mkdir -p ${SIREUM_CACHE}


function versionNorm {
  printf "%03d%03d%03d%03d" $(echo "$1" | tr '.' ' ')
}

if [ -n "$COMSPEC" -a -x "$COMSPEC" ]; then
  Z7="${SIREUM_HOME}/bin/win/7za.exe"
  Z7_URL="https://github.com/sireum/bin-windows/raw/master/7za.exe"
  if [[ -z "${PLATFORM}" ]]; then
    PLATFORM=win
  fi
elif [[ "$(uname)" == "Darwin" ]]; then
  Z7="${SIREUM_HOME}/bin/mac/7za"
  Z7_URL="https://github.com/sireum/bin-mac/raw/master/7za"
  if [[ -z "${PLATFORM}" ]]; then
    PLATFORM=mac
  fi
elif [[ "$(expr substr $(uname -s) 1 5)" == "Linux" ]]; then
  if [[ "$(uname -m)" == "aarch64" ]]; then
    Z7="${SIREUM_HOME}/bin/linux/arm/7za"
    Z7_URL="https://github.com/sireum/bin-linux/raw/master/arm/7za"
    if [[ -z "${PLATFORM}" ]]; then
      PLATFORM=linux/arm
    fi
  else
    Z7="${SIREUM_HOME}/bin/linux/7za"
    Z7_URL="https://github.com/sireum/bin-linux/raw/master/7za"
    if [[ -z "${PLATFORM}" ]]; then
      PLATFORM=linux
    fi
  fi
else
  >&2 echo "Sireum does not support: $(uname)."
  exit 1
fi

getVersion() {
  grep "^$1=" ${SIREUM_HOME}/versions.properties | cut -d'=' -f2-
}

download() {
  if hash curl 2>/dev/null; then
    curl -c /dev/null -JLso $1 $2
  elif hash wget 2>/dev/null; then
    wget -qO $1 $2
  else
    >&2 echo "Either curl or wget is required, but none found."
    exit 1
  fi
}

uncompress() {
  if [ -x "$Z7" ]; then
    $Z7 x -y $1 > /dev/null
  elif hash unzip 2>/dev/null; then
    unzip -qo $1
  elif hash 7z 2>/dev/null; then
    7z x -y $1 > /dev/null
  else
    echo "Please wait while downloading 7za ..."
    rm -fR $Z7
    download $Z7 $Z7_URL
    chmod +x $Z7
    echo
    $Z7 x -y $1 > /dev/null
  fi
}

#
# Sireum
#
SIREUM_HOME=$( cd "$( dirname "$0" )"/.. &> /dev/null && pwd )
cd ${SIREUM_HOME}
if [[ ! -f bin/sireum.jar ]]; then
  echo "Please wait while downloading Sireum ..."
  download bin/sireum.jar https://github.com/sireum/init/releases/download/${SIREUM_INIT_V}/sireum.jar
  chmod +x bin/sireum.jar
  echo
fi
if [[ ! -f bin/sireum ]]; then
  download bin/sireum https://raw.githubusercontent.com/sireum/kekinian/${SIREUM_V}/bin/sireum
  chmod +x bin/sireum
fi
if [[ ! -f versions.properties ]]; then
  download versions.properties https://raw.githubusercontent.com/sireum/kekinian/${SIREUM_V}/versions.properties
fi


#
# Java
#
if [[ -n ${SIREUM_PROVIDED_JAVA} ]]; then
  exit
fi
JAVA_NAME="Zulu JDK"
if [[ -z ${JAVA_VERSION} ]]; then
  JAVA_VERSION=$(getVersion "org.sireum.version.zulu")
fi
if [[ "${PLATFORM}" == "mac" ]]; then
  if [[ "$(uname -m)" == "arm64" ]]; then
    JAVA_DROP_URL=https://cdn.azul.com/zulu/bin/zulu${JAVA_VERSION}-macosx_aarch64.tar.gz
  else
    JAVA_DROP_URL=https://cdn.azul.com/zulu/bin/zulu${JAVA_VERSION}-macosx_x64.tar.gz
  fi
elif [[ "${PLATFORM}" == "linux/arm" ]]; then
  JAVA_VERSION=${JAVA_VERSION/-fx}
  JAVA_DROP_URL=https://cdn.azul.com/zulu/bin/zulu${JAVA_VERSION}-linux_aarch64.tar.gz
elif [[ "${PLATFORM}" == "linux" ]]; then
  if [[ -n ${SIREUM_ZING_VERSION} ]]; then
    echo "Azul Platform Prime Stream Build is only for evaluation purposes"
    echo "(see: https://www.azul.com/wp-content/uploads/Azul-Platform-Prime-Evaluation-Agreement.pdf)"
    JAVA_NAME="Zing JDK"
    JAVA_VERSION=${SIREUM_ZING_VERSION}
    JAVA_DROP_URL=https://cdn.azul.com/zing-zvm/ZVM${JAVA_VERSION%%-*}/zing${JAVA_VERSION}-linux_x64.tar.gz
  else
    JAVA_DROP_URL=https://cdn.azul.com/zulu/bin/zulu${JAVA_VERSION}-linux_x64.tar.gz
  fi
elif [[ "${PLATFORM}" == "win" ]]; then
  JAVA_DROP_URL=https://cdn.azul.com/zulu/bin/zulu${JAVA_VERSION}-win_x64.zip
fi
mkdir -p ${SIREUM_HOME}/bin/${PLATFORM}
cd ${SIREUM_HOME}/bin/${PLATFORM}
JAVA_DROP="${JAVA_DROP_URL##*/}"
JAVA_DIR="${JAVA_DROP%.*}"
if [[ ${JAVA_DIR} == *.tar ]]; then
  JAVA_DIR="${JAVA_DIR%.*}"
fi
grep -q ${JAVA_VERSION} java/VER &> /dev/null && JAVA_UPDATE=false || JAVA_UPDATE=true
if [[ ! -d "java" ]] || [[ "${JAVA_UPDATE}" = "true" ]]; then
  if [[ ! -f ${SIREUM_CACHE}/${JAVA_DROP} ]]; then
      echo "Please wait while downloading ${JAVA_NAME} ${JAVA_VERSION} ..."
      download  ${SIREUM_CACHE}/${JAVA_DROP} ${JAVA_DROP_URL}
  fi
  echo "Extracting ${JAVA_NAME} ${JAVA_VERSION} ..."
  if [[ ${JAVA_DROP} == *.tar.gz ]]; then
    tar xf ${SIREUM_CACHE}/${JAVA_DROP}
  else
    uncompress ${SIREUM_CACHE}/${JAVA_DROP}
  fi
  rm -fR java
  mv ${JAVA_DIR} java
  echo
  if [[ -d "java/bin" ]]; then
    chmod +x java/bin/*
    chmod -fR u+w java
    echo "${JAVA_VERSION}" > java/VER
  else
    >&2 echo "Could not install ${JAVA_NAME} ${JAVA_VERSION}."
    exit 1
  fi
fi


#
# Setup
#
if [[ ! -f ${SIREUM_HOME}/bin/build.cmd ]] && [[ ! "${SIREUM_NO_SETUP}" = "true" ]]; then
  export PATH=${SIREUM_HOME}/bin/${PLATFORM}/java/bin:$PATH
  java -jar ${SIREUM_HOME}/bin/sireum.jar --setup
fi