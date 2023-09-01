#! /bin/bash

export USER_HOME_DIR=$1
export NEXUS_USER=$2
export NEXUS_PASS=$3
export UPLOAD_URL=$4

for file in $(ls ${USER_HOME_DIR});
do 
    if [[ "${file}" =~ ^esa-snap_all* ]]
    then
        ls
        export OS=$(echo "$file" | grep -oP  "(unix|windows|macos)")
        export VERSION=pRC10
        export EXT=""
        export GROUP="installers"
        export REPO="snap-maven-releases"
        if [[ "${file}" == *".dmg"* ]] 
            then
                EXT="dmg"
        elif [[ "${file}" == *".tgz"* ]]
            then
                EXT="tgz"
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
                    -F "maven2.groupId=org.esa.snap.${GROUP}" -F "maven2.artifactId=snap_all_${OS}" -F "maven2.version=${VERSION}" \
                    -F "maven2.asset1=@${USER_HOME_DIR}/${file}" -F "maven2.asset1.extension=${EXT}" \
                    "${UPLOAD_URL}=${REPO}"
        fi
    fi
done