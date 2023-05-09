#! /bin/bash

export USER_HOME_DIR=$1
export NEXUS_USER=$2
export NEXUS_PASS=$3
export UPLOAD_URL=$4

for file in $(ls ${USER_HOME_DIR});
do 
    if [[ "${file}" =~ ^esa-* ]]
    then
        export OS=$(echo "$file" | grep -oP  "(unix|windows|macos)")
        export VERSION=$(echo "$file" | grep -oP  "([0-9]{2}_[0-9]_[0-9])(-SNAPSHOT)?")
        if [[ "${file}" == *"SNAPSHOT"* ]]
        then
            echo "Uploading ${file}"
            curl -v -u ${NEXUS_USER}:${NEXUS_PASS} \
            -F "raw.directory=org/esa/snap/${OS}/${VERSION}" -F "raw.asset1=${USER_HOME_DIR}/${file}" \
            -X POST ${UPLOAD_URL}-snapshot
        else \
            echo "Uploading ${file}"
            curl -v -u ${NEXUS_USER}:${NEXUS_PASS} \
            -F "raw.directory=org/esa/snap/${OS}/${VERSION}" -F "raw.asset1=${USER_HOME_DIR}/${file}" \
            -X POST ${UPLOAD_URL}-releases
        fi
    fi
done