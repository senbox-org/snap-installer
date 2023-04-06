#! /bin/bash

if [ $# -ne 4 ]
then
    echo "Usage $0 nbmSrcDirectory nbmDestDirectory branchVersion toolName"
    echo "nbmSrcDirectory: Directory where this script will do a recursive search to find nbm files"
    echo "nbmDestDirectory: Directory where the nbm files will be copied"
    echo "branchVersion: to know if we must copy binaries in case of master or *.x branch"
    echo "toolName: one of s1tbx, s2tbx, s3tbx, snap-desktop, snap-engine"
fi

export NBM_SRC_DIR_NAME=$1
export NBM_DEST_DIR_NAME=$2
export BRANCH_VERSION=$3
export TOOL_NAME=$4

echo "Delete directory /local-update-center/${NBM_DEST_DIR_NAME} if exists"
rm -rf /local-update-center/${NBM_DEST_DIR_NAME}
echo "Create dest nbm directory: /local-update-center/${NBM_DEST_DIR_NAME}"
mkdir -p "/local-update-center/${NBM_DEST_DIR_NAME}"
echo "Copy all nbm from ${NBM_SRC_DIR_NAME} to dest nbm directory"
find ${NBM_SRC_DIR_NAME} -name "*.nbm" -exec cp {} /local-update-center/${NBM_DEST_DIR_NAME} \;
# Copy to tool/branch to be available if master, 6.x
if [ "${branchVersion}" == "master" ] || [[ "${branchVersion}" =~ .?.x ]] || [ "${branchVersion}" == "testJenkins_validation" ]
then
    echo "Copy also *.nbm to /local-update-center/${TOOL_NAME}/${BRANCH_VERSION}"
    rm -rf /local-update-center/${TOOL_NAME}/${BRANCH_VERSION}
    mkdir -p /local-update-center/${TOOL_NAME}/${BRANCH_VERSION}
    find ${NBM_SRC_DIR_NAME} -name "*.nbm" -exec cp {} /local-update-center/${TOOL_NAME}/${BRANCH_VERSION} \;
fi

