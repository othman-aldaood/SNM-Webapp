<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <title>Certificates - SharkNet</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <script>
        tailwind.config = {
            darkMode: 'class',
            theme: {
                extend: {
                    colors: {
                        primary: { 500: '#3b82f6', 600: '#2563eb' }
                    }
                }
            }
        }
    </script>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
</head>

<body class="bg-gray-50 dark:bg-gray-900 text-gray-900 dark:text-gray-100 transition-colors duration-300">
    <jsp:include page="header.jsp" />

    <div class="flex flex-col md:flex-row min-h-screen">
        <% request.setAttribute("activePage", "certificates"); %>
        <jsp:include page="sidebar.jsp" />

        <main class="flex-1 p-6">
            <div class="max-w-6xl mx-auto space-y-6">

                <div class="flex flex-col md:flex-row justify-between items-start md:items-center mb-6 gap-4">
                    <div>
                        <h1 class="text-2xl font-bold">Certificate Management</h1>
                        <p class="text-sm text-gray-500 dark:text-gray-400">Manage PKI credentials, trust stores, and identity certificates.</p>
                    </div>
                    <div class="flex gap-2">
                        <button class="bg-gray-200 hover:bg-gray-300 text-gray-800 dark:bg-gray-700 dark:text-gray-200 dark:hover:bg-gray-600 px-4 py-2 rounded-lg font-medium transition-colors shadow-sm" onclick="showImportModal()">
                            Send Certificate
                        </button>
                        <button class="bg-primary-500 hover:bg-primary-600 text-white px-4 py-2 rounded-lg font-medium transition-colors shadow-sm" onclick="refreshCertificates()">
                            <i class="fas fa-sync-alt mr-1"></i> Refresh
                        </button>
                    </div>
                </div>

                <div class="bg-white dark:bg-gray-800 p-6 rounded-xl border border-gray-200 dark:border-gray-700 shadow-sm flex flex-col sm:flex-row justify-between items-start sm:items-center gap-4">
                    <div>
                        <h3 class="font-bold text-lg text-gray-900 dark:text-white">Your Identity Certificate</h3>
                        <div class="text-sm text-gray-500 dark:text-gray-400 mt-1">
                            Peer ID: <span id="your-peer-id" class="font-mono font-medium text-gray-800 dark:text-gray-300">Loading...</span>
                        </div>
                    </div>
                    <button class="bg-gray-100 hover:bg-gray-200 text-gray-800 dark:bg-gray-700 dark:text-gray-200 dark:hover:bg-gray-600 px-4 py-2 rounded-lg text-sm font-medium transition-colors border border-gray-300 dark:border-gray-600" onclick="exportOwnCertificate()">
                        Export Public Key
                    </button>
                </div>

                <div class="bg-white dark:bg-gray-800 p-6 rounded-xl border border-gray-200 dark:border-gray-700 shadow-sm">
                    <div class="flex items-center gap-3 mb-4 border-b border-gray-100 dark:border-gray-700 pb-3">
                        <h3 class="font-bold text-lg text-gray-900 dark:text-white">Pending Credential Requests</h3>
                        <span id="pending-count" class="bg-yellow-100 text-yellow-800 dark:bg-yellow-900/30 dark:text-yellow-500 text-xs font-bold px-2.5 py-0.5 rounded-full">0</span>
                    </div>
                    <div id="pending-credentials-container" class="space-y-3">
                        <div class="text-gray-500 dark:text-gray-400 text-sm italic py-2">No pending credential requests</div>
                    </div>
                </div>

                <div class="bg-white dark:bg-gray-800 p-6 rounded-xl border border-gray-200 dark:border-gray-700 shadow-sm">
                    <h3 class="font-bold text-lg mb-4 border-b border-gray-100 dark:border-gray-700 pb-3">Advanced Filtering</h3>

                    <div class="flex flex-wrap items-end gap-4">
                        <div class="w-full sm:w-auto flex-1 min-w-[200px]">
                            <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">Filter by:</label>
                            <select id="filter-type" class="w-full bg-gray-50 dark:bg-gray-900 border border-gray-300 dark:border-gray-600 text-gray-900 dark:text-white rounded-lg p-2.5 text-sm focus:ring-2 focus:ring-primary-500 outline-none" onchange="onFilterTypeChange()">
                                <option value="all">All Certificates</option>
                                <option value="issuer">By Issuer</option>
                                <option value="subject">By Subject</option>
                                <option value="trust">By Trust Level</option>
                            </select>
                        </div>

                        <div class="w-full sm:w-auto flex-1 min-w-[200px] hidden" id="issuer-filter">
                            <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">Issuer:</label>
                            <select id="issuer-select" class="w-full bg-gray-50 dark:bg-gray-900 border border-gray-300 dark:border-gray-600 text-gray-900 dark:text-white rounded-lg p-2.5 text-sm focus:ring-2 focus:ring-primary-500 outline-none">
                                <option value="">All Issuers</option>
                            </select>
                        </div>

                        <div class="w-full sm:w-auto flex-1 min-w-[200px] hidden" id="subject-filter">
                            <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">Subject:</label>
                            <select id="subject-select" class="w-full bg-gray-50 dark:bg-gray-900 border border-gray-300 dark:border-gray-600 text-gray-900 dark:text-white rounded-lg p-2.5 text-sm focus:ring-2 focus:ring-primary-500 outline-none">
                                <option value="">All Subjects</option>
                            </select>
                        </div>

                        <div class="w-full sm:w-auto flex-1 min-w-[200px] hidden" id="trust-filter">
                            <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">Trust Level:</label>
                            <select id="trust-select" class="w-full bg-gray-50 dark:bg-gray-900 border border-gray-300 dark:border-gray-600 text-gray-900 dark:text-white rounded-lg p-2.5 text-sm focus:ring-2 focus:ring-primary-500 outline-none">
                                <option value="">All Levels</option>
                                <option value="0">Unknown</option>
                                <option value="1">Self-Signed</option>
                                <option value="2">Verified</option>
                                <option value="3">Highly Verified</option>
                            </select>
                        </div>

                        <div class="w-full sm:w-auto flex gap-2 mt-4 sm:mt-0">
                            <button class="bg-primary-500 hover:bg-primary-600 text-white px-4 py-2.5 rounded-lg text-sm font-medium transition-colors" onclick="applyFilter()">Apply Filter</button>
                            <button class="bg-gray-200 hover:bg-gray-300 text-gray-800 dark:bg-gray-700 dark:text-gray-200 dark:hover:bg-gray-600 px-4 py-2.5 rounded-lg text-sm font-medium transition-colors" onclick="clearFilter()">Clear</button>
                        </div>
                    </div>
                </div>

                <div class="bg-white dark:bg-gray-800 rounded-xl border border-gray-200 dark:border-gray-700 shadow-sm overflow-hidden">
                    <div class="p-4 border-b border-gray-200 dark:border-gray-700 flex flex-col sm:flex-row justify-between items-start sm:items-center gap-4">
                        <h3 class="font-bold text-lg text-gray-900 dark:text-white">Trusted Peer Certificates</h3>
                        <input type="text" id="certificate-search" class="w-full sm:w-64 bg-gray-50 dark:bg-gray-900 border border-gray-300 dark:border-gray-600 rounded-lg p-2 text-sm outline-none focus:ring-2 focus:ring-primary-500" placeholder="🔍 Search Certificates..." onkeyup="filterCertificates()">
                    </div>

                    <div class="overflow-x-auto">
                        <table class="w-full text-left text-sm" id="certificates-table">
                            <thead class="text-xs uppercase bg-gray-50 dark:bg-gray-700 text-gray-700 dark:text-gray-300 border-b border-gray-200 dark:border-gray-700">
                                <tr>
                                    <th class="px-6 py-4 font-semibold">Subject</th>
                                    <th class="px-6 py-4 font-semibold">Issuer</th>
                                    <th class="px-6 py-4 font-semibold">Valid Until</th>
                                    <th class="px-6 py-4 font-semibold">Trust Level</th>
                                    <th class="px-6 py-4 font-semibold text-right">Actions</th>
                                </tr>
                            </thead>
                            <tbody id="certificates-tbody" class="divide-y divide-gray-200 dark:divide-gray-700">
                                <tr>
                                    <td colspan="5" class="px-6 py-8 text-center text-gray-500 dark:text-gray-400">Loading certificates...</td>
                                </tr>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
        </main>
    </div>

    <div id="revoke-modal" class="fixed inset-0 z-50 hidden bg-gray-900/50 backdrop-blur-sm flex items-center justify-center p-4">
        <div class="bg-white dark:bg-gray-800 w-full max-w-md rounded-xl shadow-2xl border border-gray-200 dark:border-gray-700 flex flex-col overflow-hidden">
            <div class="p-4 border-b border-gray-200 dark:border-gray-700 flex justify-between items-center bg-gray-50 dark:bg-gray-700/50">
                <h3 class="font-bold text-lg text-gray-900 dark:text-white">Revoke Certificate</h3>
                <button class="text-gray-400 hover:text-red-500 transition-colors text-xl w-8 h-8 flex items-center justify-center rounded-full hover:bg-red-50 dark:hover:bg-red-900/20" onclick="hideRevokeModal()">&times;</button>
            </div>
            <div class="p-6 space-y-4">
                <div>
                    <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">Subject ID:</label>
                    <input type="text" id="revoke-subject-id" class="w-full bg-gray-100 dark:bg-gray-900 border border-gray-300 dark:border-gray-600 rounded-lg p-2.5 text-sm text-gray-500 dark:text-gray-400 cursor-not-allowed" readonly>
                </div>
                <div>
                    <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">Certificate Subject:</label>
                    <input type="text" id="revoke-subject-name" class="w-full bg-gray-100 dark:bg-gray-900 border border-gray-300 dark:border-gray-600 rounded-lg p-2.5 text-sm text-gray-500 dark:text-gray-400 cursor-not-allowed" readonly>
                </div>
                <div class="bg-red-50 dark:bg-red-900/20 text-red-700 dark:text-red-400 p-3 rounded-lg text-sm border border-red-200 dark:border-red-800/30">
                    <strong>⚠️ Warning:</strong> This action cannot be undone. The certificate will be revoked and can no longer be used for verification.
                </div>
            </div>
            <div class="p-4 border-t border-gray-200 dark:border-gray-700 bg-gray-50 dark:bg-gray-700/50 flex justify-end gap-3">
                <button class="px-4 py-2 border border-gray-300 dark:border-gray-600 rounded-lg text-gray-700 dark:text-gray-300 hover:bg-gray-100 dark:hover:bg-gray-600 text-sm font-medium transition-colors" onclick="hideRevokeModal()">Cancel</button>
                <button class="px-4 py-2 bg-red-600 hover:bg-red-700 text-white rounded-lg text-sm font-medium shadow-sm transition-colors" onclick="revokeCertificate()">Revoke Certificate</button>
            </div>
        </div>
    </div>

    <div id="import-modal" class="fixed inset-0 z-50 hidden bg-gray-900/50 backdrop-blur-sm flex items-center justify-center p-4">
        <div class="bg-white dark:bg-gray-800 w-full max-w-md rounded-xl shadow-2xl border border-gray-200 dark:border-gray-700 flex flex-col overflow-hidden">
            <div class="p-4 border-b border-gray-200 dark:border-gray-700 flex justify-between items-center bg-gray-50 dark:bg-gray-700/50">
                <h3 class="font-bold text-lg text-gray-900 dark:text-white">Send Certificate</h3>
                <button class="text-gray-400 hover:text-red-500 transition-colors text-xl w-8 h-8 flex items-center justify-center rounded-full hover:bg-red-50 dark:hover:bg-red-900/20" onclick="hideImportModal()">&times;</button>
            </div>
            <div class="p-6 space-y-4">
                <div>
                    <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">Peer ID (optional):</label>
                    <input type="text" id="import-peer-name" class="w-full bg-gray-50 dark:bg-gray-900 border border-gray-300 dark:border-gray-600 text-gray-900 dark:text-white rounded-lg p-2.5 text-sm focus:ring-2 focus:ring-primary-500 outline-none" placeholder="Leave empty to broadcast">
                </div>
                <div>
                    <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">Message (optional):</label>
                    <textarea id="import-message" rows="3" class="w-full bg-gray-50 dark:bg-gray-900 border border-gray-300 dark:border-gray-600 text-gray-900 dark:text-white rounded-lg p-2.5 text-sm focus:ring-2 focus:ring-primary-500 outline-none resize-none" placeholder="Optional message to send with credentials"></textarea>
                </div>
            </div>
            <div class="p-4 border-t border-gray-200 dark:border-gray-700 bg-gray-50 dark:bg-gray-700/50 flex justify-end gap-3">
                <button class="px-4 py-2 border border-gray-300 dark:border-gray-600 rounded-lg text-gray-700 dark:text-gray-300 hover:bg-gray-100 dark:hover:bg-gray-600 text-sm font-medium transition-colors" onclick="hideImportModal()">Cancel</button>
                <button class="px-4 py-2 bg-primary-500 hover:bg-primary-600 text-white rounded-lg text-sm font-medium shadow-sm transition-colors" onclick="sendCredentials()">Send Credentials</button>
            </div>
        </div>
    </div>

    <div id="details-modal" class="fixed inset-0 z-50 hidden bg-gray-900/50 backdrop-blur-sm flex items-center justify-center p-4">
        <div class="bg-white dark:bg-gray-800 w-full max-w-2xl rounded-xl shadow-2xl border border-gray-200 dark:border-gray-700 flex flex-col overflow-hidden max-h-[90vh]">
            <div class="p-4 border-b border-gray-200 dark:border-gray-700 flex justify-between items-center bg-gray-50 dark:bg-gray-700/50">
                <h3 class="font-bold text-lg text-gray-900 dark:text-white">Certificate Details</h3>
                <button class="text-gray-400 hover:text-red-500 transition-colors text-xl w-8 h-8 flex items-center justify-center rounded-full hover:bg-red-50 dark:hover:bg-red-900/20" onclick="hideDetailsModal()">&times;</button>
            </div>
            <div class="p-6 overflow-y-auto">
                <div id="certificate-details" class="text-sm text-gray-700 dark:text-gray-300 space-y-4">
                    </div>
            </div>
            <div class="p-4 border-t border-gray-200 dark:border-gray-700 bg-gray-50 dark:bg-gray-700/50 flex justify-end">
                <button class="px-4 py-2 border border-gray-300 dark:border-gray-600 rounded-lg text-gray-700 dark:text-gray-300 hover:bg-gray-100 dark:hover:bg-gray-600 text-sm font-medium transition-colors" onclick="hideDetailsModal()">Close</button>
            </div>
        </div>
    </div>

    <script src="js/certificates.js?v=3"></script>
</body>
</html>