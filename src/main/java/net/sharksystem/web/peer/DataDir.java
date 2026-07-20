package net.sharksystem.web.peer;

import java.nio.file.Path;
import java.nio.file.Paths;

/**
 * Resolves the base directory for all persistent peer data.
 *
 * <p>Resolution order:</p>
 * <ol>
 *   <li>System property {@code -Dsnm.data.dir=/absolute/path}</li>
 *   <li>Environment variable {@code SNM_DATA_DIR} (set by scripts/start.sh)</li>
 *   <li>Fallback: {@code data} relative to the current working directory
 *       (previous behaviour &mdash; only works when Tomcat is started from
 *       the project root)</li>
 * </ol>
 */
public final class DataDir {

    private DataDir() {
        // utility class
    }

    /** Base data directory as an absolute, normalized path. */
    public static Path base() {
        String configured = System.getProperty("snm.data.dir");
        if (configured == null || configured.isBlank()) {
            configured = System.getenv("SNM_DATA_DIR");
        }
        if (configured == null || configured.isBlank()) {
            configured = "data";
        }
        return Paths.get(configured).toAbsolutePath().normalize();
    }

    /** Resolve a path inside the base data directory. */
    public static Path resolve(String... parts) {
        Path path = base();
        for (String part : parts) {
            path = path.resolve(part);
        }
        return path;
    }
}
