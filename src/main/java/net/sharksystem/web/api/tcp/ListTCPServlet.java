package net.sharksystem.web.api.tcp;

import com.google.gson.Gson;
import com.google.gson.JsonArray;
import com.google.gson.JsonObject;
import jakarta.servlet.http.HttpServlet;
import net.sharksystem.web.peer.PeerRuntime;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import net.sharksystem.web.peer.PeerRuntimeManager;
import net.sharksystem.asap.ASAPEncounterConnectionType;

import java.util.Map;
import java.util.Set;
import java.util.List;
import java.util.HashSet;
import java.util.ArrayList;
import java.io.IOException;

/**
 * API to list open TCP ports on the peer.
 *
 * POST /api/tcp/list
 * Body: { "peerId": "peerId_xxx" }
 */
@WebServlet("/api/tcp/list")
public class ListTCPServlet extends HttpServlet {

    // Max gap between a connection's tracked timestamp and an encounter's start time
    // for the two to still be considered the same event.
    private static final long CORRELATION_TOLERANCE_MS = 5000;

    private final PeerRuntimeManager manager = PeerRuntimeManager.getInstance();
    private final Gson gson = new Gson();

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        JsonObject response = new JsonObject();
        JsonObject body = gson.fromJson(req.getReader(), JsonObject.class);

        if (body == null || !body.has("peerId")) {
            resp.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.addProperty("msg", "Missing peerId in request body");
            resp.setContentType("application/json");
            resp.getWriter().write(gson.toJson(response));
            return;
        }

        String peerId = body.get("peerId").getAsString();
        PeerRuntime peer = manager.getPeer(peerId);

        if (peer == null || !peer.isActive()) {
            resp.setStatus(HttpServletResponse.SC_NOT_FOUND);
            response.addProperty("msg", "Peer not found or not active");
            resp.setContentType("application/json");
            resp.getWriter().write(gson.toJson(response));
            return;
        }

        // Collect open TCP ports
        Map<Integer, ?> openSockets = peer.getOpenSockets();
        JsonArray portsArray = new JsonArray();
        for (Integer port : openSockets.keySet()) {
            portsArray.add(port);
        }

        response.addProperty("peerId", peerId);
        response.add("openPorts", portsArray);

        // Collect active connections (clients), correlated with encounter log entries
        // (same data source as PeerStatusServlet's encounters array) to recover the peer ID.
        JsonArray connectionsArray = new JsonArray();

        List<PeerRuntime.EncounterLog> tcpEncounters = new ArrayList<>();
        for (List<PeerRuntime.EncounterLog> logs : peer.getEncounterLogs().values()) {
            for (PeerRuntime.EncounterLog log : logs) {
                if (log.type == ASAPEncounterConnectionType.INTERNET) {
                    tcpEncounters.add(log);
                }
            }
        }
        Set<PeerRuntime.EncounterLog> matchedEncounters = new HashSet<>();

        for (PeerRuntime.ConnectionInfo info : peer.getActiveConnections()) {
            JsonObject conn = new JsonObject();
            conn.addProperty("remoteAddress", info.host);
            conn.addProperty("remotePort", info.port);
            conn.addProperty("timestamp", info.timestamp);

            // Best-effort match: nearest not-yet-used TCP encounter by start time,
            // since connectTCP() logs the encounter right before tracking the connection.
            PeerRuntime.EncounterLog bestMatch = null;
            long bestDiff = Long.MAX_VALUE;
            for (PeerRuntime.EncounterLog log : tcpEncounters) {
                if (matchedEncounters.contains(log)) continue;
                long diff = Math.abs(log.startTime - info.timestamp);
                if (diff < bestDiff) {
                    bestDiff = diff;
                    bestMatch = log;
                }
            }

            if (bestMatch != null && bestDiff <= CORRELATION_TOLERANCE_MS) {
                matchedEncounters.add(bestMatch);
                conn.addProperty("peerID", bestMatch.peerID.toString());
            }

            connectionsArray.add(conn);
        }
        response.add("connections", connectionsArray);

        resp.setStatus(HttpServletResponse.SC_OK);
        resp.setContentType("application/json");
        resp.getWriter().write(gson.toJson(response));
    }
}
