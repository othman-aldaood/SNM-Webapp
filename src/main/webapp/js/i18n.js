/**
 * i18n.js - Handles Multi-Language Support (English / Deutsch)
 * Supports automatic browser language detection and instant DOM updates.
 */

// Externalized UI Strings Dictionary
const translations = {
    en: {
        // Common
        "common.cancel": "Cancel",
        "common.save": "Save",
        "common.close": "Close",
        "common.refresh": "Refresh",
        "common.loading": "Loading...",
        "common.status": "Status",
        "common.actions": "Actions",

        // Sidebar
        "nav.messenger": "Messenger",
        "nav.peer": "Peer Contacts",
        "nav.persons": "Persons",
        "nav.certificates": "Certificates",
        "nav.network": "Network Status",
        "nav.hubs": "ASAP Hubs",
        "nav.settings": "Settings",
        "nav.profile": "My Profile",
        "nav.help": "Help",

        // Header
        "header.internet": "Internet",
        "header.logout": "Logout",
        "header.logout_confirm": "Confirm Logout",
        "header.logout_desc": "Are you sure you want to log out?<br>This will stop the active peer and redirect you to the login screen.",

        // Settings Page
        "settings.title": "Settings & Configuration",
        "settings.desc": "Manage peer configuration and application settings.",
        "settings.app_settings": "Application Settings",
        "settings.msg_defaults": "Message Defaults",
        "settings.sign_default": "Sign messages by default",
        "settings.enc_default": "Encrypt messages by default",
        "settings.hub_settings": "Hub Connection Settings",
        "settings.remember_hubs": "Remember new hub connections",
        "settings.remember_hubs_desc": "Automatically save and reconnect to previously used hub connections.",
        "settings.reconnect_hubs": "Enable hub reconnection",
        "settings.reconnect_hubs_desc": "Automatically attempt to reconnect to hubs when connection is lost.",

        // Messenger Page
        "msg.channels": "Channels",
        "msg.create_channel": "Create Channel",
        "msg.search_ph": "Search text...",
        "msg.filters": "Filters",
        "msg.sender_name": "Sender Name",
        "msg.from_date": "From Date",
        "msg.to_date": "To Date",
        "msg.clear_filters": "Clear Filters",
        "msg.type_here": "Type your message here...",
        "msg.send": "Send",
        "msg.sign": "Sign",
        "msg.encrypt": "Encrypt",
        "msg.peer_info": "Peer Info",
        "msg.stats": "Statistics",

        // Profile Page
        "prof.title": "Peer Profile",
        "prof.desc": "Manage your decentralized identity and view network metrics.",
        "prof.export": "Export Identity",
        "prof.crypto_id": "Cryptographic Identity",
        "prof.fingerprint": "Public Key Fingerprint",
        "prof.net_activity": "Network Activity",
        "prof.connections": "Connections",
        "prof.open_ports": "Open Ports",
        "prof.wot": "Web of Trust Summary",
        "prof.wot_desc": "Your identity has been verified and trusted by multiple peers within your local mesh network.",

        // Onboarding / Welcome Alerts
        "welcome.alert.name_required": "Please input your display name representation to proceed.",
        "welcome.alert.hub_required": "Please enter both target remote address and operational port mappings.",
        "welcome.alert.hub_failed": "Failed dispatching operational frame context to target hub.",
        "welcome.alert.uri_required": "A valid active scope target channel URI is required.",
        "welcome.alert.channel_failed": "Failed to initialize your first channel: ",
        "welcome.alert.save_error": "An error occurred while saving your configuration.",

        // Onboarding Welcome Page
        "welcome.step.profile": "Profile",
        "welcome.step.pki": "Keys (PKI)",
        "welcome.step.hub": "Hub Link",
        "welcome.step.channels": "Channels",

        "welcome.prof.header": "Configure User Profile",
        "welcome.prof.desc": "Set up your local display preference for this SharkNet peer identity.",
        "welcome.prof.label": "Peer Custom Name",
        "welcome.prof.placeholder": "e.g. Shark_Node_Alpha",
        "welcome.prof.info": "This configuration establishes your personal identifier representation across active channels within the decentralized framework.",

        "welcome.pki.header": "Cryptographic Key Infrastructure",
        "welcome.pki.desc": "Your secure decentralized cryptographic identity credentials are automatically managed.",
        "welcome.pki.status": "PKI Infrastructure Status:",
        "welcome.pki.active": "Active",
        "welcome.pki.hash": "Public Key Fingerprint Hash",
        "welcome.pki.resolving": "Resolving identity fingerprint string...",
        "welcome.pki.storage": "Keys are stored securely inside your local peer data partition directories.",

        "welcome.hub.header": "Establish Hub Link",
        "welcome.hub.desc": "Connect to an operational ASAP protocol hub router to enable background data sync orchestration.",
        "welcome.hub.address": "Hub Address / Host",
        "welcome.hub.port": "Target TCP Port",
        "welcome.hub.dispatch": "Dispatch Connection",

        "welcome.chan.header": "Initialize First Channel",
        "welcome.chan.desc": "Establish or subscribe to a communication URI space instance channel to initiate message interactions.",
        "welcome.chan.uri": "Channel Address Identity URI",
        "welcome.chan.friendly": "Descriptive Friendly Label Name (Optional)",
        "welcome.chan.placeholder": "Global Mesh Exchange Channel",

        "welcome.btn.prev": "Previous",
        "welcome.btn.next": "Next",

        // Certificate Management Page
        "cert.title": "Certificate Management",
        "cert.desc": "Manage PKI credentials, trust stores, and identity certificates.",
        "cert.send": "Send Certificate",
        "cert.your_identity": "Your Identity Certificate",
        "cert.export_public": "Export Public Key",
        "cert.pending": "Pending Requests",
        "cert.no_pending": "No pending credential requests",
        "cert.adv_filter": "Advanced Filtering",
        "cert.filter_by": "Filter by:",
        "cert.all": "All Certificates",
        "cert.issuer": "By Issuer",
        "cert.subject": "By Subject",
        "cert.trust_level": "By Trust Level",
        "cert.apply": "Apply",
        "cert.clear": "Clear",
        "cert.trusted_peer": "Trusted Peer Certificates",
        "cert.search_placeholder": "Search Certificates...",
        "cert.th.subject": "Subject",
        "cert.th.issuer": "Issuer",
        "cert.th.valid_until": "Valid Until",
        "cert.th.trust_level": "Trust Level",
        "cert.loading": "Loading certificates...",
        "cert.revoke.title": "Revoke Certificate",
        "cert.revoke.warning": "<strong>⚠️ Warning:</strong> This action cannot be undone. The certificate will be revoked and can no longer be used for verification.",

        // Peer Management Page
        "contacts.title": "Peer Management",
        "contacts.desc": "Create, start, stop, and manage your local peers.",
        "contacts.create_btn": "Create New Peer",
        "contacts.local_peers": "Local Peers",
        "contacts.th.status": "Status",
        "contacts.th.details": "Peer Details",
        "contacts.loading": "Loading peers...",
        "contacts.modal.title": "Create New Peer",
        "contacts.modal.label": "Peer Name",
        "contacts.modal.placeholder": "e.g. My Local Node",

        // Login Page Localization Mapping
        "login.subtitle": "Decentralized P2P Communication",
        "login.processing": "Processing request...",
        "login.select_peer": "Select Existing Peer",
        "login.select_peer_placeholder": "-- Select a peer --",
        "login.btn_continue": "Continue",
        "login.or": "OR",
        "login.create_peer": "Create New Peer",
        "login.peer_name_placeholder": "Enter peer name...",
        "login.btn_create": "Create New Peer",
        "login.btn_refresh": "Refresh Peer List",

        // ASAP Hub Management Localization Mapping
        "hubs.title": "ASAP Hub Management",
        "hubs.desc": "Connect and manage your ASAP Hub connections.",
        "hubs.connect_title": "Connect to Hub",
        "hubs.address_label": "Hub Address",
        "hubs.address_placeholder": "e.g., 192.168.1.50 or hub.sharknet.org",
        "hubs.port_label": "Port",
        "hubs.port_placeholder": "e.g., 9001",
        "hubs.btn_connect": "Connect",
        "hubs.open_title": "Open Local Port",
        "hubs.btn_open": "Open Port",
        "hubs.active_connections": "Active Hub Connections",
        "hubs.loading": "Loading active connections...",

        // Network Overview Page
        "net.title": "Network Overview",
        "net.desc": "Manage direct TCP connections and open ports.",
        "net.refresh": "Refresh Network",
        "net.direct_conns": "Direct TCP Connections",
        "net.listen_port": "Listen on New Port",
        "net.port_number": "Port Number",
        "net.btn_open": "Open Port",
        "net.connect_peer": "Connect to Peer",
        "net.peer_address": "Peer Address",
        "net.btn_connect": "Connect",
        "net.active_ports": "Active TCP Ports",
        "net.th.port": "Port",
        "net.th.status": "Status",
        "net.established_conns": "Established Connections",
        "net.remote_address": "Remote Address",
        "net.remote_port": "Remote Port",
        "net.status.listening": "Listening",
        "net.status.connected": "Connected",
        "net.no_ports": "No active TCP ports.",
        "net.no_conns": "No outgoing connections visible.",
        "net.operational": "Network Status: All systems operational",
        "net.alert.port": "Please enter a port number.",
        "net.alert.address_port": "Please enter both address and port.",
        "net.confirm.close": "Are you sure you want to close port ",

        // Persons Management Page
        "persons.title": "Persons Management",
        "persons.desc": "Manage PKI identities, trust levels, and contact information.",
        "persons.btn_refresh": "Refresh Data",
        "persons.overview_title": "Known Persons Overview",
        "persons.total_persons": "Total Persons",
        "persons.trusted": "Trusted",
        "persons.unknown": "Unknown",
        "persons.all_persons": "All Persons",
        "persons.search_placeholder": "Search name or ID...",
        "persons.th.name": "Name",
        "persons.th.peer_id": "Peer ID",
        "persons.th.trust_level": "Trust Level",
        "persons.th.signing_rate": "Signing Rate",
        "persons.th.identity_assurance": "Identity Assurance",
        "persons.loading": "Loading persons...",
        "persons.modal.rename_title": "Rename Person",
        "persons.modal.current_name": "Current Name:",
        "persons.modal.new_name": "New Name:",
        "persons.modal.new_name_placeholder": "Enter new name",
        "persons.modal.btn_rename": "Rename",
        "persons.modal.details_title": "Person Details",

        // Profile Page Localization
        "prof.title": "Peer Profile",
        "prof.desc": "Manage your decentralized identity and view network metrics.",
        "prof.active_identity": "Active Identity",
        "prof.export": "Export Identity",
        "prof.crypto_id": "Cryptographic Identity",
        "prof.peer_id": "Peer ID",
        "prof.fingerprint": "Public Key Fingerprint",
        "prof.resolving": "Resolving from PKI...",
        "prof.net_activity": "Network Activity",
        "prof.connections": "Connections",
        "prof.open_ports": "Open Ports",
        "prof.messaging_status": "Messaging Status",
        "prof.wot": "Web of Trust Summary",
        "prof.trusted_status": "Trusted",
        "prof.wot_desc": "Your identity has been verified and trusted by multiple peers within your local mesh network.",
        "prof.badge_verified": "Verified Certificates: 3",
        "prof.badge_direct_trust": "Direct Trust: High",
        "prof.badge_no_flags": "No security flags"


    },


    de: {
        // Common
        "common.cancel": "Abbrechen",
        "common.save": "Speichern",
        "common.close": "Schließen",
        "common.refresh": "Aktualisieren",
        "common.loading": "Wird geladen...",
        "common.status": "Status",
        "common.actions": "Aktionen",

        // Sidebar
        "nav.messenger": "Nachrichten",
        "nav.peer": "Peer-Kontakte",
        "nav.persons": "Personen",
        "nav.certificates": "Zertifikate",
        "nav.network": "Netzwerkstatus",
        "nav.hubs": "ASAP Hubs",
        "nav.settings": "Einstellungen",
        "nav.profile": "Mein Profil",
        "nav.help": "Hilfe",

        // Header
        "header.internet": "Internet",
        "header.logout": "Abmelden",
        "header.logout_confirm": "Abmeldung bestätigen",
        "header.logout_desc": "Möchten Sie sich wirklich abmelden?<br>Dies stoppt den aktiven Peer und leitet Sie zur Anmeldeseite weiter.",

        // Settings Page
        "settings.title": "Einstellungen & Konfiguration",
        "settings.desc": "Verwalten Sie Peer-Konfigurationen und Anwendungseinstellungen.",
        "settings.app_settings": "Anwendungseinstellungen",
        "settings.msg_defaults": "Nachrichten-Standards",
        "settings.sign_default": "Nachrichten standardmäßig signieren",
        "settings.enc_default": "Nachrichten standardmäßig verschlüsseln",
        "settings.hub_settings": "Hub-Verbindungseinstellungen",
        "settings.remember_hubs": "Neue Hub-Verbindungen merken",
        "settings.remember_hubs_desc": "Zuvor genutzte Hub-Verbindungen automatisch speichern und wiederverbinden.",
        "settings.reconnect_hubs": "Hub-Wiederverbindung aktivieren",
        "settings.reconnect_hubs_desc": "Automatisch versuchen, die Verbindung zu Hubs wiederherzustellen, wenn diese abbricht.",

        // Messenger Page
        "msg.channels": "Kanäle",
        "msg.create_channel": "Kanal erstellen",
        "msg.search_ph": "Text suchen...",
        "msg.filters": "Filter",
        "msg.sender_name": "Absender",
        "msg.from_date": "Von Datum",
        "msg.to_date": "Bis Datum",
        "msg.clear_filters": "Filter löschen",
        "msg.type_here": "Schreiben Sie Ihre Nachricht hier...",
        "msg.send": "Senden",
        "msg.sign": "Signieren",
        "msg.encrypt": "Verschlüsseln",
        "msg.peer_info": "Peer-Info",
        "msg.stats": "Statistiken",

        // Profile Page
        "prof.title": "Peer Profil",
        "prof.desc": "Verwalten Sie Ihre dezentrale Identität und Netzwerkmetriken.",
        "prof.export": "Identität exportieren",
        "prof.crypto_id": "Kryptografische Identität",
        "prof.fingerprint": "Öffentlicher Schlüssel-Fingerabdruck",
        "prof.net_activity": "Netzwerkaktivität",
        "prof.connections": "Verbindungen",
        "prof.open_ports": "Offene Ports",
        "prof.wot": "Web of Trust Zusammenfassung",
        "prof.wot_desc": "Ihre Identität wurde von mehreren Peers in Ihrem lokalen Mesh-Netzwerk verifiziert und als vertrauenswürdig eingestuft.",

        // Onboarding / Welcome Alerts
        "welcome.alert.name_required": "Bitte geben Sie Ihren Anzeigenamen ein, um fortzufahren.",
        "welcome.alert.hub_required": "Bitte geben Sie sowohl die Zieladresse als auch die Port-Zuweisungen ein.",
        "welcome.alert.hub_failed": "Fehler beim Senden des Betriebskontexts an den Ziel-Hub.",
        "welcome.alert.uri_required": "Eine gültige Kanal-URI ist erforderlich.",
        "welcome.alert.channel_failed": "Fehler beim Initialisieren Ihres ersten Kanals: ",

        // Onboarding Welcome Page
        "welcome.step.profile": "Profil",
        "welcome.step.pki": "Schlüssel (PKI)",
        "welcome.step.hub": "Hub-Link",
        "welcome.step.channels": "Kanäle",

        "welcome.prof.header": "Benutzerprofil konfigurieren",
        "welcome.prof.desc": "Richten Sie Ihren lokalen Anzeigenamen für diese SharkNet-Peer-Identität ein.",
        "welcome.prof.label": "Benutzerdefinierter Peer-Name",
        "welcome.prof.placeholder": "z.B. Shark_Node_Alpha",
        "welcome.prof.info": "Diese Konfiguration legt Ihre persönliche Kennung in aktiven Kanälen innerhalb des dezentralen Frameworks fest.",

        "welcome.pki.header": "Kryptografische Schlüsselinfrastruktur",
        "welcome.pki.desc": "Ihre sicheren dezentralen kryptografischen Identitätsdaten werden automatisch verwaltet.",
        "welcome.pki.status": "PKI-Infrastrukturstatus:",
        "welcome.pki.active": "Aktiv",
        "welcome.pki.hash": "Öffentlicher Schlüssel-Fingerabdruck-Hash",
        "welcome.pki.resolving": "Identitäts-Fingerabdruck-String wird aufgelöst...",
        "welcome.pki.storage": "Schlüssel werden sicher in Ihren lokalen Peer-Datenpartitionsverzeichnissen gespeichert.",

        "welcome.hub.header": "Hub-Verbindung herstellen",
        "welcome.hub.desc": "Verbinden Sie sich mit einem aktiven ASAP-Protokoll-Hub-Router, um die Synchronisation im Hintergrund zu aktivieren.",
        "welcome.hub.address": "Hub-Adresse / Host",
        "welcome.hub.port": "Ziel-TCP-Port",
        "welcome.hub.dispatch": "Verbindung senden",

        "welcome.chan.header": "Ersten Kanal initialisieren",
        "welcome.chan.desc": "Erstellen oder abonnieren Sie einen Kommunikations-URI-Raum, um Nachrichtenaustausch zu starten.",
        "welcome.chan.uri": "Kanal-Adressidentitäts-URI",
        "welcome.chan.friendly": "Beschreibender Anzeigename (Optional)",
        "welcome.chan.placeholder": "Globaler Mesh-Austauschkanal",

        "welcome.btn.prev": "Zurück",
        "welcome.btn.next": "Weiter",

        // Certificate Management Page
        "cert.title": "Zertifikatsverwaltung",
        "cert.desc": "Verwalten Sie PKI-Anmeldedaten, Vertrauensspeicher und Identitätszertifikate.",
        "cert.send": "Zertifikat senden",
        "cert.your_identity": "Ihr Identitätszertifikat",
        "cert.export_public": "Öffentlichen Schlüssel exportieren",
        "cert.pending": "Ausstehende Anfragen",
        "cert.no_pending": "Keine ausstehenden Anmeldedaten-Anfragen",
        "cert.adv_filter": "Erweiterte Filterung",
        "cert.filter_by": "Filtern nach:",
        "cert.all": "Alle Zertifikate",
        "cert.issuer": "Nach Aussteller",
        "cert.subject": "Nach Betreff",
        "cert.trust_level": "Nach Vertrauensstufe",
        "cert.apply": "Anwenden",
        "cert.clear": "Löschen",
        "cert.trusted_peer": "Vertrauenswürdige Peer-Zertifikate",
        "cert.search_placeholder": "Zertifikate suchen...",
        "cert.th.subject": "Betreff",
        "cert.th.issuer": "Aussteller",
        "cert.th.valid_until": "Gültig bis",
        "cert.th.trust_level": "Vertrauensstufe",
        "cert.loading": "Zertifikate werden geladen...",
        "cert.revoke.title": "Zertifikat widerrufen",
        "cert.revoke.warning": "<strong>⚠️ Warnung:</strong> Diese Aktion kann nicht rückgängig gemacht werden. Das Zertifikat wird widerrufen und kann nicht mehr zur Verifizierung verwendet werden.",

        // Peer Management Page
        "contacts.title": "Peer-Verwaltung",
        "contacts.desc": "Erstellen, starten, stoppen und verwalten Sie Ihre lokalen Peers.",
        "contacts.create_btn": "Neuen Peer erstellen",
        "contacts.local_peers": "Lokale Peers",
        "contacts.th.status": "Status",
        "contacts.th.details": "Peer-Details",
        "contacts.loading": "Peers werden geladen...",
        "contacts.modal.title": "Neuen Peer erstellen",
        "contacts.modal.label": "Peer-Name",
        "contacts.modal.placeholder": "z.B. Mein lokaler Knoten",


        // Login Page Localization Mapping
        "login.subtitle": "Dezentrale P2P-Kommunikation",
        "login.processing": "Anfrage wird verarbeitet...",
        "login.select_peer": "Bestehenden Peer auswählen",
        "login.select_peer_placeholder": "-- Peer auswählen --",
        "login.btn_continue": "Weiter",
        "login.or": "ODER",
        "login.create_peer": "Neuen Peer erstellen",
        "login.peer_name_placeholder": "Peer-Namen eingeben...",
        "login.btn_create": "Neuen Peer erstellen",
        "login.btn_refresh": "Peer-Liste aktualisieren",

        // ASAP Hub Management Localization Mapping
        "hubs.title": "ASAP-Hub-Verwaltung",
        "hubs.desc": "Verbinden und verwalten Sie Ihre ASAP-Hub-Verbindungen.",
        "hubs.connect_title": "Mit Hub verbinden",
        "hubs.address_label": "Hub-Adresse",
        "hubs.address_placeholder": "z.B. 192.168.1.50 oder hub.sharknet.org",
        "hubs.port_label": "Port",
        "hubs.port_placeholder": "z.B. 9001",
        "hubs.btn_connect": "Verbinden",
        "hubs.open_title": "Lokalen Port öffnen",
        "hubs.btn_open": "Port öffnen",
        "hubs.active_connections": "Aktive Hub-Verbindungen",
        "hubs.loading": "Aktive Verbindungen werden geladen...",


        // Network Overview Page
        "net.title": "Netzwerkübersicht",
        "net.desc": "Direkte TCP-Verbindungen und offene Ports verwalten.",
        "net.refresh": "Netzwerk aktualisieren",
        "net.direct_conns": "Direkte TCP-Verbindungen",
        "net.listen_port": "Auf neuem Port lauschen",
        "net.port_number": "Portnummer",
        "net.btn_open": "Port öffnen",
        "net.connect_peer": "Mit Peer verbinden",
        "net.peer_address": "Peer-Adresse",
        "net.btn_connect": "Verbinden",
        "net.active_ports": "Aktive TCP-Ports",
        "net.th.port": "Port",
        "net.th.status": "Status",
        "net.established_conns": "Hergestellte Verbindungen",
        "net.remote_address": "Remote-Adresse",
        "net.remote_port": "Remote-Port",
        "net.status.listening": "Lauschen",
        "net.status.connected": "Verbunden",
        "net.no_ports": "Keine aktiven TCP-Ports.",
        "net.no_conns": "Keine ausgehenden Verbindungen sichtbar.",
        "net.operational": "Netzwerkstatus: Alle Systeme betriebsbereit",
        "net.alert.port": "Bitte geben Sie eine Portnummer ein.",
        "net.alert.address_port": "Bitte geben Sie sowohl Adresse als auch Port ein.",
        "net.confirm.close": "Sind Sie sicher, dass Sie den Port schließen möchten: ",

        // Persons Management Page
        "persons.title": "Personenverwaltung",
        "persons.desc": "Verwalten Sie PKI-Identitäten, Vertrauensstufen und Kontaktinformationen.",
        "persons.btn_refresh": "Daten aktualisieren",
        "persons.overview_title": "Übersicht bekannter Personen",
        "persons.total_persons": "Personen insgesamt",
        "persons.trusted": "Vertrauenswürdig",
        "persons.unknown": "Unbekannt",
        "persons.all_persons": "Alle Personen",
        "persons.search_placeholder": "Name oder ID suchen...",
        "persons.th.name": "Name",
        "persons.th.peer_id": "Peer-ID",
        "persons.th.trust_level": "Vertrauensstufe",
        "persons.th.signing_rate": "Signierungsrate",
        "persons.th.identity_assurance": "Identitätsabsicherung",
        "persons.loading": "Personen werden geladen...",
        "persons.modal.rename_title": "Person umbenennen",
        "persons.modal.current_name": "Aktueller Name:",
        "persons.modal.new_name": "Neuer Name:",
        "persons.modal.new_name_placeholder": "Neuen Namen eingeben",
        "persons.modal.btn_rename": "Umbenennen",
        "persons.modal.details_title": "Personendetails",

        // Profile Page Localization
        "prof.title": "Peer-Profil",
        "prof.desc": "Verwalten Sie Ihre dezentrale Identität und zeigen Sie Netzwerkmetriken an.",
        "prof.active_identity": "Aktive Identität",
        "prof.export": "Identität exportieren",
        "prof.crypto_id": "Kryptografische Identität",
        "prof.peer_id": "Peer-ID",
        "prof.fingerprint": "Öffentlicher Schlüssel-Fingerabdruck",
        "prof.resolving": "Wird von PKI aufgelöst...",
        "prof.net_activity": "Netzwerkaktivität",
        "prof.connections": "Verbindungen",
        "prof.open_ports": "Offene Ports",
        "prof.messaging_status": "Nachrichtenstatus",
        "prof.wot": "Web of Trust Zusammenfassung",
        "prof.trusted_status": "Vertrauenswürdig",
        "prof.wot_desc": "Ihre Identität wurde von mehreren Peers in Ihrem lokalen Mesh-Netzwerk verifiziert und als vertrauenswürdig eingestuft.",
        "prof.badge_verified": "Verifizierte Zertifikate: 3",
        "prof.badge_direct_trust": "Direktes Vertrauen: Hoch",
        "prof.badge_no_flags": "Keine Sicherheitsflaggen"
    }

};

/**
 * Applies the selected language to all HTML elements with the 'data-i18n' attribute.
 * @param {string} lang - The target language code ('en' or 'de')
 * @return {void}
 */
function setLanguage(lang) {
    localStorage.setItem('snm-lang', lang);
    document.documentElement.lang = lang;

    // Update standard HTML text elements
    document.querySelectorAll('[data-i18n]').forEach(el => {
        const key = el.getAttribute('data-i18n');
        if (translations[lang] && translations[lang][key]) {
            el.innerHTML = translations[lang][key]; // innerHTML allows <br> tags in translations
        }
    });

    // Update Input Placeholders if they have data-i18n-placeholder
    document.querySelectorAll('[data-i18n-placeholder]').forEach(el => {
        const key = el.getAttribute('data-i18n-placeholder');
        if (translations[lang] && translations[lang][key]) {
            el.setAttribute('placeholder', translations[lang][key]);
        }
    });
}

/**
 * Initialize language settings on page load.
 */
document.addEventListener('DOMContentLoaded', () => {
    let savedLang = localStorage.getItem('snm-lang');

    if (!savedLang) {
        const browserLang = navigator.language || navigator.userLanguage;
        savedLang = browserLang.startsWith('de') ? 'de' : 'en';
    }

    setLanguage(savedLang);
});