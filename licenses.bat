@echo OFF
echo %date% %time%

cd %0\..\..

set licenseDir=%~d0%~p03rd-party-licenses
if NOT exist %licenseDir% (
  mkdir %licenseDir%
)
set mvnBaseCall=mvn -q license:aggregate-add-third-party -Dlicense.outputDirectory=%licenseDir% -DexcludeTransitiveDependencies=true -Dlicense.excludedGroups=org\.esa\.snap


echo Generating 3rd-party license file for ...

if exist snap-engine\pom.xml (
echo ... snap-engine ...
    call %mvnBaseCall% -f snap-engine\pom.xml -Dlicense.thirdPartyFilename=SNAP-ENGINE-THIRD-PARTY.txt
    if %errorlevel% neq 0 exit /B %errorlevel%
)

if exist snap-desktop\pom.xml (
echo ... snap-desktop ...
    call %mvnBaseCall% -f snap-engine\pom.xml -Dlicense.thirdPartyFilename=SNAP-DESKTOP-THIRD-PARTY.txt
    if %errorlevel% neq 0 exit /B %errorlevel%
)

if exist s1tbx\pom.xml (
echo ... s1tbx ...
    cd s1tbx
    call %mvnBaseCall% -Dlicense.thirdPartyFilename=S1TBX-THIRD-PARTY.txt
    if %errorlevel% neq 0 exit /B %errorlevel%
    cd ..
)

if exist s2tbx\pom.xml (
echo ... s2tbx ...
    cd s2tbx
    call %mvnBaseCall% -Dlicense.thirdPartyFilename=S2TBX-THIRD-PARTY.txt
    if %errorlevel% neq 0 exit /B %errorlevel%
    cd ..
)

if exist s3tbx\pom.xml (
echo ... s3tbx ...
    cd s3tbx
    call %mvnBaseCall% -Dlicense.thirdPartyFilename=S3TBX-THIRD-PARTY.txt
    if %errorlevel% neq 0 exit /B %errorlevel%
    cd ..
)

if exist smos-box\pom.xml (
echo ... smos-box ...
    cd smos-box
    call %mvnBaseCall% -Dlicense.thirdPartyFilename=SMOS-BOX-THIRD-PARTY.txt
    if %errorlevel% neq 0 exit /B %errorlevel%
    cd ..
)

if exist probavbox\pom.xml (
echo ... probavbox ...
    cd probavbox
    call %mvnBaseCall% -Dlicense.thirdPartyFilename=PROBAVBOX-THIRD-PARTY.txt
    if %errorlevel% neq 0 exit /B %errorlevel%
    cd ..
)

cd snap-installer

echo %date% %time%
