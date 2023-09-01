FROM ubuntu:22.04 AS base

ARG DEBIAN_FRONTEND=noninteractive
ARG USER=snap
ARG USER_HOME_DIR="/home/snap"
ARG DOCKER_GID=999


##################
# SETUP UBUNTU   #
##################

RUN apt-get -qq update && apt-get -qqy upgrade && apt-get -qqy install --no-install-recommends gnupg2 locales wget curl bc git ca-certificates
RUN apt-get -qqy install libxext6 libxrender1 libxtst6 libxi6 libxxf86dga1 libxxf86vm1 libgfortran5 mesa-utils xvfb fonts-dejavu jblas unzip apt-transport-https gnupg libhdf5-serial-dev && \
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
RUN wget -O - https://packages.adoptium.net/artifactory/api/gpg/key/public | apt-key add -
RUN echo "deb https://packages.adoptium.net/artifactory/deb $(awk -F= '/^VERSION_CODENAME/{print$2}' /etc/os-release) main" | tee /etc/apt/sources.list.d/adoptium.list
RUN apt-get -qq update && apt-cache search temurin-11-jdk && apt-get -qqy install temurin-11-jdk && \
    apt-get clean && rm -rf /var/lib/apt/lists/* && \
    java -version && which java && echo $JAVA_HOME

ENV PATH=${PATH}:$JAVA_HOME/bin/


###################
# SETUP MAVEN     #
###################

ARG MAVEN_VERSION=3.9.2
ARG SHA=900bdeeeae550d2d2b3920fe0e00e41b0069f32c019d566465015bdd1b3866395cbe016e22d95d25d51d3a5e614af2c83ec9b282d73309f644859bbad08b63db
ARG MVN_URL=https://archive.apache.org/dist/maven/maven-3/${MAVEN_VERSION}/binaries

RUN mkdir -p /usr/share/maven /usr/share/maven/ref \
  && curl -fsSL -o /tmp/apache-maven.tar.gz ${MVN_URL}/apache-maven-${MAVEN_VERSION}-bin.tar.gz \
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
RUN apt-get update && apt-get -qqy install --no-install-recommends python3 python3-pip \
    # python3-requests \
    # python3-lxml \
    # python3-psutil \
    # python3-numpy \
    # python3-pymysql \
    # python3-yaml \
    # python3-matplotlib \
    # python3-cryptography \
    # python3-pip \
&& apt-get remove python3-pil -qqy \
&& rm -rf /var/lib/apt/lists/*
#  \
# && pip3 install --no-cache-dir pillow psutil matplotlib lxml cryptography pymysql
# pillow allow to save figures in jpeg format to save disk space

##################
#     AWS CLI    #
##################

RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o awscliv2.zip \
    && unzip awscliv2.zip \
    && rm -f awscliv2.zip \
    && ./aws/install >/dev/null \
    && rm -rf ./aws

###################
# SETUP QFTest    #
###################

# ARG QFTEST_VERSION=4.7.2
# RUN wget https://www.qfs.de/fileadmin/Webdata/pub/qftest/QF-Test-${QFTEST_VERSION}.tar.gz -O /tmp/QF-Test.tar.gz -q --progress=dot:giga && \
# 	tar -xzvf /tmp/QF-Test.tar.gz -C /opt && \
# 	cd /opt/qftest/qftest-${QFTEST_VERSION} &&\
# 	./setup.sh &&\
# 	rm /tmp/QF-Test.tar.gz 

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
ENV SNAP_DIR=/home/snap/esa-snap-software

RUN groupadd --gid 1013 ${USER} && \
    addgroup --gid ${DOCKER_GID} docker && \
    useradd --uid 1012 --gid 1013 -m -s /bin/bash ${USER} && \
    usermod -aG docker ${USER} && \
    usermod -aG sudo ${USER}

RUN mkdir -p /local-update-center && \
    chown ${USER}:${USER} /local-update-center && \
    mkdir -p /opt/scripts && \
    mkdir -p ${DEST} ${SNAP_DIR} && \
    chown ${USER}:${USER} ${DEST} && \
    chown ${USER}:${USER} ${SNAP_DIR} && \
    chown 1012:1013 -R /var/maven

FROM base AS installer

###################
# SETUP Install4J #
###################

ARG INSTALL4J_VERSION=10_0_5

RUN wget -nv https://download.ej-technologies.com/install4j/install4j_linux-x64_${INSTALL4J_VERSION}.deb -O /tmp/install4j_linux.deb && \
	apt-get install -qqyf /tmp/install4j_linux.deb && \
	rm /tmp/install4j_linux.deb

RUN mkdir -p ${DEST}/snap-installer ${DEST}/snap-installer/files ${DEST}/snap-installer/images \${DEST}/snap-desktop/snap-main/target/ ${DEST}/snap-engine \
    ${DEST}/snap-desktop/snap-application/target/snap/etc ${DEST}/snap-desktop/snap-application/target/snap/snap \ 
    ${DEST}/snap-desktop/snap-smart-configurator-ui/src/main/resources/org/esa/snap/smart/configurator/ui/ \
    ${DEST}/smos-box/smos-kit/target/netbeans_clusters/smos ${DEST}/microwavetbx-kit/target/netbeans_clusters/rstb/ \
    ${DEST}/opttbx-kit/target/netbeans_clusters/opttbx/

COPY snap.install4j LICENSE.txt VERSION.txt ${DEST}/snap-installer/
COPY files/ ${DEST}/snap-installer/files/
COPY images/ ${DEST}/snap-installer/images/
COPY LICENSE.html ${DEST}/snap-engine/
COPY etc/ ${DEST}/snap-engine/etc/
COPY snap-application/target/snap/etc/snap.clusters ${DEST}/snap-desktop/snap-application/target/snap/etc/
COPY snap-main/target/snap-main.jar ${DEST}/snap-desktop/snap-main/target/
COPY snap-application/target/snap/platform/ ${DEST}/snap-desktop/snap-application/target/snap/platform/
COPY snap-application/target/snap/ide/ ${DEST}/snap-desktop/snap-application/target/snap/ide/
COPY snap-application/target/snap/snap/config/Modules/*.xml ${DEST}/snap-desktop/snap-application/target/snap/snap/config/Modules/
COPY snap-application/target/snap/snap/core/ ${DEST}/snap-desktop/snap-application/target/snap/snap/core/
COPY snap-application/target/snap/snap/modules/ ${DEST}/snap-desktop/snap-application/target/snap/snap/modules/
COPY snap-application/target/snap/snap/modules/* ${DEST}/snap-desktop/snap-application/target/snap/snap/modules/
COPY snap-smart-configurator-ui/src/main/resources/org/esa/snap/smart/configurator/ui/Performance32.png ${DEST}/snap-desktop/snap-smart-configurator-ui/src/main/resources/org/esa/snap/smart/configurator/ui/
COPY snap-application/target/snap/THIRDPARTY_LICENSES.txt ${DEST}/snap-desktop/snap-application/target/snap/
COPY microwavetbx-kit/target/netbeans_clusters/microwavetbx ${DEST}/microwave-toolbox/microwavetbx-kit/target/netbeans_clusters/microwavetbx/
COPY microwavetbx-kit/target/netbeans_clusters/rstb ${DEST}/microwave-toolbox/microwavetbx-kit/target/netbeans_clusters/rstb/
COPY opttbx-kit/target/netbeans_clusters/opttbx ${DEST}/optical-toolbox/opttbx-kit/target/netbeans_clusters/opttbx/
COPY smos-kit/target/netbeans_clusters/smos/ ${DEST}/smos-box/smos-kit/target/netbeans_clusters/smos/

# Create installers
ARG LICENSE
ARG USER_HOME_DIR="/home/snap"
ARG CSC_KEY_PASSWORD

RUN install4jc -q -d ${USER_HOME_DIR} -L ${LICENSE} -m unixInstaller,macosFolderArchive,macosArchive,windows --mac-keystore-password=${CSC_KEY_PASSWORD} \
    ${DEST}/snap-installer/snap.install4j && \
    chmod 777 ${USER_HOME_DIR}/esa-* && \
    rm ${USER_HOME_DIR}/*x32* && rm ${USER_HOME_DIR}/*smos* && rm ${USER_HOME_DIR}/*sentinel* && \
    rm -rf ${DEST}

USER snap
RUN ${USER_HOME_DIR}/*_all_unix* -q -dir /home/snap/esa-snap-software

# Deploy installers
ARG UPLOAD_URL
ARG NEXUS_USER
ARG NEXUS_PASS

COPY docker/build/scripts/upload.sh /opt/scripts/upload.sh

RUN /opt/scripts/upload.sh ${USER_HOME_DIR} ${NEXUS_USER} ${NEXUS_PASS} ${UPLOAD_URL}

FROM base AS unix

ENV SNAP_DIR="/home/snap/esa-snap-software"

WORKDIR ${SNAP_DIR}

COPY --chown=snap:snap --chmod=755 --from=installer ${SNAP_DIR}/ ${SNAP_DIR}/

# Allow GPT test custom JVM options
RUN chmod -R 755 ${SNAP_DIR}

USER snap
RUN sh /usr/local/bin/mvn-entrypoint.sh