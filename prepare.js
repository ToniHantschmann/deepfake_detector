const fs = require('fs');
const path = require('path');

// Erkennen, ob das Skript im electron-deepfake-detector Verzeichnis läuft
const currentDir = process.cwd();
const isInElectronDir = currentDir.endsWith('electron-deepfake-detector');

// Projektverzeichnis entsprechend festlegen
const projectRoot = isInElectronDir ? path.resolve(currentDir, '..') : currentDir;

// Korrekte Pfadkonfiguration basierend auf dem tatsächlichen Projektverzeichnis
const flutterBuildDir = path.join(projectRoot, 'build', 'web');
const electronWebDir = path.join(projectRoot, 'electron-deepfake-detector', 'web');

// Hilfsfunktion zum rekursiven Löschen eines Verzeichnisses
function deleteFolderRecursive(folderPath) {
  if (fs.existsSync(folderPath)) {
    fs.readdirSync(folderPath).forEach(file => {
      const curPath = path.join(folderPath, file);
      if (fs.lstatSync(curPath).isDirectory()) {
        deleteFolderRecursive(curPath);
      } else {
        fs.unlinkSync(curPath);
      }
    });
    fs.rmdirSync(folderPath);
  }
}

// Hilfsfunktion zum rekursiven Kopieren von Dateien
function copyRecursively(source, destination) {
  if (!fs.existsSync(destination)) {
    fs.mkdirSync(destination, { recursive: true });
  }

  const files = fs.readdirSync(source);

  for (const file of files) {
    const sourcePath = path.join(source, file);
    const destPath = path.join(destination, file);

    const stats = fs.statSync(sourcePath);

    if (stats.isDirectory()) {
      copyRecursively(sourcePath, destPath);
    } else {
      fs.copyFileSync(sourcePath, destPath);
    }
  }
}

// Funktion zum Kopieren der Flutter-Build-Dateien
function copyFlutterBuildFiles() {
  console.log(`Kopiere Flutter-Build-Dateien von ${flutterBuildDir} nach ${electronWebDir}...`);
  
  try {
    // Prüfe, ob das Quellverzeichnis existiert
    if (!fs.existsSync(flutterBuildDir)) {
      console.error(`Das Flutter build/web Verzeichnis existiert nicht: ${flutterBuildDir}`);
      console.error('Bitte führe zuerst "flutter build web" aus.');
      process.exit(1);
    }
    
    // Prüfe, ob das Electron-App-Verzeichnis existiert
    const electronAppDir = path.join(projectRoot, 'electron-deepfake-detector');
    if (!fs.existsSync(electronAppDir)) {
      console.error(`Das Electron-App-Verzeichnis existiert nicht: ${electronAppDir}`);
      console.error('Bitte erstelle zuerst das Electron-App-Verzeichnis.');
      process.exit(1);
    }
    
    // Lösche das Zielverzeichnis, falls es existiert
    if (fs.existsSync(electronWebDir)) {
      console.log(`Lösche bestehendes Verzeichnis ${electronWebDir}...`);
      deleteFolderRecursive(electronWebDir);
    }
    
    // Kopiere alle Dateien
    copyRecursively(flutterBuildDir, electronWebDir);
    
    console.log('Flutter-Build-Dateien erfolgreich kopiert.');
  } catch (err) {
    console.error('Fehler beim Kopieren der Flutter-Build-Dateien:', err);
    process.exit(1);
  }
}

// Funktion zum Anpassen der index.html
function modifyIndexHtml() {
  console.log('Passe index.html für Electron an...');
  
  const indexHtmlPath = path.join(electronWebDir, 'index.html');
  
  try {
    if (!fs.existsSync(indexHtmlPath)) {
      console.error(`index.html wurde nicht gefunden in ${indexHtmlPath}`);
      process.exit(1);
    }
    
    // Datei lesen
    let htmlContent = fs.readFileSync(indexHtmlPath, 'utf8');
    
    // 1. Ersetze den base href Tag mit dem dynamischen Script
    const baseHrefRegex = /<base href="[^"]*">/;
    const dynamicBaseScript = `<script>
    // Base-URL für Electron dynamisch anpassen
    (function() {
      const isElectron = window.navigator.userAgent.toLowerCase().indexOf('electron') > -1;
      if (isElectron) {
        document.write(\`<base href="file://\${window.location.pathname.substring(0, window.location.pathname.lastIndexOf('/') + 1)}">\`);
        console.log("Base-URL für Electron angepasst:", \`file://\${window.location.pathname.substring(0, window.location.pathname.lastIndexOf('/') + 1)}\`);
      } else {
        document.write('<base href="/">');
      }
    })();
  </script>`;
    
    if (baseHrefRegex.test(htmlContent)) {
      htmlContent = htmlContent.replace(baseHrefRegex, dynamicBaseScript);
      console.log('Base href mit dynamischem Script ersetzt.');
    } else {
      console.log('Warnung: Konnte base href Tag nicht finden. Manuelles Eingreifen erforderlich.');
    }

    // 2. Ersetze oder füge das flutter.js Script-Tag hinzu
    const flutterScriptRegex = /<script\s+src=['"]flutter\.js['"][^>]*><\/script>/i;
    const flutterScriptTag = `<!-- This script adds the flutter initialization JS code -->
  <script src="flutter.js" defer></script>`;
    
    if (flutterScriptRegex.test(htmlContent)) {
      // Ersetze das vorhandene flutter.js Script-Tag
      htmlContent = htmlContent.replace(flutterScriptRegex, flutterScriptTag);
      console.log('flutter.js Script-Tag ersetzt.');
    } else {
      // Füge das flutter.js Script-Tag vor dem schließenden head-Tag ein
      const headCloseTag = '</head>';
      if (htmlContent.includes(headCloseTag)) {
        htmlContent = htmlContent.replace(headCloseTag, `${flutterScriptTag}\n</head>`);
        console.log('flutter.js Script-Tag zum head-Bereich hinzugefügt.');
      } else {
        console.log('Warnung: Konnte schließenden head-Tag nicht finden. Manuelles Eingreifen erforderlich.');
      }
    }
    
    // 3. Ersetze den kompletten addEventListener-Block im Body
    const eventListenerRegex = /<script>\s*window\.addEventListener\('load',[\s\S]*?<\/script>/;
    const newEventListenerScript = `<script>
  window.addEventListener('load', function(ev) {
    // Initialisiere Asset Manager für Electron
    if (window.assetManager) {
      window.assetManager.init();
    }
    
    // Download main.dart.js
    _flutter.loader.loadEntrypoint({
      // Für Electron KEIN Service Worker verwenden
      serviceWorker: null,
      onEntrypointLoaded: function(engineInitializer) {
        engineInitializer.initializeEngine().then(function(appRunner) {
          appRunner.runApp();
        });
      }
    });
  });
</script>`;
    
    if (eventListenerRegex.test(htmlContent)) {
      htmlContent = htmlContent.replace(eventListenerRegex, newEventListenerScript);
      console.log('Event-Listener-Script erfolgreich ersetzt.');
    } else {
      console.log('Warnung: Konnte Event-Listener-Script nicht finden. Manuelles Eingreifen erforderlich.');
    }
    
    // Datei schreiben
    fs.writeFileSync(indexHtmlPath, htmlContent, 'utf8');
    
    console.log('index.html erfolgreich angepasst.');
  } catch (err) {
    console.error('Fehler beim Anpassen der index.html:', err);
    process.exit(1);
  }
}

// Hauptfunktion
function prepare() {
  console.log('Bereite Flutter-App für Electron vor...');
  console.log(`Aktuelles Arbeitsverzeichnis: ${currentDir}`);
  console.log(`Erkannt als ${isInElectronDir ? 'innerhalb' : 'außerhalb'} des electron-deepfake-detector Verzeichnisses`);
  console.log(`Projektverzeichnis: ${projectRoot}`);
  console.log(`Flutter Web-Build: ${flutterBuildDir}`);
  console.log(`Electron Web-Ziel: ${electronWebDir}`);
  
  copyFlutterBuildFiles();
  modifyIndexHtml();
  
  console.log('Vorbereitung abgeschlossen! Die Flutter-App ist bereit für Electron.');
}

// Skript ausführen
prepare();