#! /bin/bash

export USER_HOME_DIR=$1
export NEXUS_USER=$2
export NEXUS_PASS=$3
export UPLOAD_URL=$4

for file in $(ls ${USER_HOME_DIR});
do 
    if [[ "${file}" =~ ^esa-snap_all* ]]
    then
        export OS=$(echo "$file" | grep -oP  "(unix|windows|macos)")
        export VERSION=$(echo "$file" | grep -oP  "([0-9]{1,2})(_)([0-9]*)(_)([0-9]*)")
        export EXT=""
        export GROUP="installers"
        if [[ "${file}" == *".dmg"* ]]
            then
                EXT="dmg"
        elif [[ "${file}" == *".exe"* ]]
            then
                EXT="exe"
            else \
                EXT="sh"
        fi
        if [[ "${file}" == *"SNAPSHOT"* ]]
            then
                GROUP="installers-snapshot"
        fi
        if [[ "${file}" != "*x32*" ]]
            then
                echo "Uploading ${file} to ${UPLOAD_URL}"
                curl -u ${NEXUS_USER}:${NEXUS_PASS} --progress-bar \
                    -F "maven2.groupId=org.esa.snap.${GROUP}" -F "maven2.artifactId=snap_all_${OS}" -F "maven2.version=${VERSION}" \
                    -F "maven2.asset1=@${USER_HOME_DIR}/${file}" -F "maven2.asset1.extension=${EXT}" \
                    "${UPLOAD_URL}"
        fi
    fi
done