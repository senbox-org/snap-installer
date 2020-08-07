echo %date% %time%

cd %0\..\..

echo Git updates...

set skipTests=true

set buildSnapEngine=true
set buildSnapDesktop=true
set buildSnapExamples=false
set buildS1TBX=false
set buildS2TBX=false
set buildS3TBX=false
set buildSMOSBOX=false
set buildProbavBox=false

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
if exist snap-examples\.git (
    cd snap-examples
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
if exist s1tbx\.git (
    cd s1tbx
    call git pull
    if %errorlevel% neq 0 exit /B %errorlevel%
    cd ..
)
if exist s2tbx\.git (
    cd s2tbx
    call git pull
    if %errorlevel% neq 0 exit /B %errorlevel%
    cd ..
)
if exist s3tbx\.git (
    cd s3tbx
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
if exist probavbox\.git (
    cd probavbox
    call git pull
    if %errorlevel% neq 0 exit /B %errorlevel%
    cd ..
)
if exist testdata\.git (
    cd testdata
    call git pull
    if %errorlevel% neq 0 exit /B %errorlevel%
    cd ..
)

echo Maven builds...

if exist snap-engine\pom.xml if %buildSnapEngine% EQU true (
    cd snap-engine
    call mvn clean install -T 4 -DskipTests=%skipTests%
    if %errorlevel% neq 0 exit /B %errorlevel%
    call mvn nbm:autoupdate
    if %errorlevel% neq 0 exit /B %errorlevel%
    cd ..
)
if exist snap-desktop\pom.xml if %buildSnapDesktop% EQU true (
    cd snap-desktop
    call mvn clean install -T 4 -DskipTests=%skipTests%
    if %errorlevel% neq 0 exit /B %errorlevel%
    call mvn nbm:autoupdate
    if %errorlevel% neq 0 exit /B %errorlevel%
    cd snap-application
    call mvn nbm:cluster-app
    if %errorlevel% neq 0 exit /B %errorlevel%
    cd ..\..
)
if exist snap-examples\pom.xml if %buildSnapExamples% EQU true (
    cd snap-examples
    call mvn clean install -T 4  -DskipTests=%skipTests%
    if %errorlevel% neq 0 exit /B %errorlevel%
    call mvn nbm:autoupdate
    if %errorlevel% neq 0 exit /B %errorlevel%
    cd ..
)
if exist s1tbx\pom.xml if %buildS1TBX% EQU true (
    cd s1tbx
    call mvn clean
    if %errorlevel% neq 0 exit /B %errorlevel%
    call mvn install -T 4 -DskipTests=%skipTests%
    if %errorlevel% neq 0 exit /B %errorlevel%
    call mvn nbm:autoupdate
    if %errorlevel% neq 0 exit /B %errorlevel%
    cd ..
)
if exist s2tbx\pom.xml if %buildS2TBX% EQU true (
    cd s2tbx
    call mvn clean install -T 4 -DskipTests=%skipTests%
    if %errorlevel% neq 0 exit /B %errorlevel%
    call mvn nbm:autoupdate
    if %errorlevel% neq 0 exit /B %errorlevel%

    cd s2tbx-sta-adapters\sen2cor
    call mvn clean install -T 4 -DskipTests=%skipTests%
    if %errorlevel% neq 0 exit /B %errorlevel%
    call mvn nbm:autoupdate
    if %errorlevel% neq 0 exit /B %errorlevel%

    cd ..\..\..
)
if exist s3tbx\pom.xml if %buildS3TBX% EQU true (
    cd s3tbx
    call mvn clean install -T 4 -DskipTests=%skipTests%
    if %errorlevel% neq 0 exit /B %errorlevel%
    call mvn nbm:autoupdate
    if %errorlevel% neq 0 exit /B %errorlevel%
    cd ..
)
if exist smos-box\pom.xml if %buildSMOSBOX% EQU true (
    cd smos-box
    call mvn clean install -T 4 -DskipTests=%skipTests%
    if %errorlevel% neq 0 exit /B %errorlevel%
    call mvn nbm:autoupdate
    if %errorlevel% neq 0 exit /B %errorlevel%
    cd ..
)
if exist probavbox\pom.xml if %buildProbavBox% EQU true (
    cd probavbox
    call mvn clean install -T 4 -DskipTests=%skipTests%
    if %errorlevel% neq 0 exit /B %errorlevel%
    call mvn nbm:autoupdate
    if %errorlevel% neq 0 exit /B %errorlevel%
    cd ..
)

echo %date% %time%