// AbsensiKu Service Worker v3
// Versi ini memastikan installable sebagai app native Android

const CACHE_NAME = 'absensiKu-v3';
const STATIC_ASSETS = [
  './',
  './index.html',
  './manifest.json',
  './icons/icon-192.png',
  './icons/icon-512.png'
];

// Install — cache aset penting
self.addEventListener('install', (event) => {
  console.log('[SW] Install v3');
  event.waitUntil(
    caches.open(CACHE_NAME)
      .then(cache => cache.addAll(STATIC_ASSETS.map(url => new Request(url, {mode:'no-cors'}))))
      .catch(err => console.warn('[SW] Cache partial fail:', err))
  );
  // Langsung aktif tanpa nunggu tab lama ditutup
  self.skipWaiting();
});

// Activate — bersihkan cache lama
self.addEventListener('activate', (event) => {
  console.log('[SW] Activate v3');
  event.waitUntil(
    caches.keys().then(keys =>
      Promise.all(keys.filter(k => k !== CACHE_NAME).map(k => caches.delete(k)))
    )
  );
  // Ambil kendali semua tab langsung
  self.clients.claim();
});

// Fetch — strategi cerdas per jenis request
self.addEventListener('fetch', (event) => {
  const url = new URL(event.request.url);

  // Supabase API — selalu network
  if(url.hostname.includes('supabase.co')) {
    event.respondWith(
      fetch(event.request).catch(() =>
        new Response('{"error":"offline"}', {
          status: 503,
          headers: {'Content-Type':'application/json'}
        })
      )
    );
    return;
  }

  // CDN (React, fonts, dll) — cache-first
  if(url.hostname.includes('cloudflare') || url.hostname.includes('googleapis') ||
     url.hostname.includes('gstatic') || url.hostname.includes('jsdelivr')) {
    event.respondWith(
      caches.match(event.request).then(cached => {
        if(cached) return cached;
        return fetch(event.request).then(resp => {
          if(resp && resp.ok) {
            const clone = resp.clone();
            caches.open(CACHE_NAME).then(c => c.put(event.request, clone));
          }
          return resp;
        }).catch(() => new Response('', {status:408}));
      })
    );
    return;
  }

  // File lokal (index.html, manifest, icons) — network-first dengan fallback cache
  if(event.request.method !== 'GET') return;

  event.respondWith(
    fetch(event.request).then(resp => {
      if(resp && resp.ok) {
        const clone = resp.clone();
        caches.open(CACHE_NAME).then(c => c.put(event.request, clone));
      }
      return resp;
    }).catch(() =>
      caches.match(event.request).then(cached =>
        cached || caches.match('./index.html')
      )
    )
  );
});

// Push notification
self.addEventListener('push', (event) => {
  if(!event.data) return;
  const data = event.data.json();
  self.registration.showNotification(data.title || 'AbsensiKu', {
    body: data.body || 'Ada notifikasi baru',
    icon: './icons/icon-192.png',
    badge: './icons/icon-72.png',
    vibrate: [200, 100, 200],
    data: { url: data.url || './' }
  });
});

self.addEventListener('notificationclick', (event) => {
  event.notification.close();
  event.waitUntil(clients.openWindow(event.notification.data.url || './'));
});
