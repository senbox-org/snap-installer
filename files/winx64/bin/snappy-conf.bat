@echo off

if [%1] == [] goto Usage
if [%1] == [/?] goto Usage
if not [%3] == [] goto Usage

"%~dp0\snap64.exe" --nogui --nosplash --snappy %1 %2
goto End

:Usage
@echo Configures the SNAP-Python interface 'esa_snappy'.
@echo. 
@echo %~n0 Python [Dir] ^| [/?]
@echo.  
@echo     Python: Full path to Python executable to be used with SNAP, e.g. C:\Python37\python.exe
@echo     Dir:    Directory where the 'esa_snappy' module should be installed. Defaults to %USERPROFILE%\.snap\snap-python
@echo.
:End