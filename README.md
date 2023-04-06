# snap-installer

Installer(s) for SNAP and its add-ons.

The SNAP installer is build with the install4j install system.
There is an updateall.bat which pulls and builds all SNAP repositories found.
Use it before you use the install4j.

Note that if you install CoreUtils for Windows (http://gnuwin32.sourceforge.net/packages/coreutils.htm)
to ``tee`` updateall.bat's output to console and to updateall.log file.

## CI pipeline

1. Installers are built inside a container from docker/build/Dockerfile
2. Executables files are uploaded to Nexus with `mvn deploy-file` plugin
3. docker image is published to Nexus as well