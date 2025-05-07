const { contextBridge, ipcRenderer } = require('electron');
const fs = require('fs');
const path = require('path');

// Expose protected methods that allow the renderer process to use
// Electron's IPC and filesystem functionality
contextBridge.exposeInMainWorld(
  'electron', {
    isElectron: true
  }
);

// Expose a function to save files (used by getDeepfakeStats)
contextBridge.exposeInMainWorld(
  'electronSaveFile', 
  (filename, content) => {
    // Use Electron's dialog to save file
    ipcRenderer.invoke('save-file', { filename, content });
  }
);

// Provide file system access for assets
contextBridge.exposeInMainWorld(
  'electronFileSystem', {
    readAssetFile: (filePath) => {
      // Convert web path to local filesystem path
      const localPath = path.join(__dirname, filePath);
      return fs.readFileSync(localPath, 'utf8');
    }
  }
);