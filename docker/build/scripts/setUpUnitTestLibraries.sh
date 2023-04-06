#! /bin/bash

# Download deps
mvn -Duser.home=/var/maven -Dsnap.userdir=/home/snap install deploy -DskipTests=true

export WORKSPACE_PATH=`pwd`

# Set up OpenJPEG
echo 'Using  SNAP engine openJPEG'
#export OPENJPEG_VERSION=`cat pom.xml | grep '<version>' | head -1 | cut -d '>' -f 2 | cut -d '<' -f 1`
#echo ${OPENJPEG_VERSION}
#mkdir -p /home/snap/auxdata/openjpeg/${OPENJPEG_VERSION}
#cp -r lib-openjpeg/src/main/resources/auxdata/openjpeg/* /home/snap/auxdata/openjpeg/${OPENJPEG_VERSION}
#chmod 755 -R /home/snap/auxdata/openjpeg/${OPENJPEG_VERSION}/*/bin
export OPENJPEG_VERSION=`ls /var/tmp/repository/org/esa/snap/lib-openjpeg/`
cd /var/tmp/repository/org/esa/snap/lib-openjpeg/${OPENJPEG_VERSION}
unzip lib-openjpeg-${OPENJPEG_VERSION}.jar
mkdir -p /home/snap/auxdata/openjpeg/${OPENJPEG_VERSION}
cp -r auxdata/openjpeg/* /home/snap/auxdata/openjpeg/${OPENJPEG_VERSION}
chmod 755 -R /home/snap/auxdata/openjpeg/${OPENJPEG_VERSION}/*/bin


# Set up GDAL is currently not required for Unit Tests

#export GDAL_VERSION=`ls /var/tmp/repository/org/esa/s2tbx/lib-gdal/`
#cd /var/tmp/repository/org/esa/s2tbx/lib-gdal/${GDAL_VERSION}
#unzip lib-gdal-${GDAL_VERSION}.jar
#mkdir -p /home/snap/auxdata/openjpeg/${OPENJPEG_VERSION}
#cp -r auxdata/gdal /home/snap/auxdata/
#cd /home/snap/auxdata/gdal/gdal-*linux
#unzip *.zip
#chmod 755 -R bin/*

# Update LD_LIBRARY_PATH Library
#export LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:/lib/:/lib/x86_64-linux-gnu/:/usr/lib/:/home/snap/auxdata/gdal/:/home/snap/auxdata/gdal/gdal-2.2.0-linux/lib/:/home/snap/auxdata/g$
