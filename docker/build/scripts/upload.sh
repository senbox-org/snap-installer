#! /bin/bash

export USER_HOME_DIR=$1
export NEXUS_USER=$2
export NEXUS_PASS=$3
export UPLOAD_URL=$4

for file in $(ls ${USER_HOME_DIR});
do 
    # if [[ "${file}" =~ ^esa-snap_all* ]]
    if [[ "${file}" =~ ^esa-snap* ]]
    then
        echo $file
        export OS=$(echo "$file" | grep -oP  "(unix|windows|macos)")
        export VERSION="10.0.0"
        export EXT=""
        export GROUP="installers"
        export REPO="snap-maven-releases"
        export TYPE="all"
        if [[ "${file}" == *"sentinel"* ]]
            then
                TYPE="sentinel"
        elif [[ "${file}" == *"smos"* ]]
            then
                TYPE="smos"
        fi
        if [[ "${file}" == *".dmg"* ]]
            then
                EXT="dmg"
                if [[ "${file}" == *"archive"* ]]
                    then
                        OS="macos_archive"
                elif [[ "${file}" == *"arm"* ]]
                    then
                        OS="macos_arm"
                elif [[ "${file}" == *"intel"* ]]
                    then
                        OS="macos_intel"
                fi
        elif [[ "${file}" == *".exe"* ]]
            then
                EXT="exe"
        else
            EXT="sh"
        fi
        if [[ "${file}" == *"SNAPSHOT"* ]]
            then
                GROUP="installers-snapshot"
        fi
        if [[ "${file}" != "*x32*" ]]
            then
                echo "Uploading ${file} to ${REPO}"
                curl -u ${NEXUS_USER}:${NEXUS_PASS} --progress-bar \
                    -F "maven2.groupId=org.esa.snap.${GROUP}" -F "maven2.artifactId=snap_${TYPE}_${OS}" -F "maven2.version=${VERSION}" \
                    -F "maven2.asset1=@${USER_HOME_DIR}/${file}" -F "maven2.asset1.extension=${EXT}" \
                    "${UPLOAD_URL}=${REPO}"
        fi
    fi
done