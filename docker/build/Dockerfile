FROM ubuntu:22.04 as base

ARG DEBIAN_FRONTEND=noninteractive
ARG USER=snap
ARG USER_HOME_DIR="/home/snap"
ARG DOCKER_GID=999


##################
# SETUP UBUNTU   #
##################

RUN apt-get -qq update && apt-get -qqy upgrade && apt-get -qqy install gnupg2 locales wget curl bc git
RUN apt-get -qqy install libxext6 libxrender1 libxtst6 libxi6 libxxf86dga1 libxxf86vm1 libgfortran5 mesa-utils xvfb fonts-dejavu jblas unzip apt-transport-https gnupg && \
    locale-gen en_US.UTF-8 && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8


##################
# SETUP JDK      #
##################

RUN cat /etc/os-release | grep UBUNTU_CODENAME
# USING ADOPTOPENJDK (Adoptium by Temurin)
RUN apt-get install -y wget apt-transport-https gnupg
RUN wget -O - https://packages.adoptium.net/artifactory/api/gpg/key/public | tee /usr/share/keyrings/adoptium.asc
RUN echo "deb [signed-by=/usr/share/keyrings/adoptium.asc] https://packages.adoptium.net/artifactory/deb $(awk -F= '/^VERSION_CODENAME/{print$2}' /etc/os-release) main" | tee /etc/apt/sources.list.d/adoptium.list
RUN apt-get -qq update && apt-cache search temurin-11-jdk && apt-get -qqy install temurin-11-jdk && \
    apt-get clean && rm -rf /var/lib/apt/lists/* && \
    java -version && which java && echo $JAVA_HOME

ENV PATH=${PATH}:$JAVA_HOME/bin/


###################
# SETUP MAVEN     #
###################

ARG MAVEN_VERSION=3.6.3
ARG SHA=c35a1803a6e70a126e80b2b3ae33eed961f83ed74d18fcd16909b2d44d7dada3203f1ffe726c17ef8dcca2dcaa9fca676987befeadc9b9f759967a8cb77181c0
ARG BASE_URL=https://apache.osuosl.org/maven/maven-3/${MAVEN_VERSION}/binaries

RUN mkdir -p /usr/share/maven /usr/share/maven/ref \
  && curl -fsSL -o /tmp/apache-maven.tar.gz ${BASE_URL}/apache-maven-${MAVEN_VERSION}-bin.tar.gz \
  && echo "${SHA}  /tmp/apache-maven.tar.gz" | sha512sum -c - \
  && tar -xzf /tmp/apache-maven.tar.gz -C /usr/share/maven --strip-components=1 \
  && rm -f /tmp/apache-maven.tar.gz \
  && ln -s /usr/share/maven/bin/mvn /usr/bin/mvn


ENV MAVEN_HOME /usr/share/maven
ENV MAVEN_CONFIG "$USER_HOME_DIR/.m2"

COPY docker/build/maven/mvn-entrypoint.sh /usr/local/bin/mvn-entrypoint.sh
COPY docker/build/maven/settings-docker.xml /usr/share/maven/ref/

RUN mkdir -p /var/maven/.m2


###################
# SETUP PYTHON 3  #
###################

RUN apt-get update && \
	apt-get -qqy install python3 python3-requests python3-lxml python3-psutil python3-numpy python3-pymysql python3-yaml python3-matplotlib python3-cryptography python3-pip && \
	apt-get remove python3-pil -qqy && apt-get clean && rm -rf /var/lib/apt/lists/* && \
	pip3 install pillow psutil matplotlib lxml cryptography pymysql

# pillow allow to save figures in jpeg format to save disk space


###################
# SETUP Install4J #
###################

ARG INSTALL4J_VERSION=10_0_5

RUN wget https://download.ej-technologies.com/install4j/install4j_linux-x64_${INSTALL4J_VERSION}.deb -O /tmp/install4j_linux.deb --progress=dot:giga && \
	apt install -qqyf /tmp/install4j_linux.deb && \
	rm /tmp/install4j_linux.deb

###################
# SETUP QFTest    #
###################

ARG QFTEST_VERSION=4.7.2
RUN wget https://www.qfs.de/fileadmin/Webdata/pub/qftest/QF-Test-${QFTEST_VERSION}.tar.gz -O /tmp/QF-Test.tar.gz && \
	tar -xzvf /tmp/QF-Test.tar.gz -C /opt && \
	cd /opt/qftest/qftest-${QFTEST_VERSION} &&\
	./setup.sh &&\
	rm /tmp/QF-Test.tar.gz 

###################
# USER  SETUP     #
###################
WORKDIR /
RUN mkdir -p /var/maven/.m2

# RUN mkdir -p /home/${USER} && \
# 	chown 1012:1013 /home/${USER} && \
#     chmod 777 /home/${USER} && \
RUN mkdir -p /opt/scripts /opt/properties 

COPY docker/build/scripts/* /opt/scripts/
# COPY ./docker/build/properties/* /opt/properties/

ENV DEST=/opt/snap-build

RUN groupadd --gid 1013 ${USER} && \
    addgroup --gid ${DOCKER_GID} docker && \
    useradd --uid 1012 --gid 1013 -m -s /bin/bash ${USER} && \
    usermod -a -G docker ${USER}

RUN mkdir -p /local-update-center && \
    chown ${USER}:${USER} /local-update-center && \
    mkdir -p /opt/scripts && \
    mkdir -p /opt/snap-build && \
    chown ${USER}:${USER} ${DEST} && \
    chown 1012:1013 -R /var/maven

RUN mkdir -p ${DEST}/snap-installer ${DEST}/snap-installer/files ${DEST}/snap-installer/images \${DEST}/snap-desktop/snap-main/target/ ${DEST}/snap-engine \
    ${DEST}/snap-desktop/snap-application/target/snap/etc ${DEST}/snap-desktop/snap-application/target/snap/snap \ 
    ${DEST}/snap-desktop/snap-smart-configurator-ui/src/main/resources/org/esa/snap/smart/configurator/ui/ \
    ${DEST}/s1tbx/s1tbx-kit/target/netbeans_clusters/s1tbx ${DEST}/s1tbx/s1tbx-kit/target/netbeans_clusters/rstb \
    ${DEST}/s2tbx/s2tbx-kit/target/netbeans_clusters/s2tbx ${DEST}/s3tbx/s3tbx-kit/target/netbeans_clusters/s3tbx \
    ${DEST}/smos-box/smos-kit/target/netbeans_clusters/smos ${DEST}/probavbox/probavbox-kit/target/netbeans_clusters/probavbox

COPY snap.install4j LICENSE.txt VERSION.txt ${DEST}/snap-installer/
COPY files/ ${DEST}/snap-installer/files/
COPY images/ ${DEST}/snap-installer/images/
COPY LICENSE.html ${DEST}/snap-engine/
COPY etc/ ${DEST}/snap-engine/etc/
COPY snap-application/target/snap/etc/snap.clusters ${DEST}/snap-desktop/snap-application/target/snap/etc/
COPY snap-main/target/snap-main.jar ${DEST}/snap-desktop/snap-main/target/
COPY snap-application/target/snap/platform/ ${DEST}/snap-desktop/snap-application/target/snap/platform/
COPY snap-application/target/snap/ide/ ${DEST}/snap-desktop/snap-application/target/snap/ide/
COPY snap-application/target/snap/snap/ ${DEST}/snap-desktop/snap-application/target/snap/snap/
COPY snap-smart-configurator-ui/src/main/resources/org/esa/snap/smart/configurator/ui/Performance32.png ${DEST}/snap-desktop/snap-smart-configurator-ui/src/main/resources/org/esa/snap/smart/configurator/ui/
COPY snap-application/target/snap/THIRDPARTY_LICENSES.txt ${DEST}/snap-desktop/snap-application/target/snap/
COPY s1tbx-kit/target/netbeans_clusters/s1tbx/ ${DEST}/s1tbx/s1tbx-kit/target/netbeans_clusters/s1tbx/
COPY s1tbx-kit/target/netbeans_clusters/rstb/ ${DEST}/s1tbx/s1tbx-kit/target/netbeans_clusters/rstb/
COPY s2tbx-kit/target/netbeans_clusters/s2tbx/ ${DEST}/s2tbx/s2tbx-kit/target/netbeans_clusters/s2tbx/
COPY s3tbx-kit/target/netbeans_clusters/s3tbx/ ${DEST}/s3tbx/s3tbx-kit/target/netbeans_clusters/s3tbx/
COPY smos-kit/target/netbeans_clusters/smos/ ${DEST}/smos-box/smos-kit/target/netbeans_clusters/smos/
COPY probavbox-kit/target/netbeans_clusters/probavbox/ ${DEST}/probavbox/probavbox-kit/target/netbeans_clusters/probavbox/

# Create installers
ARG LICENSE
RUN install4jc -v -d ${USER_HOME_DIR} -L ${LICENSE} -m unixInstaller,macos,windows ${DEST}/snap-installer/snap.install4j && \
    chmod 777 ${USER_HOME_DIR}/esa-* && rm ${USER_HOME_DIR}/*x32* && rm ${USER_HOME_DIR}/*smos* && rm ${USER_HOME_DIR}/*sentinel* && rm -rf ${DEST}

# Install snap
WORKDIR ${USER_HOME_DIR}
RUN ./*_all_unix*.sh -q && rm ./*_all_unix*.sh

USER ${USER}
RUN sh /usr/local/bin/mvn-entrypoint.sh

# Default target platform is 'unix'
# ARG TARGET_PLATFORM=unix

# # 'unix' stage
# FROM ubuntu:22.04 as unix
# ARG DEBIAN_FRONTEND=noninteractive
# ARG USER=snap
# ARG USER_HOME_DIR="/home/snap"
# COPY --from=base /build/snap-installer/target/esa-snap_all_unix.sh USER_HOME_DIR/
# CMD [ "/home/snap/esa-snap_all_unix.sh" ]

# # 'darwin' stage
# FROM sickcodes/docker-osx:ventura as darwin
# ARG USER=snap
# ARG USER_HOME_DIR="/home/snap"
# COPY --from=base /build/snap-installer/target/esa-snap_all_macos.dmg USER_HOME_DIR/
# CMD [ "/home/snap/esa-snap_all_macos.dmg" ]

# # 'windows' stage
# FROM mcr.microsoft.com/windows/servercore:ltsc2022 as windows
# ARG USER=snap
# ARG USER_HOME_DIR="C:\Users\snap\Documents"
# COPY --from=base /build/snap-installer/target/esa-snap_all_windows-x64.exe USER_HOME_DIR/
# CMD [ "C:\Users\snap\Documents\esa-snap_all_windows-x64.exe" ]

# FROM package-${TARGET_PLATFORM} AS executable