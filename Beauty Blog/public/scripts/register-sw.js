/**
 * If you want to "enable" PWA offline and caching capabilities,
 * please make sure you set window.ENABLE_SERVICE_WORKER = true
 *
 * If you want to "disable" PWA offline and caching capabilities,
 * please make sure you set window.ENABLE_SERVICE_WORKER = false
 */
window.ENABLE_SERVICE_WORKER = true; // Set this to true to register service worker

if ("serviceWorker" in navigator) {
  if (!window.ENABLE_SERVICE_WORKER) {
    navigator.serviceWorker.getRegistrations().then(function(registrations) {
      for (let registration of registrations) {
        registration.unregister();
      }
    });
  } else {
    window.addEventListener("load", () => {
      navigator.serviceWorker.register("/service-worker.js").then(reg => {
        console.log("Service worker registered.", reg);
      });
    });
  }
}
