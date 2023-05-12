FROM mcr.microsoft.com/windows/server:ltsc2022

# Install Chocolatey
RUN powershell -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command "[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'));" && SET "PATH=%PATH%;%ALLUSERSPROFILE%\chocolatey\bin"

### PYTHON ###
RUN choco install -y python311 --params "/quiet"
RUN python --version && py -m pip --version

# JAVA
RUN choco install -y Temurin8 --params="/ADDLOCAL=FeatureMain,FeatureEnvironment,FeatureJarFileRunWith,FeatureJavaHome /quiet"
RUN java -version
# ARG USER_HOME_DIR="C:/Users/snap"

# Maven
RUN choco install -y maven --params "/quiet"
RUN mvn --version

COPY docker/build/maven/mvn-entrypoint.ps1 C:/ProgramData/Maven/apache-maven-3.6.3/mvn-entrypoint.ps1
COPY docker/build/maven/settings-docker.xml C:/ProgramData/Maven/apache-maven-3.6.3/Reference/settings-docker.xml


# PIP packages
RUN py -m pip install pillow psutil matplotlib lxml cryptography pymysql

# USER snap
### SNAP ###
ADD https://nexus.snap-ci.ovh/repository/snap-maven-public/org/esa/snap/installers-snapshot/snap_all_windows/10_0_0/snap_all_windows-10_0_0.exe /c/windows/temp/snap.exe

RUN /c/windows/temp/snap.exe -y

USER snap
ENTRYPOINT ["pwsh", "-f", "C:/ProgramData/Maven/apache-maven-3.6.3/mvn-entrypoint.ps1"]
CMD ["mvn"]