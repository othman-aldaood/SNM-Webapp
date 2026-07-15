package net.sharksystem.web.api.messenger;

import com.google.gson.JsonObject;
import com.google.gson.JsonParser;
import net.sharksystem.SharkException;
import jakarta.servlet.http.HttpServlet;
import net.sharksystem.asap.ASAPException;
import net.sharksystem.web.peer.PeerRuntime;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import net.sharksystem.asap.persons.PersonValues;
import net.sharksystem.web.peer.PeerRuntimeManager;
import net.sharksystem.app.messenger.SharkNetMessage;
import net.sharksystem.app.messenger.SharkNetMessageList;
import net.sharksystem.app.messenger.SharkNetMessengerChannel;
import net.sharksystem.app.messenger.SharkNetMessengerComponent;
import static net.sharksystem.web.api.pki.WebPKIUtils.getUniquePersonValues;

import java.util.Date;
import java.io.IOException;
import java.text.SimpleDateFormat;
import java.nio.charset.StandardCharsets;

/**
 * API to send a messenger message.
 *
 * POST /api/messenger/messages
 *
 * Body parameters:
 * - content: String, the message content
 * - contentType: String, the content type (optional, default: ASAP_CHARACTER_SEQUENCE)
 * - sign: boolean, whether to sign the message (optional, default: true)
 * - encrypt: boolean, whether to encrypt the message (optional, default: false)
 * - receiver: String, the receiver's name or ANY_SHARKNET_PEER (optional, default: ANY_SHARKNET_PEER)
 * - channelIndex: int, the index of the channel to use (optional, default: 1)
 */
@WebServlet("/api/messenger/messages")
public class MessageServlet extends HttpServlet {

    private final PeerRuntimeManager manager = PeerRuntimeManager.getInstance();

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws IOException {

        PeerRuntime peer = manager.getActivePeer();
        if (peer == null) {
            sendError(resp, "no active peer");
            return;
        }

        JsonObject body = JsonParser.parseReader(req.getReader()).getAsJsonObject();

        String content = body.get("content").getAsString();
        if (content == null) {
             sendError(resp, "content is required");
            return;
        }

        String contentType = body.has("contentType")
                ? body.get("contentType").getAsString()
                : SharkNetMessage.SN_CONTENT_TYPE_ASAP_CHARACTER_SEQUENCE;

        boolean sign = !body.has("sign") || body.get("sign").getAsBoolean();
        boolean encrypt = body.has("encrypt") && body.get("encrypt").getAsBoolean();

        String receiverName = body.has("receiver")
                ? body.get("receiver").getAsString()
                : SharkNetMessage.ANY_SHARKNET_PEER;

        int channelIndex = body.has("channelIndex")
                ? body.get("channelIndex").getAsInt()
                : 1;

        try {
            SharkNetMessengerComponent messenger = peer.getMessengerComponent();

            // Resolve channel
            CharSequence channelURI;
            try {
                SharkNetMessengerChannel channel =
                        messenger.getChannel(channelIndex - 1);
                channelURI = channel.getURI();
            } catch (SharkException se) {
                if (channelIndex == 1) {
                    channelURI = SharkNetMessengerComponent.GENERAL_CHANNEL_URI;
                } else {
                    sendError(resp, "invalid channel index");
                    return;
                }
            }

            // Resolve receiver
            CharSequence receiverID = receiverName;
            if (!receiverName.equalsIgnoreCase(SharkNetMessage.ANY_SHARKNET_PEER)) {
                PersonValues pv =
                        getUniquePersonValues(receiverName, peer.getPkiComponent());
                receiverID = pv.getUserID();
            }

            // Serialize content as plain UTF-8 bytes. Do NOT wrap it via
            // ASAPSerialization.writeCharSequenceParameter() here - that prepends a 4-byte
            // length header meant for framing multiple parameters inside ASAP management
            // messages. SharkNetMessage.getContent() (used by ListMessagesServlet) returns
            // these bytes verbatim with no such framing removed, so wrapping them here corrupted
            // every message's displayed content with leading NUL/control bytes (visible as
            // "???"/garbled characters, most noticeable when opening a message for editing).
            byte[] contentBytes = content.getBytes(StandardCharsets.UTF_8);

            // Send message
            messenger.sendSharkMessage(
                    contentType,
                    contentBytes,
                    channelURI,
                    receiverID,
                    sign,
                    encrypt
            );

            // Response
            JsonObject response = new JsonObject();
            response.addProperty("msg", "message sent");
            response.addProperty("channelIndex", channelIndex);
            response.addProperty("receiver", receiverName);
            response.addProperty("signed", sign);
            response.addProperty("encrypted", encrypt);

            resp.setStatus(HttpServletResponse.SC_OK);
            resp.setContentType("application/json");
            resp.getWriter().write(response.toString());

        } catch (ASAPException e) {
            sendError(resp, e.getMessage());
        }
        catch (SharkException e) {
            sendError(resp, e.getMessage());
        }
    }

    /**
     * Edits a message.
     *
     * PUT /api/messenger/messages
     * Body: { "messageId": "<creation timestamp>", "channelIndex": int, "content": "new text" }
     *
     * The underlying SharkNetMessage store is append-only (no update API exists), so this
     * records a peer-local content override keyed by the message's creation timestamp -
     * which is exactly what ListMessagesServlet already exposes to (and what the frontend
     * already sends back as) the message's id - rather than rewriting anything in storage.
     */
    @Override
    protected void doPut(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        PeerRuntime peer = manager.getActivePeer();
        if (peer == null) {
            sendError(resp, "no active peer");
            return;
        }

        JsonObject body = JsonParser.parseReader(req.getReader()).getAsJsonObject();

        if (!body.has("messageId") || !body.has("content")) {
            sendError(resp, "messageId and content are required");
            return;
        }

        String messageId = body.get("messageId").getAsString();
        String content = body.get("content").getAsString();
        int channelIndex = body.has("channelIndex") ? body.get("channelIndex").getAsInt() : 1;

        try {
            SharkNetMessengerComponent messenger = peer.getMessengerComponent();
            CharSequence channelURI = resolveChannelURI(messenger, channelIndex);

            if (!messageExists(messenger, channelURI, messageId)) {
                sendError(resp, HttpServletResponse.SC_NOT_FOUND, "message not found");
                return;
            }

            peer.markMessageEdited(channelURI, messageId, content);

            JsonObject response = new JsonObject();
            response.addProperty("msg", "message updated");
            response.addProperty("messageId", messageId);
            resp.setStatus(HttpServletResponse.SC_OK);
            resp.setContentType("application/json");
            resp.getWriter().write(response.toString());
        } catch (SharkException e) {
            sendError(resp, e.getMessage());
        }
    }

    /**
     * Deletes a message.
     *
     * DELETE /api/messenger/messages?msgId=<creation timestamp>&channelIndex=<int>
     *
     * Records a peer-local tombstone for this message (keyed the same way as edits, above)
     * so ListMessagesServlet omits it from future responses - the message itself cannot be
     * removed from the append-only underlying store.
     */
    @Override
    protected void doDelete(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        PeerRuntime peer = manager.getActivePeer();
        if (peer == null) {
            sendError(resp, "no active peer");
            return;
        }

        String msgId = req.getParameter("msgId");
        if (msgId == null || msgId.isEmpty()) {
            sendError(resp, "msgId is required");
            return;
        }

        int channelIndex = 1;
        String channelIndexParam = req.getParameter("channelIndex");
        if (channelIndexParam != null && !channelIndexParam.isEmpty()) {
            channelIndex = Integer.parseInt(channelIndexParam);
        }

        try {
            SharkNetMessengerComponent messenger = peer.getMessengerComponent();
            CharSequence channelURI = resolveChannelURI(messenger, channelIndex);

            if (!messageExists(messenger, channelURI, msgId)) {
                sendError(resp, HttpServletResponse.SC_NOT_FOUND, "message not found");
                return;
            }

            peer.markMessageDeleted(channelURI, msgId);

            JsonObject response = new JsonObject();
            response.addProperty("msg", "message deleted");
            response.addProperty("messageId", msgId);
            resp.setStatus(HttpServletResponse.SC_OK);
            resp.setContentType("application/json");
            resp.getWriter().write(response.toString());
        } catch (SharkException e) {
            sendError(resp, e.getMessage());
        }
    }

    /**
     * Resolves a channel URI from a 1-based channel index, matching the same "index 1 falls
     * back to the general channel" convention used by doPost.
     */
    private CharSequence resolveChannelURI(SharkNetMessengerComponent messenger, int channelIndex) throws SharkException, IOException {
        try {
            SharkNetMessengerChannel channel = messenger.getChannel(channelIndex - 1);
            return channel.getURI();
        } catch (SharkException se) {
            if (channelIndex == 1) {
                return SharkNetMessengerComponent.GENERAL_CHANNEL_URI;
            }
            throw se;
        }
    }

    /**
     * Confirms a message with the given key (its formatted creation timestamp, the same
     * value ListMessagesServlet exposes as the message's id) currently exists in the channel.
     */
    private boolean messageExists(SharkNetMessengerComponent messenger, CharSequence channelURI, String messageKey)
            throws SharkException, IOException {
        SharkNetMessengerChannel channel = messenger.getChannel(channelURI);
        SharkNetMessageList messages = channel.getMessages();
        for (int i = 0; i < messages.size(); i++) {
            try {
                SharkNetMessage msg = messages.getSharkMessage(i, true);
                if (formatTime(msg.getCreationTime()).equals(messageKey)) {
                    return true;
                }
            } catch (Exception ignored) {
                // skip messages whose creation time can't be read (e.g. undecryptable)
            }
        }
        return false;
    }

    private String formatTime(long millis) {
        return new SimpleDateFormat("yyyy-MM-dd HH:mm:ss.SSS").format(new Date(millis));
    }

    private void sendError(HttpServletResponse resp, String msg) throws IOException {
        sendError(resp, HttpServletResponse.SC_BAD_REQUEST, msg);
    }

    private void sendError(HttpServletResponse resp, int status, String msg) throws IOException {
        JsonObject err = new JsonObject();
        err.addProperty("error", msg);
        resp.setStatus(status);
        resp.setContentType("application/json");
        resp.getWriter().write(err.toString());
    }
}
