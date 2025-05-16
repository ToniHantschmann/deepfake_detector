const { app, BrowserWindow, protocol, ipcMain, dialog } = require('electron');
const path = require('path');
const fs = require('fs');
const url = require('url');

let mainWindow;

function createWindow() {
  // Create the browser window
  mainWindow = new BrowserWindow({
    width: 1280,
    height: 800,
    webPreferences: {
      preload: path.join(__dirname, 'preload.js'),
      contextIsolation: true,
      nodeIntegration: false
      // Sandbox ist standardmäßig aktiviert, daher keine explizite Angabe
    },
    title: "Deepfake Detector",
    icon: path.join(__dirname, 'resources/icon.ico')
  });

  // Debugging aktivieren - später entfernen für Produktion
  mainWindow.webContents.openDevTools();

  // Log app path für Debugging
  console.log('App path:', __dirname);
  console.log('Preload path:', path.join(__dirname, 'preload.js'));

  // Load the Flutter web app
  const startUrl = url.format({
    pathname: path.join(__dirname, 'web/index.html'),
    protocol: 'file:',
    slashes: true
  });
  console.log('Loading URL:', startUrl);
  
  mainWindow.loadURL(startUrl);

  mainWindow.on('closed', () => {
    mainWindow = null;
  });
  mainWindow.webContents.on('did-fail-load', (event, errorCode, errorDescription) => {
    console.error('Seite konnte nicht geladen werden:', errorDescription);
  });
  
  // Protokolliere die URL, die wir laden
  console.log('Lade URL:', startUrl);
}

// Register file: protocol handler for Flutter web assets
app.whenReady().then(() => {
  // Verbesserte Protokollverarbeitung für file://
  protocol.registerFileProtocol('file', (request, callback) => {
    const filePath = request.url.replace('file://', '');
    const decodedPath = decodeURI(filePath);
    
    // Debug-Ausgabe für wichtige Dateien
    if (decodedPath.includes('flutter.js') || decodedPath.includes('main.dart.js')) {
      console.log(`Kritische Datei angefordert: ${decodedPath}`);
    }
    
    try {
      return callback(decodedPath);
    } catch (error) {
      console.error(`Protokollfehler für ${decodedPath}:`, error);
      return callback(404);
    }
  });
  
  createWindow();
  
  // Überprüfe das Web-Verzeichnis und flutter.js
  const webDir = path.join(__dirname, 'web');
  if (fs.existsSync(webDir)) {
    console.log('Web-Verzeichnisinhalt:', fs.readdirSync(webDir));
    
    // Prüfe explizit auf flutter.js
    const flutterJsPath = path.join(webDir, 'flutter.js');
    if (fs.existsSync(flutterJsPath)) {
      console.log('flutter.js existiert');
    } else {
      console.error('flutter.js fehlt!');
    }
  } else {
    console.error('Web-Verzeichnis existiert nicht!');
  }
});

// Handler für Text-Assets (JSON, etc.)
ipcMain.handle('fetch-asset', async (event, assetPath) => {
  console.log('Asset request received:', assetPath);
  
  // Direkter Pfad zum Asset
  const assetFullPath = path.join(__dirname, 'web', 'assets', assetPath);
  console.log('Loading asset from:', assetFullPath);
  
  try {
    if (fs.existsSync(assetFullPath)) {
      console.log('Asset found, loading content');
      return fs.readFileSync(assetFullPath, 'utf8');
    } else {
      console.error('Asset not found:', assetFullPath);
      return null;
    }
  } catch (error) {
    console.error('Error reading asset file:', error);
    return null;
  }
});

// Handler für Binärdaten (Bilder, Videos)
ipcMain.handle('fetch-asset-binary', async (event, assetPath) => {
  console.log('Binary asset request received:', assetPath);
  
  // Direkter Pfad zum Asset
  const assetFullPath = path.join(__dirname, 'web', 'assets', assetPath);
  console.log('Loading binary from:', assetFullPath);
  
  try {
    if (fs.existsSync(assetFullPath)) {
      console.log('Binary asset found');
      const buffer = fs.readFileSync(assetFullPath);
      return buffer.toString('base64');
    } else {
      console.error('Binary asset not found:', assetFullPath);
      return null;
    }
  } catch (error) {
    console.error('Error reading binary asset:', error);
    return null;
  }
});

// IPC Handler für Datei speichern
ipcMain.handle('save-file', async (event, args) => {
  console.log('Saving file:', args.filename);
  const { filename, content } = args;
  
  const { filePath } = await dialog.showSaveDialog({
    title: 'Save Statistics',
    defaultPath: filename,
    filters: [
      { name: 'JSON Files', extensions: ['json'] },
      { name: 'All Files', extensions: ['*'] }
    ]
  });
  
  if (filePath) {
    fs.writeFileSync(filePath, content);
    console.log('File saved successfully:', filePath);
    return { success: true, filePath };
  }
  
  console.log('File save cancelled');
  return { success: false };
});

app.on('window-all-closed', () => {
  if (process.platform !== 'darwin') {
    app.quit();
  }
});

app.on('activate', () => {
  if (BrowserWindow.getAllWindows().length === 0) {
    createWindow();
  }
});