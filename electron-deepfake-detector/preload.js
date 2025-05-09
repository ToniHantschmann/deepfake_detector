const { contextBridge, ipcRenderer } = require('electron');

// Debugging
console.log('Preload script started');

// Expose protected methods that allow the renderer process to use
// the IPC mechanism without direct Node.js access
contextBridge.exposeInMainWorld('electron', {
  isElectron: true,
  
  // Methode zum Speichern von Dateien
  saveFile: (filename, content) => {
    console.log('Renderer requesting to save file:', filename);
    return ipcRenderer.invoke('save-file', { filename, content });
  },
  
  // Methode zum Lesen von Dateien
  readAssetFile: (filePath) => {
    console.log('Renderer requesting to read file:', filePath);
    return ipcRenderer.invoke('read-asset-file', filePath);
  }
});

// JavaScript-Funktion als globales Fenster-Objekt bereitstellen (für Flutter)
contextBridge.exposeInMainWorld('electronFileSystem', {
  readAssetFile: (filePath) => {
    console.log('electronFileSystem.readAssetFile called for:', filePath);
    return ipcRenderer.invoke('read-asset-file', filePath);
  }
});

console.log('Preload script completed successfully');