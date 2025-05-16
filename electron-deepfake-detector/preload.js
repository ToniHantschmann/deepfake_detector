const { contextBridge, ipcRenderer } = require('electron');

console.log('Preload script started');

// Nur die essentiellen Electron-Funktionen
contextBridge.exposeInMainWorld('electron', {
  isElectron: true,
  
  // Methode zum Speichern von Dateien
  saveFile: (filename, content) => {
    console.log('Renderer requesting to save file:', filename);
    return ipcRenderer.invoke('save-file', { filename, content });
  }
});

// Einfacher fetch-Interceptor für Assets
const originalFetch = window.fetch;
window.fetch = function(url, options) {
  // Nur für Asset-Anfragen
  if (typeof url === 'string' && url.startsWith('assets/')) {
    console.log('Asset request detected:', url);
    
    // Umleiten zu unserem IPC-Handler
    return ipcRenderer.invoke('fetch-asset', url).then(content => {
      if (!content) {
        console.error('Failed to load asset through IPC:', url);
        return originalFetch(url, options);
      }
      
      // Simuliere erfolgreiche fetch-Response
      return {
        ok: true,
        status: 200,
        text: () => Promise.resolve(content),
        json: () => Promise.resolve(JSON.parse(content))
      };
    }).catch(err => {
      console.error('Error in asset fetch interception:', err);
      return originalFetch(url, options);
    });
  }
  
  // Standardmäßiges fetch für alle anderen URLs
  return originalFetch(url, options);
};

// Image-Interceptor für Bilddateien
const originalImageSrc = Object.getOwnPropertyDescriptor(HTMLImageElement.prototype, 'src');

Object.defineProperty(HTMLImageElement.prototype, 'src', {
  set(url) {
    const img = this;
    
    if (typeof url === 'string' && url.startsWith('assets/')) {
      console.log('Intercepting image src assignment:', url);
      
      // Lade das Bild über IPC
      ipcRenderer.invoke('fetch-asset-binary', url).then(base64Data => {
        if (base64Data) {
          // Bestimme MIME-Typ basierend auf Dateiendung
          let mimeType = 'image/jpeg'; // Standard
          if (url.endsWith('.png')) mimeType = 'image/png';
          else if (url.endsWith('.gif')) mimeType = 'image/gif';
          else if (url.endsWith('.svg')) mimeType = 'image/svg+xml';
          
          // Erstelle data URL
          const dataUrl = `data:${mimeType};base64,${base64Data}`;
          originalImageSrc.set.call(img, dataUrl);
        } else {
          originalImageSrc.set.call(img, url);
        }
      }).catch(err => {
        console.error('Error loading image:', err);
        originalImageSrc.set.call(img, url);
      });
    } else {
      // Normales Verhalten für nicht-Asset-URLs
      originalImageSrc.set.call(this, url);
    }
  },
  get() {
    return originalImageSrc.get.call(this);
  }
});

// Video-Interceptor für Videodateien
const originalVideoSrc = Object.getOwnPropertyDescriptor(HTMLVideoElement.prototype, 'src');

Object.defineProperty(HTMLVideoElement.prototype, 'src', {
  set(url) {
    const video = this;
    
    if (typeof url === 'string' && url.startsWith('assets/')) {
      console.log('Intercepting video src assignment:', url);
      
      // Elektronpfad für Videos
      const electronPath = `file://${__dirname.replace(/\\/g, '/')}/web/assets/${url}`;
      console.log('Setting video src to:', electronPath);
      originalVideoSrc.set.call(video, electronPath);
    } else {
      // Normales Verhalten für nicht-Asset-URLs
      originalVideoSrc.set.call(this, url);
    }
  },
  get() {
    return originalVideoSrc.get.call(this);
  }
});

// Zusätzlich für <source>-Element innerhalb von <video>-Tags
const originalSourceSrc = Object.getOwnPropertyDescriptor(HTMLSourceElement.prototype, 'src');

Object.defineProperty(HTMLSourceElement.prototype, 'src', {
  set(url) {
    const source = this;
    
    if (typeof url === 'string' && url.startsWith('assets/')) {
      console.log('Intercepting video source src assignment:', url);
      
      // Elektronpfad für Video-Sources
      const electronPath = `file://${__dirname.replace(/\\/g, '/')}/web/assets/${url}`;
      console.log('Setting source src to:', electronPath);
      originalSourceSrc.set.call(source, electronPath);
    } else {
      // Normales Verhalten
      originalSourceSrc.set.call(this, url);
    }
  },
  get() {
    return originalSourceSrc.get.call(this);
  }
});

console.log('Preload script completed - all interceptors installed');