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

## Locally

### Make installers with docker

You can either build it as usual or use docker.
In case you want to build the docker image locally

`export LICENCE=<install4j_license>`

`docker build -f docker/build/Dockerfile . -t snap/snap-installer:latest --rm --build-arg=LICENSE`

Then `docker run -i -l snap-installer snap/snap-installer:latest`

### Build Windows Dockerfile

`export SNAP_WIN_DOWLOAD_URL=<url_to_exe_file>`

If `SNAP_WIN_DOWLOAD_URL` is not provided, snap is downloaded from step website.

`docker build -f docker/build/Dockerfile . -t snap/snap-installer:win-latest --rm --build-arg=SNAP_WIN_DOWLOAD_URL`