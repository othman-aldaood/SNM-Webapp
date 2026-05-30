/**
 * messenger.js - Handles Channels and Messaging logic
 * Updated to support Tailwind CSS UI and Flowbite List-Group design
 */

// Global state tracking the currently active channel
let currentChannelState = {
    uri: null,
    index: null, // Needed for sending messages to the correct backend index
    name: null
};

document.addEventListener('DOMContentLoaded', () => {
    loadChannels();
    loadPersonsForRecipient(); // Load available persons for recipient selection

    // Add enter key listener for textarea to send message on "Enter"
    const input = document.getElementById('message-input');
    if (input) {
        input.addEventListener('keydown', function (e) {
            if (e.key === 'Enter' && !e.shiftKey) {
                e.preventDefault();
                sendMessage();
            }
        });
    }
});

/**
 * Fetches channels from the API and dynamically renders them using Tailwind CSS classes.
 * @return {Promise<void>}
 */
async function loadChannels() {
    console.log('Loading channels...');
    const container = document.getElementById('channel-list');
    if (!container) return;

    try {
        const response = await fetch('/snm-webapp/api/messenger/channels');
        if (!response.ok) throw new Error('Failed to fetch channels');

        const data = await response.json();
        console.log('Channels data:', data);

        // Render the base wrapper for the Tailwind List Group
        container.innerHTML = `
            <div class="w-full text-sm font-medium text-gray-900 bg-white border border-gray-200 rounded-lg dark:bg-dark-card dark:border-dark-border dark:text-white shadow-sm" id="dynamic-channel-list">
            </div>
        `;

        const listGroup = document.getElementById('dynamic-channel-list');

        if (data.channels && data.channels.length > 0) {
            data.channels.forEach((channel, index) => {
                const isLast = index === data.channels.length - 1;
                const isActive = currentChannelState.uri === channel.uri;

                const item = document.createElement('a');

                // Build Tailwind classes dynamically
                let baseClasses = "channel-item flex justify-between items-center w-full px-4 py-3 cursor-pointer transition-colors ";

                // Borders and rounded corners
                if (!isLast) baseClasses += "border-b border-gray-200 dark:border-dark-border ";
                if (index === 0) baseClasses += "rounded-t-lg ";
                if (isLast) baseClasses += "rounded-b-lg ";

                // Active vs Inactive state colors
                if (isActive) {
                    baseClasses += "bg-gray-100 text-primary-600 dark:bg-gray-800 dark:text-primary-400";
                    item.setAttribute('aria-current', 'true');
                } else {
                    baseClasses += "hover:bg-gray-50 hover:text-primary-600 dark:hover:bg-gray-800 dark:hover:text-primary-400 text-gray-900 dark:text-white";
                }

                item.className = baseClasses;

                // Attach click event to handle UI update and API fetch
                item.onclick = () => selectChannel(item, channel.uri, channel.name, channel.index);

                // Render internal HTML using FontAwesome and Tailwind
                item.innerHTML = `
                    <div class="flex items-center truncate">
                        <i class="fas fa-hashtag w-4 h-4 mr-2 ${isActive ? '' : 'text-gray-400 dark:text-gray-500'} channel-icon"></i>
                        <span class="truncate name-text ${isActive ? 'font-bold' : ''}">${escapeHtml(channel.name)}</span>
                    </div>
                    <div class="flex items-center">
                        <span class="text-xs text-gray-400 mr-2 bg-gray-100 dark:bg-gray-700 px-2 py-0.5 rounded-full">${channel.messages}</span>
                        <button onclick="deleteChannel('${channel.uri}', event)" class="text-gray-400 hover:text-red-500 transition-colors" title="Delete Channel">
                            <i class="fas fa-times"></i>
                        </button>
                    </div>
                `;

                listGroup.appendChild(item);
            });

            // Update info panel count
            const countEl = document.getElementById('active-channel-count');
            if (countEl) countEl.textContent = data.channels.length;

        } else {
            // Empty state styling
            listGroup.innerHTML = `
                <div class="p-5 text-center text-gray-500 dark:text-gray-400 text-sm">
                    No channels available.<br>Create one using the <i class="fas fa-plus-circle text-primary-500 mx-1"></i> button.
                </div>
            `;
            const countEl = document.getElementById('active-channel-count');
            if (countEl) countEl.textContent = '0';
        }

    } catch (error) {
        console.error('Error loading channels:', error);
        container.innerHTML = `<div class="p-4 text-center text-red-500 text-sm">Failed to load channels from server.</div>`;
    }
}

/**
 * Handles the selection of a channel from the list, updates the UI classes,
 * stores the state, and triggers the message fetch.
 * * @param {HTMLElement} element - The clicked DOM element
 * @param {string} uri - The unique URI of the selected channel
 * @param {string} name - The display name of the selected channel
 * @param {number} index - The backend index of the channel
 */
function selectChannel(element, uri, name, index) {
    // 1. Update Global State
    currentChannelState = {uri, name, index};
    console.log('Selected channel state:', currentChannelState);

    // 2. Reset all channels to INACTIVE state in UI
    document.querySelectorAll('.channel-item').forEach(el => {
        el.removeAttribute('aria-current');
        el.classList.remove('bg-gray-100', 'text-primary-600', 'dark:bg-gray-800', 'dark:text-primary-400');
        el.classList.add('hover:bg-gray-50', 'hover:text-primary-600', 'dark:hover:bg-gray-800', 'dark:hover:text-primary-400', 'text-gray-900', 'dark:text-white');

        const nameSpan = el.querySelector('.name-text');
        if (nameSpan) nameSpan.classList.remove('font-bold');

        const icon = el.querySelector('.channel-icon');
        if (icon) icon.classList.add('text-gray-400', 'dark:text-gray-500');
    });

    // 3. Set the clicked channel to ACTIVE state in UI
    if (element) {
        element.setAttribute('aria-current', 'true');
        element.classList.remove('hover:bg-gray-50', 'hover:text-primary-600', 'dark:hover:bg-gray-800', 'dark:hover:text-primary-400', 'text-gray-900', 'dark:text-white');
        element.classList.add('bg-gray-100', 'text-primary-600', 'dark:bg-gray-800', 'dark:text-primary-400');

        const activeSpan = element.querySelector('.name-text');
        if (activeSpan) activeSpan.classList.add('font-bold');

        const activeIcon = element.querySelector('.channel-icon');
        if (activeIcon) activeIcon.classList.remove('text-gray-400', 'dark:text-gray-500');
    }

    // 4. Update the Main Chat Header
    const headerName = document.getElementById('current-channel-name');
    if (headerName) headerName.textContent = name || uri;

    document.getElementById('current-channel-pki-status').innerText = 'Connected to ' + (name || uri);

    const indicator = document.getElementById('status-indicator');
    if (indicator) {
        indicator.classList.remove('bg-gray-400');
        indicator.classList.add('bg-green-500', 'shadow-[0_0_5px_#22c55e]');
    }

    // 5. Fetch messages from the server
    loadMessages(uri);
}

/**
 * Fetches and displays messages for a specific channel URI.
 * @param {string} uri - The channel URI
 * @return {Promise<void>}
 */
async function loadMessages(uri) {
    const chatLog = document.getElementById('chat-log');
    if (!chatLog) return;

    chatLog.innerHTML = `
        <div class="flex flex-col items-center justify-center h-full text-center space-y-3 opacity-60">
            <i class="fas fa-spinner fa-spin text-3xl text-primary-500"></i>
            <p class="text-sm">Loading messages...</p>
        </div>
    `;

    try {
        const encodedUri = encodeURIComponent(uri);
        const response = await fetch(`/snm-webapp/api/messenger/messages/?uri=${encodedUri}`);

        if (!response.ok) {
            const errorText = await response.text();
            throw new Error(`Status ${response.status}: ${errorText}`);
        }

        const data = await response.json();

        if (data.channel && data.channel.messages) {
            renderMessages(data.channel.messages);
        } else {
            chatLog.innerHTML = '<div class="text-center p-5 text-gray-400 text-sm">No messages. Be the first to say hello!</div>';
        }

    } catch (error) {
        console.error('Error loading messages:', error);
        chatLog.innerHTML = `<div class="text-center text-red-500 p-5 text-sm">Error loading messages: ${error.message}</div>`;
    }
}

/**
 * Renders an array of messages into the chat log using Tailwind styling.
 * @param {Array} messages - Array of message objects
 * @return {void}
 */
function renderMessages(messages) {
    const chatLog = document.getElementById('chat-log');
    chatLog.innerHTML = '';

    if (messages.length === 0) {
        chatLog.innerHTML = '<div class="text-center p-5 text-gray-400 text-sm">No messages here yet. Say hello!</div>';
        return;
    }

    messages.forEach(msg => {
        const line = document.createElement('div');
        const isMe = msg.sender === 'you';

        line.innerHTML = `
            <div class="mb-4 max-w-[80%] ${isMe ? 'ml-auto text-right' : 'mr-auto text-left'}">
                <div class="text-[0.7rem] text-gray-500 dark:text-gray-400 mb-1 px-1">
                    ${msg.timestamp.split(' ')[1] || msg.timestamp} - ${msg.sender}
                </div>
                <div class="${isMe ? 'bg-primary-500 text-white rounded-l-xl rounded-tr-xl' : 'bg-white dark:bg-dark-card border border-gray-200 dark:border-dark-border text-gray-800 dark:text-gray-200 rounded-r-xl rounded-tl-xl'} px-4 py-2 inline-block text-sm shadow-sm text-left">
                    ${escapeHtml(msg.content)}
                </div>
            </div>
        `;
        chatLog.appendChild(line);
    });

    chatLog.scrollTop = chatLog.scrollHeight;
}

/**
 * Gathers input and sends a new message to the active channel.
 * @return {Promise<void>}
 */
async function sendMessage() {
    if (currentChannelState.index === null || currentChannelState.index === undefined) {
        alert('Please select a channel from the list first.');
        return;
    }

    const input = document.getElementById('message-input');
    const content = input.value.trim();

    if (!content) return;

    try {
        const payload = {
            content: content,
            channelIndex: currentChannelState.index,
            contentType: "ASAP_CHARACTER_SEQUENCE",
            sign: document.getElementById('sign-message')?.checked !== false,
            encrypt: document.getElementById('encrypt-message')?.checked === true,
            receiver: document.getElementById('message-receiver')?.value || "ANY_SHARKNET_PEER"
        };

        const response = await fetch('/snm-webapp/api/messenger/messages', {
            method: 'POST',
            headers: {'Content-Type': 'application/json'},
            body: JSON.stringify(payload)
        });

        const result = await response.json();

        if (response.ok) {
            input.value = ''; // Clear input
            showSendSuccess();
            setTimeout(() => {
                loadMessages(currentChannelState.uri);
            }, 500);
        } else {
            alert('Failed to send message: ' + (result.error || 'Unknown error'));
        }

    } catch (error) {
        console.error('Error sending message:', error);
        alert('Error sending message');
    }
}

/**
 * Deletes a channel after user confirmation.
 * @param {string} uri - The URI of the channel to delete
 * @param {Event} event - The click event
 * @return {Promise<void>}
 */
async function deleteChannel(uri, event) {
    if (event) event.stopPropagation(); // Prevent triggering selectChannel
    if (!confirm(`Are you sure you want to delete the channel:\n${uri}?`)) return;

    try {
        const response = await fetch('/snm-webapp/api/messenger/channels', {
            method: 'DELETE',
            headers: {'Content-Type': 'application/json'},
            body: JSON.stringify({uri: uri})
        });

        if (response.ok) {
            if (currentChannelState.uri === uri) {
                // Reset UI if the deleted channel was currently active
                document.getElementById('chat-log').innerHTML = '<div class="text-center p-5 text-gray-400 text-sm">Channel deleted.</div>';
                document.getElementById('current-channel-name').textContent = 'Select a channel';
                document.getElementById('current-channel-pki-status').innerText = 'Waiting for selection...';

                const indicator = document.getElementById('status-indicator');
                if (indicator) {
                    indicator.classList.add('bg-gray-400');
                    indicator.classList.remove('bg-green-500', 'shadow-[0_0_5px_#22c55e]');
                }

                currentChannelState = {uri: null, index: null, name: null};
            }
            loadChannels(); // Refresh the list from server
        } else {
            alert('Failed to delete channel from server.');
        }
    } catch (e) {
        console.error(e);
        alert('Error deleting channel');
    }
}

/**
 * Creates a new channel using the modal inputs.
 * @return {Promise<void>}
 */
async function createChannel() {
    const uriInput = document.getElementById('new-channel-uri');
    const nameInput = document.getElementById('new-channel-name');

    const uri = uriInput.value.trim();
    const name = nameInput.value.trim() || uri;

    if (!uri) {
        alert('Channel URI is required');
        return;
    }

    try {
        const response = await fetch('/snm-webapp/api/messenger/channels', {
            method: 'POST',
            headers: {'Content-Type': 'application/json'},
            body: JSON.stringify({uri, name})
        });

        const result = await response.json();

        if (response.ok) {
            hideCreateChannelModal();
            uriInput.value = '';
            nameInput.value = '';
            loadChannels(); // Refresh UI
        } else {
            alert('Error: ' + (result.error || result.message || 'Unknown error'));
        }
    } catch (error) {
        console.error('Error creating channel:', error);
        alert('Request failed');
    }
}

// Show send success feedback animation on button
function showSendSuccess() {
    const sendBtn = document.getElementById('send-btn');
    if (!sendBtn) return;

    const originalContent = sendBtn.innerHTML;

    sendBtn.innerHTML = `<i class="fas fa-check text-base"></i><span class="text-xs">Sent!</span>`;
    sendBtn.classList.remove('bg-primary-500', 'hover:bg-primary-600');
    sendBtn.classList.add('bg-green-500', 'hover:bg-green-600');

    setTimeout(() => {
        sendBtn.innerHTML = originalContent;
        sendBtn.classList.remove('bg-green-500', 'hover:bg-green-600');
        sendBtn.classList.add('bg-primary-500', 'hover:bg-primary-600');
    }, 2000);
}

// Load available persons for recipient selection dropdown
async function loadPersonsForRecipient() {
    try {
        const response = await fetch('/snm-webapp/api/persons');
        if (!response.ok) return;

        const data = await response.json();
        const select = document.getElementById('message-receiver');

        if (select && data.persons && data.persons.length > 0) {
            select.innerHTML = '<option value="ANY_SHARKNET_PEER">Anyone</option>';
            data.persons.forEach(person => {
                const option = document.createElement('option');
                option.value = person.name;
                option.textContent = `${person.name} (${person.id.substring(0, 8)}...)`;
                select.appendChild(option);
            });
        }
    } catch (error) {
        console.error('Error loading persons:', error);
    }
}

function showCreateChannelModal() {
    document.getElementById('create-channel-form').style.display = 'flex';
    document.getElementById('new-channel-uri').focus();
}

// Utility to escape HTML and prevent XSS
function escapeHtml(text) {
    if (!text) return '';
    return text
        .replace(/&/g, "&amp;")
        .replace(/</g, "&lt;")
        .replace(/>/g, "&gt;")
        .replace(/"/g, "&quot;")
        .replace(/'/g, "&#039;");
}