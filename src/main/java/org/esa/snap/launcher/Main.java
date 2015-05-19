package org.esa.snap.launcher;

import java.io.File;
import java.io.IOException;

/**
 * Main launcher for both NetBeans executables and other SNAP-based Java apps.
 */
public class Main {

    public static void main(String[] args) {
        String property = System.getProperty("snap.home");
        if (property == null) {
            fail();
        }
        File installDir = new File(property);
        if (!installDir.isDirectory()) {
            fail();
        }

        File binDir = new File(installDir, "bin");
        String[] fileNames = binDir.list((dir, name) -> !name.startsWith("run") && !name.endsWith(".jar") && new File(dir, name).canExecute());
        if (fileNames == null) {
            fail();
        }

        for (String fileName : fileNames) {
            ProcessBuilder processBuilder = new ProcessBuilder();
            ProcessBuilder command = processBuilder.directory(binDir).command(fileName);
            try {
                command.start();
            } catch (IOException e) {
                // ok
            }
        }
    }

    private static void fail() {
        throw new Error("System property 'snap.home' must point to a valid SNAP application directory'");
    }
}
