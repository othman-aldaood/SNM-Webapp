/**
 * service-worker.js - Minimal PWA offline cache for SharkNet Messenger.
 *
 * Scope is intentionally narrow: only same-origin static assets (JS, CSS,
 * icons, the manifest) are cached. JSP pages and /api/* calls always hit the
 * network - this app is backed by a live, session-bound peer runtime, so
 * caching dynamic/authenticated responses would risk serving stale or
 * cross-session data while offline.
 */

const CACHE_VERSION = 'v1';
const STATIC_CACHE = `snm-static-${CACHE_VERSION}`;

const PRECACHE_URLS = [
    '/snm-webapp/manifest.json',
    '/snm-webapp/icons/icon-192.png',
    '/snm-webapp/icons/icon-512.png',
    '/snm-webapp/icons/icon-maskable-512.png',
    '/snm-webapp/icons/apple-touch-icon.png',
    '/snm-webapp/css/style.css',
    '/snm-webapp/css/messenger.css',
    '/snm-webapp/css/certificates.css',
    '/snm-webapp/css/persons.css',
    '/snm-webapp/css/settings.css',
    '/snm-webapp/js/i18n.js',
    '/snm-webapp/js/ui-ux.js',
    '/snm-webapp/js/messenger.js',
    '/snm-webapp/js/login.js',
    '/snm-webapp/js/settings.js',
    '/snm-webapp/js/persons.js',
    '/snm-webapp/js/contacts.js',
    '/snm-webapp/js/certificates.js',
    '/snm-webapp/js/hubs.js',
    '/snm-webapp/js/profile.js',
    '/snm-webapp/js/pki-tutorial.js',
    '/snm-webapp/js/welcome.js'
];

/** Static, cacheable file extensions - everything else is network-only. */
const STATIC_EXTENSIONS = ['.js', '.css', '.png', '.jpg', '.jpeg', '.svg', '.webp', '.woff', '.woff2'];

function isStaticAsset(url) {
    if (url.origin !== self.location.origin) return false;
    return STATIC_EXTENSIONS.some(ext => url.pathname.endsWith(ext)) || url.pathname.endsWith('/manifest.json');
}

self.addEventListener('install', event => {
    event.waitUntil(
        caches.open(STATIC_CACHE)
            .then(cache => cache.addAll(PRECACHE_URLS))
            .catch(err => console.warn('[service-worker] precache failed:', err))
    );
    self.skipWaiting();
});

self.addEventListener('activate', event => {
    event.waitUntil(
        caches.keys().then(keys =>
            Promise.all(
                keys.filter(key => key !== STATIC_CACHE)
                    .map(key => caches.delete(key))
            )
        )
    );
    self.clients.claim();
});

self.addEventListener('fetch', event => {
    if (event.request.method !== 'GET') return;

    const url = new URL(event.request.url);
    if (!isStaticAsset(url)) return; // let JSP pages and /api/* calls go straight to the network

    event.respondWith(
        caches.match(event.request).then(cached => {
            const networkFetch = fetch(event.request)
                .then(response => {
                    if (response && response.ok) {
                        const clone = response.clone();
                        caches.open(STATIC_CACHE).then(cache => cache.put(event.request, clone));
                    }
                    return response;
                })
                .catch(() => cached); // offline - fall back to cache if the network fails

            return cached || networkFetch;
        })
    );
});
