# snap-installer

Installer(s) for SNAP and its add-ons.

The SNAP installer is build with the install4j install system.
There is an updateall.bat which pulls and builds all SNAP repositories found.
Use it before you use the install4j.

Note that if you install CoreUtils for Windows (http://gnuwin32.sourceforge.net/packages/coreutils.htm)
to ``tee`` updateall.bat's output to console and to updateall.log file.

## CI pipeline

1. Installers are built inside a container from docker/build/Dockerfile 
2. Executables files are uploaded to Nexus with `cURL`
3. docker images are published to Nexus

> For MacOS 2 bundles are generated: 
> `macosFolder` which is not suitable for CI
> `macosArchive` usable for CI but only *all* installer available at the moment

## Locally

### Make installers with docker

You can either build it as usual or use docker.
In case you want to build the docker image locally

`export LICENCE=<install4j_license>`

`docker build -f docker/build/Dockerfile . --rm --build-arg=LICENSE --build-arg UPLOAD_URL="https://nexus.snap-ci.ovh/service/rest/v1/components?repository=snap-intallers" --build-arg NEXUS_USER="$NEXUS_USER" --build-arg NEXUS_PASS="$NEXUS_PASS" -t docker-hosted.snap-ci.ovh/snap-installer:latest`

Then `docker run -i -l snap-installer docker-hosted.snap-ci.ovh/snap-installer:latest`

### Pull snap docker image

`docker pull docker.snap-ci.ovh/snap-installer:latest`

Then `docker run -i -l snap-installer docker.snap-ci.ovh/snap-installer:latest`