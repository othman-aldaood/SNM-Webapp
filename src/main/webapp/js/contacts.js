async function loadContacts() {
    const tableBody = document.getElementById('contactsTableBody');
    try {
        const response = await fetch('api/peer');
        const peers = await response.json();

        tableBody.innerHTML = '';

        peers.forEach(peer => {
            const row = document.createElement('tr');
            row.className = "hover:bg-gray-50 dark:hover:bg-gray-700/50";


            const isPeerActive = peer.active;
            const statusText = isPeerActive ? 'Active' : 'Inactive';
            const statusClass = isPeerActive ? 'bg-green-100 text-green-800' : 'bg-gray-100 text-gray-800';

            row.innerHTML = `
                <td class="px-6 py-4">
                    <span class="px-2 py-1 text-xs font-bold rounded-full ${statusClass}">${statusText}</span>
                </td>
                <td class="px-6 py-4">
                    <div class="font-bold">${peer.name || 'Unknown'}</div>
                    <div class="text-xs text-gray-500 font-mono">${peer.peerId}</div>
                </td>
                <td class="px-6 py-4">
                    <button class="px-3 py-1 text-xs ${isPeerActive ? 'bg-gray-500' : 'bg-blue-600'} text-white rounded" 
                            onclick="${isPeerActive ? 'stopPeer' : 'startPeer'}('${peer.peerId}')">
                        ${isPeerActive ? 'Stop' : 'Start'}
                    </button>
                    <button class="px-3 py-1 text-xs bg-red-600 text-white rounded ml-2" onclick="deletePeer('${peer.peerId}')">
                        Delete
                    </button>
                </td>
            `;
            tableBody.appendChild(row);
        });
    } catch (err) {
        tableBody.innerHTML = '<tr><td colspan="3" class="px-6 py-8 text-center text-red-500">Error loading data.</td></tr>';
    }
}


async function startPeer(id) {
    await fetch('api/start/' + id, {method: 'POST'});
    location.reload();
}

async function stopPeer(id) {
    await fetch('api/stop/' + id, {method: 'POST'});
    location.reload();
}

async function deletePeer(id) {
    if (confirm('Sure?')) await fetch('api/peer', {
        method: 'DELETE',
        headers: {'Content-Type': 'application/json'},
        body: JSON.stringify({peerId: id})
    });
    location.reload();
}

function createNewPeer() {
    const name = prompt("Peer Name:");
    if (!name) return;
    fetch('api/peer', {
        method: 'POST',
        headers: {'Content-Type': 'application/json'},
        body: JSON.stringify({name: name})
    })
        .then(() => location.reload());
}

document.addEventListener('DOMContentLoaded', loadContacts);