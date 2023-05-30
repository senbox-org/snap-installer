@echo off
set LOGFILE=%CD%\updateall_log.txt
echo LOG-file: %LOGFILE%
call :SCRIPT > %LOGFILE%  2>&1
exit /B

:SCRIPT

echo START %date% %time%

cd %0\..\..

echo Git updates...

set skipTests=false

set buildSnapEngine=true
set buildSnapDesktop=true
set buildMwvTBX=true
set buildOptTBX=true
set buildSMOSBOX=true
set buildSnapExamples=false

if exist snap-engine\.git (
    cd snap-engine
    call git pull
    if %errorlevel% neq 0 exit /B %errorlevel%
    cd ..
)
if exist snap-desktop\.git (
    cd snap-desktop
    call git pull
    if %errorlevel% neq 0 exit /B %errorlevel%
    cd ..
)
if exist snap-installer\.git (
    cd snap-installer
    call git pull
    if %errorlevel% neq 0 exit /B %errorlevel%
    cd ..
)
if exist microwave-toolbox\.git (
    cd microwave-toolbox
    call git pull
    if %errorlevel% neq 0 exit /B %errorlevel%
    cd ..
)
if exist optical-toolbox\.git (
    cd optical-toolbox
    call git pull
    if %errorlevel% neq 0 exit /B %errorlevel%
    cd ..
)
if exist smos-box\.git (
    cd smos-box
    call git pull
    if %errorlevel% neq 0 exit /B %errorlevel%
    cd ..
)
if exist snap-examples\.git (
    cd snap-examples
    call git pull
    if %errorlevel% neq 0 exit /B %errorlevel%
    cd ..
)

echo Maven builds...

call mvn -v

if exist snap-engine\pom.xml if %buildSnapEngine% EQU true (
    cd snap-engine
    call mvn clean install -T 8 -DskipTests=%skipTests%
    if %errorlevel% neq 0 exit /B %errorlevel%
    call mvn nbm:autoupdate
    if %errorlevel% neq 0 exit /B %errorlevel%
    cd ..
)

if exist snap-desktop\pom.xml if %buildSnapDesktop% EQU true (
    cd snap-desktop
    call mvn clean install -T 8 -DskipTests=%skipTests%
    if %errorlevel% neq 0 exit /B %errorlevel%
    call mvn nbm:autoupdate
    if %errorlevel% neq 0 exit /B %errorlevel%
    cd snap-application
    call mvn nbm:cluster-app
    if %errorlevel% neq 0 exit /B %errorlevel%
    cd ..\..
)

if exist microwave-toolbox\pom.xml if %buildMwvTBX% EQU true (
    cd microwave-toolbox
    call mvn clean install -T 8 -DskipTests=%skipTests%
    if %errorlevel% neq 0 exit /B %errorlevel%
    call mvn nbm:autoupdate
    if %errorlevel% neq 0 exit /B %errorlevel%
    cd ..
)

if exist optical-toolbox\pom.xml if %buildOptTBX% EQU true (
    cd optical-toolbox
    call mvn clean install -T 8 -DskipTests=%skipTests%
    if %errorlevel% neq 0 exit /B %errorlevel%
    call mvn nbm:autoupdate
    if %errorlevel% neq 0 exit /B %errorlevel%
    cd ..
)

if exist smos-box\pom.xml if %buildSMOSBOX% EQU true (
    cd smos-box
    call mvn clean install -T 8 -DskipTests=%skipTests%
    if %errorlevel% neq 0 exit /B %errorlevel%
    call mvn nbm:autoupdate
    if %errorlevel% neq 0 exit /B %errorlevel%
    cd ..
)

if exist snap-examples\pom.xml if %buildSnapExamples% EQU true (
    cd snap-examples
    call mvn clean install -T 8  -DskipTests=%skipTests%
    if %errorlevel% neq 0 exit /B %errorlevel%
    call mvn nbm:autoupdate
    if %errorlevel% neq 0 exit /B %errorlevel%
    cd ..
)

echo STOP %date% %time%
