'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';

const RESOURCES = {"assets/AssetManifest.bin": "86303fa2bfe18e5ded8c73f23abdd5f0",
"assets/AssetManifest.bin.json": "6a6625365f039e1e93d4e9937b1b7f24",
"assets/AssetManifest.json": "ab8b8c11c60ab18b0cd153fbbf74974a",
"assets/assets/data/videos_db.json": "90a5267c7c31401b7d42e397c08e1781",
"assets/assets/images/deepfake_Pope.JPG": "b66c30051fb443878ed48a543c1de788",
"assets/assets/images/real_Pope.JPG": "71b427f4375b5021f266dafff6ae817e",
"assets/assets/thumbnails/deepfake/id13_id10_0011.png": "106e4266a24828252397d04eb5e5c5b8",
"assets/assets/thumbnails/deepfake/id16_id6_0012.png": "781017b96c66977cefb4989696b875c0",
"assets/assets/thumbnails/deepfake/id26_id25_0006.png": "4bff19d4b8f6c91a45471267d03126f4",
"assets/assets/thumbnails/deepfake/id29_id23_0000.png": "af069450ba9e6fe044739c7aa8f7e012",
"assets/assets/thumbnails/deepfake/id32_id34_0003.png": "63dac64422f09c0ec4cc751e774685f9",
"assets/assets/thumbnails/deepfake/id33_id26_0003.png": "e3efe6689e907a5d4dbaaba7f2f7763f",
"assets/assets/thumbnails/deepfake/id40_id44_0003.png": "ef2d37c0b2a603ea636b4b590f55913a",
"assets/assets/thumbnails/deepfake/id51_id50_0002.png": "7340eda7f2527ae85a07cd6f61b2d72d",
"assets/assets/thumbnails/deepfake/id58_id55_0002.png": "520ae3117346cde11e0515eeb4c87a86",
"assets/assets/thumbnails/deepfake/id60_id61_0003.png": "b549d144810493da094652be32478787",
"assets/assets/thumbnails/deepfake/id9_id26_0000.png": "a31e85e3600f3dc0dab4634156a5e70d",
"assets/assets/thumbnails/real/id13_0011.png": "0a779995816d2e10f38087a3e5a29ef7",
"assets/assets/thumbnails/real/id16_0012.png": "15445a5d32b7530a2b2f13e769c6d36c",
"assets/assets/thumbnails/real/id26_0006.png": "5720c120118b1d15a0009149833baebc",
"assets/assets/thumbnails/real/id29_0000.png": "821a84d9c8493f23bb954b2d71b69500",
"assets/assets/thumbnails/real/id32_0003.png": "052293d2ed28808cbb9d698352b8a1be",
"assets/assets/thumbnails/real/id33_0003.png": "f1df77b49a8fb649adee3a41ea0af3c0",
"assets/assets/thumbnails/real/id40_0003.png": "a8ebe9f346ec54542835c77f9f43eea3",
"assets/assets/thumbnails/real/id51_0002.png": "0885ecede739f30b17815ef5449d5e68",
"assets/assets/thumbnails/real/id58_0002.png": "74d116abbe4ca6bad27b89135dc402d8",
"assets/assets/thumbnails/real/id60_0003.png": "7d54bcb03f8674c8bf5fea87929981c3",
"assets/assets/thumbnails/real/id9_0000.png": "65412db20b42c97ba45f6613f5f010f4",
"assets/assets/videos/deepfake/id13_id10_0011_c.mp4": "f94ebed52c01c52d1bfadd8dbcb903a7",
"assets/assets/videos/deepfake/id16_id6_0012_c.mp4": "b2c108aa2dda90d20844e0ed6ba7dbfc",
"assets/assets/videos/deepfake/id26_id25_0006_c.mp4": "d396ac47b094edc7aca3324d9e77dede",
"assets/assets/videos/deepfake/id29_id23_0000_c.mp4": "d0a1ddb691040d2691e03c3788e34d00",
"assets/assets/videos/deepfake/id32_id34_0003_c.mp4": "4b2e0e01113cc5e75200aab8aa1e9a63",
"assets/assets/videos/deepfake/id33_id26_0003_c.mp4": "6f7ecc9c7f26ff9eff48b1a28b09cdc9",
"assets/assets/videos/deepfake/id40_id44_0003_c.mp4": "230636c2e92a97cb4142b71b8b0b42f0",
"assets/assets/videos/deepfake/id51_id50_0002_c.mp4": "256f17bb76f8b0208fc5cf736599830b",
"assets/assets/videos/deepfake/id58_id55_0002_c.mp4": "6ae3770910957f8d54b68dd592ebe080",
"assets/assets/videos/deepfake/id60_id61_0003_c.mp4": "d0be7615f8692413d03821698e6cd255",
"assets/assets/videos/deepfake/id9_id26_0000_c.mp4": "cf0cdaabf0c0b703ffcdb12e6de4deea",
"assets/assets/videos/real/id13_0011_c.mp4": "b5105870a330e373fd8447ea7da65d26",
"assets/assets/videos/real/id16_0012_c.mp4": "419559b72598b1d9d36fb25a18315798",
"assets/assets/videos/real/id26_0006_c.mp4": "07e72850db7d74939b63457109b47054",
"assets/assets/videos/real/id29_0000_c.mp4": "caa57114a3344ca058ed45d98297e819",
"assets/assets/videos/real/id32_0003_c.mp4": "db61d4b27efeea69098fe2000e7b956b",
"assets/assets/videos/real/id33_0003_c.mp4": "0fac5cf351ac15446ccf613d95596b80",
"assets/assets/videos/real/id40_0003_c.mp4": "0d1f6ff477f3b294ed91e5630b493936",
"assets/assets/videos/real/id51_0002_c.mp4": "fb21b24bf820664606f5b5cff5e26ff5",
"assets/assets/videos/real/id58_0002_c.mp4": "7e21191215364b7ca35248abff5ecdb1",
"assets/assets/videos/real/id60_0003_c.mp4": "454842d5977d6b6b4136ceb5723a78e5",
"assets/assets/videos/real/id9_0000_c.mp4": "865f114d28b8559bd86606c6e34bbae9",
"assets/FontManifest.json": "dc3d03800ccca4601324923c0b1d6d57",
"assets/fonts/MaterialIcons-Regular.otf": "fe32849edbc53ad8faa4858a1ffe72cd",
"assets/NOTICES": "2df794e1a3773236e81d14724d890c2c",
"assets/packages/cupertino_icons/assets/CupertinoIcons.ttf": "e986ebe42ef785b27164c36a9abc7818",
"assets/shaders/ink_sparkle.frag": "ecc85a2e95f5e9f53123dcaf8cb9b6ce",
"canvaskit/canvaskit.js": "26eef3024dbc64886b7f48e1b6fb05cf",
"canvaskit/canvaskit.js.symbols": "efc2cd87d1ff6c586b7d4c7083063a40",
"canvaskit/canvaskit.wasm": "e7602c687313cfac5f495c5eac2fb324",
"canvaskit/chromium/canvaskit.js": "b7ba6d908089f706772b2007c37e6da4",
"canvaskit/chromium/canvaskit.js.symbols": "e115ddcfad5f5b98a90e389433606502",
"canvaskit/chromium/canvaskit.wasm": "ea5ab288728f7200f398f60089048b48",
"canvaskit/skwasm.js": "ac0f73826b925320a1e9b0d3fd7da61c",
"canvaskit/skwasm.js.symbols": "96263e00e3c9bd9cd878ead867c04f3c",
"canvaskit/skwasm.wasm": "828c26a0b1cc8eb1adacbdd0c5e8bcfa",
"canvaskit/skwasm.worker.js": "89990e8c92bcb123999aa81f7e203b1c",
"favicon.png": "5dcef449791fa27946b3d35ad8803796",
"flutter.js": "4b2350e14c6650ba82871f60906437ea",
"flutter_bootstrap.js": "4cfb1c0660ec45baa534bcc458f11ccb",
"icons/Icon-192.png": "ac9a721a12bbc803b44f645561ecb1e1",
"icons/Icon-512.png": "96e752610906ba2a93c65f8abe1645f1",
"icons/Icon-maskable-192.png": "c457ef57daa1d16f64b27b786ec2ea3c",
"icons/Icon-maskable-512.png": "301a7604d45b3e739efc881eb04896ea",
"index.html": "a1bd1e6a284d2bcfd37b6d5be05c007d",
"/": "a1bd1e6a284d2bcfd37b6d5be05c007d",
"main.dart.js": "78d2c8bbb93ea5d4394fa3165e943c76",
"manifest.json": "09a0597e9a883d02c65ce6310e815fa1",
"version.json": "f4d6484882f06d1a1bf382074b129eb8"};
// The application shell files that are downloaded before a service worker can
// start.
const CORE = ["main.dart.js",
"index.html",
"flutter_bootstrap.js",
"assets/AssetManifest.bin.json",
"assets/FontManifest.json"];

// During install, the TEMP cache is populated with the application shell files.
self.addEventListener("install", (event) => {
  self.skipWaiting();
  return event.waitUntil(
    caches.open(TEMP).then((cache) => {
      return cache.addAll(
        CORE.map((value) => new Request(value, {'cache': 'reload'})));
    })
  );
});
// During activate, the cache is populated with the temp files downloaded in
// install. If this service worker is upgrading from one with a saved
// MANIFEST, then use this to retain unchanged resource files.
self.addEventListener("activate", function(event) {
  return event.waitUntil(async function() {
    try {
      var contentCache = await caches.open(CACHE_NAME);
      var tempCache = await caches.open(TEMP);
      var manifestCache = await caches.open(MANIFEST);
      var manifest = await manifestCache.match('manifest');
      // When there is no prior manifest, clear the entire cache.
      if (!manifest) {
        await caches.delete(CACHE_NAME);
        contentCache = await caches.open(CACHE_NAME);
        for (var request of await tempCache.keys()) {
          var response = await tempCache.match(request);
          await contentCache.put(request, response);
        }
        await caches.delete(TEMP);
        // Save the manifest to make future upgrades efficient.
        await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
        // Claim client to enable caching on first launch
        self.clients.claim();
        return;
      }
      var oldManifest = await manifest.json();
      var origin = self.location.origin;
      for (var request of await contentCache.keys()) {
        var key = request.url.substring(origin.length + 1);
        if (key == "") {
          key = "/";
        }
        // If a resource from the old manifest is not in the new cache, or if
        // the MD5 sum has changed, delete it. Otherwise the resource is left
        // in the cache and can be reused by the new service worker.
        if (!RESOURCES[key] || RESOURCES[key] != oldManifest[key]) {
          await contentCache.delete(request);
        }
      }
      // Populate the cache with the app shell TEMP files, potentially overwriting
      // cache files preserved above.
      for (var request of await tempCache.keys()) {
        var response = await tempCache.match(request);
        await contentCache.put(request, response);
      }
      await caches.delete(TEMP);
      // Save the manifest to make future upgrades efficient.
      await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
      // Claim client to enable caching on first launch
      self.clients.claim();
      return;
    } catch (err) {
      // On an unhandled exception the state of the cache cannot be guaranteed.
      console.error('Failed to upgrade service worker: ' + err);
      await caches.delete(CACHE_NAME);
      await caches.delete(TEMP);
      await caches.delete(MANIFEST);
    }
  }());
});
// The fetch handler redirects requests for RESOURCE files to the service
// worker cache.
self.addEventListener("fetch", (event) => {
  if (event.request.method !== 'GET') {
    return;
  }
  var origin = self.location.origin;
  var key = event.request.url.substring(origin.length + 1);
  // Redirect URLs to the index.html
  if (key.indexOf('?v=') != -1) {
    key = key.split('?v=')[0];
  }
  if (event.request.url == origin || event.request.url.startsWith(origin + '/#') || key == '') {
    key = '/';
  }
  // If the URL is not the RESOURCE list then return to signal that the
  // browser should take over.
  if (!RESOURCES[key]) {
    return;
  }
  // If the URL is the index.html, perform an online-first request.
  if (key == '/') {
    return onlineFirst(event);
  }
  event.respondWith(caches.open(CACHE_NAME)
    .then((cache) =>  {
      return cache.match(event.request).then((response) => {
        // Either respond with the cached resource, or perform a fetch and
        // lazily populate the cache only if the resource was successfully fetched.
        return response || fetch(event.request).then((response) => {
          if (response && Boolean(response.ok)) {
            cache.put(event.request, response.clone());
          }
          return response;
        });
      })
    })
  );
});
self.addEventListener('message', (event) => {
  // SkipWaiting can be used to immediately activate a waiting service worker.
  // This will also require a page refresh triggered by the main worker.
  if (event.data === 'skipWaiting') {
    self.skipWaiting();
    return;
  }
  if (event.data === 'downloadOffline') {
    downloadOffline();
    return;
  }
});
// Download offline will check the RESOURCES for all files not in the cache
// and populate them.
async function downloadOffline() {
  var resources = [];
  var contentCache = await caches.open(CACHE_NAME);
  var currentContent = {};
  for (var request of await contentCache.keys()) {
    var key = request.url.substring(origin.length + 1);
    if (key == "") {
      key = "/";
    }
    currentContent[key] = true;
  }
  for (var resourceKey of Object.keys(RESOURCES)) {
    if (!currentContent[resourceKey]) {
      resources.push(resourceKey);
    }
  }
  return contentCache.addAll(resources);
}
// Attempt to download the resource online before falling back to
// the offline cache.
function onlineFirst(event) {
  return event.respondWith(
    fetch(event.request).then((response) => {
      return caches.open(CACHE_NAME).then((cache) => {
        cache.put(event.request, response.clone());
        return response;
      });
    }).catch((error) => {
      return caches.open(CACHE_NAME).then((cache) => {
        return cache.match(event.request).then((response) => {
          if (response != null) {
            return response;
          }
          throw error;
        });
      });
    })
  );
}
