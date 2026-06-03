# 🔥 PRANK TIMER — Guide complet

## Structure du repo GitHub

```
prank/
├── index.html        ← page affichée (GitHub Pages)
├── prank.ps1         ← timer PowerShell
├── manifest.json     ← liste de tes médias + intervalle
└── media/
    ├── meme1.jpg     ← tes images ici
    ├── meme2.jpg
    ├── meme3.jpg
    └── video1.mp4    ← tes vidéos ici
```

---

## 1. Ajouter tes images / vidéos

### Sur GitHub.com (sans logiciel) :
1. Va dans ton repo → clique **Add file → Upload files**
2. Crée un dossier `media/` en nommant le fichier `media/meme1.jpg`
3. Dépose tes fichiers

### Taille max : 25 MB par fichier (limite GitHub)
- Images : JPG, PNG, GIF, WEBP → OK
- Vidéos  : MP4, WEBM → OK (garde-les < 20 MB)

---

## 2. Modifier manifest.json

```json
{
  "interval_minutes": 2,
  "files": [
    { "type": "image", "src": "media/meme1.jpg" },
    { "type": "image", "src": "media/meme2.jpg" },
    { "type": "video", "src": "media/video1.mp4" },
    { "type": "image", "src": "media/meme3.jpg", "caption": "😂 BOOZLE FR FR 💀" }
  ]
}
```

- `interval_minutes` : combien de minutes avant de changer (mets 1, 2, 0.5...)
- `type` : `"image"` ou `"video"`
- `src` : chemin dans le repo
- `caption` : (optionnel) texte affiché en bas — sinon c'est aléatoire

---

## 3. Activer GitHub Pages

Settings → Pages → Source : **Deploy from branch** → `main` / `/ (root)`

Ton URL : `https://TON_USERNAME.github.io/prank/`

---

## 4. Lancer sur le PC de la classe

**Dans prank.ps1, configure :**
```powershell
$HeureH  = 10          # 10h
$HeureM  = 30          # 30min
$URL     = "https://TON_USERNAME.github.io/prank/"
$Browser = "msedge"    # msedge / chrome / firefox
```

**Commande PowerShell à taper sur le PC :**
```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass; iex (irm 'https://raw.githubusercontent.com/TON_USERNAME/prank/main/prank.ps1')
```

> Win+R → `powershell` → colle la commande → Entrée → minimise la fenêtre

