@echo off

if [%1] == [] goto Usage
if [%1] == [/?] goto Usage
if not [%3] == [] goto Usage

"%~dp0\snap.exe" --nogui --nosplash --snappy %1 %2
goto End

:Usage
@echo Configures the SNAP-Python interface 'esa_snappy'.
@echo.
@echo Usage:
@echo %~n0 Python [Dir] ^| [/?]
@echo.  
@echo     Python: Full path to Python executable to be used with SNAP, e.g. C:\Python37\python.exe
@echo     Dir:     Directory where the 'esa_snappy' package should have been installed. Default is the site-packages directory of the Python installation."
@echo.
:End
