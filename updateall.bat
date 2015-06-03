cd %0\..\..

echo Git updates...

if exist snap-engine\.git (
    cd snap-engine
    call git pull
    cd ..
)
if exist snap-desktop\.git (
    cd snap-desktop
    call git pull
    cd ..
)
if exist snap-examples\.git (
    cd snap-examples
    call git pull
    cd ..
)
if exist snap-installer\.git (
    cd snap-installer
    call git pull
    cd ..
)
if exist s1tbx\.git (
    cd s1tbx
    call git pull
    cd ..
)
if exist s2tbx\.git (
    cd s2tbx
    call git pull
    cd ..
)
if exist s3tbx\.git (
    cd s3tbx
    call git pull
    cd ..
)

echo Maven builds...

if exist snap-engine\pom.xml (
    cd snap-engine
    call mvn clean install -T 4
    cd ..
)
if exist snap-desktop\pom.xml (
    cd snap-desktop
    call mvn clean install -T 4 -DskipTests=true
    cd ..
)
if exist snap-examples\pom.xml (
    cd snap-examples
    call mvn clean install -T 4
    cd ..
)
if exist s1tbx\pom.xml (
    cd s1tbx
    call mvn clean install -T 4
    cd ..
)
if exist s2tbx\pom.xml (
    cd s2tbx
    call mvn clean install -T 4
    cd ..
)
if exist s3tbx\pom.xml (
    cd s3tbx
    call mvn clean install -T 4
    cd ..
)

