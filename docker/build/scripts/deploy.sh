#! /bin/bash

if [ $# -ne 5 ] && [ $# -ne 7 ]
then
	echo "Usage $0 snapMajorVersion nbmDestDirectory currentBranch jobName maintenanceBranch listOfProjects(optional) tagName(optional)"
	echo "snapMajorVersion: snap major version (Ex: 7)"
	echo "nbmDestDirectory: Directory where the nbm files are stored"
	echo "currentBranch: current branch"
	echo "jobName : one of s1tbx s2tbx s3tbx snap-engine snap-desktop"
	echo "maintenanceBranch : true (deploy maintenance branch with .nbm files) or false (deploy without .nbm files)"
	echo "listOfProjects : list of projects used for updates separated by commas"
	echo "tagName : tag for the docker. Mandatory if listOf Projects has been provided"
	exit 1
fi


export SNAP_MAJOR_VERSION=$1
export NBM_DIR_NAME=$2
export CURRENT_BRANCH=$3
export JOB_NAME=$4
export MAINTENANCE_BRANCH=$5

if [ $# -eq 7 ]
then
	orig=$6	
	export PROJECTS=${orig//,/ }
        export TAGNAME=$7
else
	export PROJECTS="s1tbx s2tbx s3tbx snap-engine snap-desktop"
        export TAGNAME=${CURRENT_BRANCH}
fi


if [ "${MAINTENANCE_BRANCH}" = "true" ] || [ "${CURRENT_BRANCH}" != "master" ] && [[ ! "${CURRENT_BRANCH}" =~ [0-9]+\.[0-9]+\.[0-9]+(-rc[0-9]+)?$ ]]
then
	# Branch is not master and not x.x.x (ex: 8.0.0) and not x.x.x-rcx (ex: 8.0.0-rc1) => We use nbm files

	# Create a temporary build directory
	mkdir /local-update-center/${NBM_DIR_NAME}/build
	cp /local-update-center/${NBM_DIR_NAME}/*.nbm /local-update-center/${NBM_DIR_NAME}/build

        echo "Copy nbm from other projects if available"
        echo "Projects: ${PROJECTS}"
        for nbmDir in ${PROJECTS}
        do
            if [ "${nbmDir}" != "${JOB_NAME}" ] && [ -d /local-update-center/${nbmDir}/${CURRENT_BRANCH} ]
            then
                # search for nbm files in other projects with same branch name
                find /local-update-center/${nbmDir}/${CURRENT_BRANCH} -name "*.nbm" -exec cp {} /local-update-center/${NBM_DIR_NAME}/build \;
            else
                if [ "${nbmDir}" != "${JOB_NAME}" ]
                then
                    echo "No nbm available for ${nbmDir} project and branch ${CURRENT_BRANCH}"
                else
                    echo "Skipping for ${nbmDir} project"
                fi
           fi
        done
	
	echo "Generate updates.xml file"
	python /opt/scripts/generate_updates_xml.py /local-update-center/${NBM_DIR_NAME}/build
	echo "Create updated snap image to be used to launch tests"
	echo FROM snap-build-server.tilaa.cloud/snap:${SNAP_MAJOR_VERSION=}.0.0 > /local-update-center/${NBM_DIR_NAME}/build/Dockerfile
	echo 'ADD ./*.nbm /local-update-center/' >> /local-update-center/${NBM_DIR_NAME}/build/Dockerfile
	echo 'ADD ./updates.xml /local-update-center/' >> /local-update-center/${NBM_DIR_NAME}/build/Dockerfile
	echo 'RUN /opt/scripts/moduleUpdate.sh' >> /local-update-center/${NBM_DIR_NAME}/build/Dockerfile
	#echo 'USER root' >> /local-update-center/${NBM_DIR_NAME}/build/Dockerfile
	#echo 'RUN rm -rf /local-update-center/*' >> /local-update-center/${NBM_DIR_NAME}/build/Dockerfile
	echo 'USER snap' >> /local-update-center/${NBM_DIR_NAME}/build/Dockerfile
	echo 'ENV LANG en_US.ISO-8859-1' >> /local-update-center/${NBM_DIR_NAME}/build/Dockerfile
	more /local-update-center/${NBM_DIR_NAME}/build/Dockerfile
	cd /local-update-center/${NBM_DIR_NAME}/build/ && docker build . -t snap-build-server.tilaa.cloud/snap:${TAGNAME}
	# No need to push on build server (too much disk space required)
	# docker push snap-build-server.tilaa.cloud/snap:${CURRENT_BRANCH}

	rm -rf /local-update-center/${NBM_DIR_NAME}/build

else
    # Branch is master or x.x.x (ex: 8.0.0) or x.x.x-rcx (ex: 8.0.0-rc1) => we don't use .nbm files, we use the snap intaller
    
    # Copy installer from volume
    cp /snap-installer/${CURRENT_BRANCH}/target/esa-snap_all_unix_*.sh /opt/snap-build
    cd /opt/snap-build
    echo "build docker image snap-build-server.tilaa.cloud/snap:${CURRENT_BRANCH}"
    docker build --build-arg UPDATE_SNAP=false . -t snap-build-server.tilaa.cloud/snap:${TAGNAME}
fi


#if [ "${CURRENT_BRANCH}" == "master" ] || [[ "${CURRENT_BRANCH}" =~ [0-9]+\.x ]] || [[ "${CURRENT_BRANCH}" =~ [0-9]+\.[0-9]+\.[0-9]+(-rc[0-9]+)?$ ]]
#then
#	echo "Push snap:${CURRENT_BRANCH} docker image"
#	docker tag snap-build-server.tilaa.cloud/${DOCKER_NAME} snap-build-server.tilaa.cloud/snap:${CURRENT_BRANCH}
#	# docker push snap-build-server.tilaa.cloud/snap:${CURRENT_BRANCH}
#fi
