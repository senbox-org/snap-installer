@echo off

if [%1] == [] goto Usage
if [%1] == [/?] goto Usage
if not [%4] == [] goto Usage

%~dp0\snap.exe --nogui --nosplash --python %1 %2 %3
goto End

:Usage
@echo Configures the SNAP-Python interface 'snappy'.
@echo. 
@echo %~n0 Python [Target [Force]]
@echo.  
@echo     Python:  Full path to Python executable to be used with SNAP.
@echo     Target:  Directory where the 'snappy' module should be installed.
@echo     Force:   "true" if an existing 'snappy' in be overwritten in Target.
@echo.  
:End