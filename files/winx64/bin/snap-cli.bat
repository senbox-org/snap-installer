@echo off

set SNAP_HOME=${installer:sys.installationDir}

echo.
@echo Welcome to the SNAP command-line interface!
@echo The following command-line tools are available:
@echo   gpt         - Graph Processing Tool
@echo   pconvert    - Data product conversion and quicklook generation
@echo   snap64      - SNAP Desktop launcher
@echo Typing the name of the tool will output its usage information.
echo.

cd "%SNAP_HOME%\bin"

prompt $G$S
