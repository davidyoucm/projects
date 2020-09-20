const CACHE_NAME = "static-files-cache";

self.addEventListener("install", evt => {
  console.log("[ServiceWorker] Install");
  // CODELAB: Precache static resources here.
  evt.waitUntil(
    fetch("/cacheable")
      .then(res => res.json())
      .then(files => caches.open(CACHE_NAME).then(cache => [files, cache]))
      .then(([files, cache]) => {
        console.log("[ServiceWorker] Pre-caching offline page");
        files = files.filter(file => file !== "/service-worker.js");
        files.push("/");
        return cache.addAll(files);
      })
      .catch(err => console.warn("Failed to fetch /cacheable:", err))
  );
  self.skipWaiting();
});

self.addEventListener("activate", evt => {
  console.log("[ServiceWorker] Activate");
  // CODELAB: Remove previous cached data from disk.
  evt.waitUntil(
    caches.keys().then(keyList => {
      return Promise.all(
        keyList.map(key => {
          if (key !== CACHE_NAME) {
            console.log("[ServiceWorker] Removing old cache", key);
            return caches.delete(key);
          }
        })
      );
    })
  );
  self.clients.claim();
});

self.addEventListener("fetch", evt => {
  console.log("[ServiceWorker] Fetch", evt.request.url);
  // CODELAB: Add fetch event handler here.
  evt.respondWith(
    new Promise(async (resolve, reject) => {
      let cache;
      try {
        cache = await caches.open(CACHE_NAME);
        if (cache) {
          const res = await cache.match(evt.request);
          if (res) resolve(res);
          else resolve(await fetch(evt.request));
        }
        const url = new URL(evt.request.url);
        if (cache && (url.protocol === "https:" || url.protocol === "http:"))
          await cache.add(evt.request.url);
      } catch (err) {
        if (cache) {
          const res = await cache.match(evt.request);
          if (res) return resolve(res);
        }
        reject(new Error(`Cannot fetch request for ${evt.request.url}`));
      }
    })
  );
});
