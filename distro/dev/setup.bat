@echo off
set INSTALL_PATH="%USERPROFILE%\Applications"
choice /T 5 /C YN /D N /N /M "Customize where Sireum-dev should be installed under (defaults to %INSTALL_PATH%) [Y/N]? "
if errorlevel 2 goto :install
set /p INSTALL_PATH="Enter the directory path [Press Enter to use the default]: "
:install
echo Installing in %INSTALL_PATH% ...
md %INSTALL_PATH% 1> nul 2>&1
rd /S /Q %INSTALL_PATH%\Sireum-dev 2>nul
move %~dp0Sireum-dev %INSTALL_PATH% 1> nul 2>&1
if not exist %~dp0Sireum-dev\ goto failed
:success
echo Sireum-dev IVE can now be launched by running %INSTALL_PATH%\Sireum-dev\bin\win\idea\bin\idea64.exe
echo Java Development Kit (JDK) is available at %INSTALL_PATH%\Sireum-dev\bin\win\java
echo Scala is available at %INSTALL_PATH%\Sireum-dev\bin\scala
echo Mill can be found at %INSTALL_PATH%\Sireum-dev\bin\mill.bat
goto end
:failed
echo Installation failed
:end
echo Press any key to exit ...
pause >nul
REM (goto) 2>nul & del "%~f0"