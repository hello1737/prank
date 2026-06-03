# ════════════════════════════════════════════════════════════
#   PRANK POPUP TIMER — Images & Vidéos à heures fixes
#   Fenêtre aléatoire sur l'écran, son au max, disparaît vite
# ════════════════════════════════════════════════════════════

# ── CONFIG — Modifie ici ────────────────────────────────────

$GitHubUser = "TON_USERNAME"   # ton pseudo GitHub
$GitHubRepo = "prank"          # nom de ton repo

# Fichiers dans ton repo GitHub (images + vidéos)
$MediaFiles = @(
    "meme1.jpg",
    "meme2.jpg",
    "meme3.jpg"
    # "video1.mp4"     # décommente quand tu ajoutes des vidéos
)

# Heures de déclenchement  H = heure, M = minutes
$Triggers = @(
    @{ H = 8;  M = 0  },   # 08h00
    @{ H = 8;  M = 55 },   # 08h55
    @{ H = 9;  M = 55 }    # 09h55
)

# Durée d'affichage des IMAGES (secondes) — vidéos = jouées en entier
$DisplaySec = 4

# Taille de la fenêtre popup
$WinW = 520
$WinH = 400

# ────────────────────────────────────────────────────────────

# Cache local dans %TEMP%
$Cache = "$env:TEMP\prank_popup"
New-Item -ItemType Directory -Force -Path $Cache | Out-Null

# ── Téléchargement des médias depuis GitHub ─────────────────
Write-Host ""
Write-Host "  Téléchargement des médias depuis GitHub..." -ForegroundColor Cyan

foreach ($f in $MediaFiles) {
    $dest = Join-Path $Cache $f
    if (-not (Test-Path $dest)) {
        $url = "https://raw.githubusercontent.com/$GitHubUser/$GitHubRepo/main/$f"
        try {
            Invoke-WebRequest -Uri $url -OutFile $dest -UseBasicParsing -ErrorAction Stop
            Write-Host "  ✓ $f" -ForegroundColor Green
        } catch {
            Write-Host "  ✗ Impossible de télécharger $f" -ForegroundColor Red
        }
    } else {
        Write-Host "  ✓ $f (cache)" -ForegroundColor DarkGreen
    }
}

# ── Fonction : mettre le volume au maximum ──────────────────
function Set-VolumeMax {
    $wsh = New-Object -ComObject WScript.Shell
    1..50 | ForEach-Object { $wsh.SendKeys([char]0xAF) }  # touche Volume+
}

# ── Fonction : afficher le popup ────────────────────────────
function Show-Prank {

    # Fichier aléatoire parmi ceux disponibles en cache
    $available = $MediaFiles | Where-Object { Test-Path (Join-Path $Cache $_) }
    if (-not $available) { Write-Host "  Aucun média disponible" -ForegroundColor Red; return }

    $chosen  = $available | Get-Random
    $path    = Join-Path $Cache $chosen
    $ext     = [System.IO.Path]::GetExtension($chosen).ToLower()
    $isVideo = $ext -in @('.mp4', '.webm', '.avi', '.mov', '.mkv')

    Write-Host "  🔥 POPUP → $chosen" -ForegroundColor Red

    # Volume max avant de lancer
    Set-VolumeMax

    # Runspace STA (obligatoire pour WPF)
    $rs = [System.Management.Automation.Runspaces.RunspaceFactory]::CreateRunspace()
    $rs.ApartmentState = "STA"
    $rs.Open()

    $ps = [PowerShell]::Create()
    $ps.Runspace = $rs

    [void]$ps.AddScript({
        param($path, $isVideo, $winW, $winH, $duration)

        Add-Type -AssemblyName PresentationCore, PresentationFramework, WindowsBase, System.Windows.Forms

        $screenW = [System.Windows.Forms.Screen]::PrimaryScreen.Bounds.Width
        $screenH = [System.Windows.Forms.Screen]::PrimaryScreen.Bounds.Height

        $win = New-Object System.Windows.Window
        $win.WindowStyle   = 'None'
        $win.Topmost       = $true
        $win.ShowInTaskbar = $false
        $win.Width         = $winW
        $win.Height        = $winH
        $win.Background    = [System.Windows.Media.Brushes]::Black
        $win.Left          = Get-Random -Min 10 -Max ([math]::Max(11, $screenW - $winW - 10))
        $win.Top           = Get-Random -Min 10 -Max ([math]::Max(11, $screenH - $winH - 10))

        if ($isVideo) {
            $m = New-Object System.Windows.Controls.MediaElement
            $m.Source         = [Uri]$path
            $m.Volume         = 1.0
            $m.LoadedBehavior = [System.Windows.Controls.MediaState]::Play
            $m.Stretch        = [System.Windows.Media.Stretch]::Uniform
            $m.Add_MediaEnded({ $win.Close() })
            $win.Content = $m
        } else {
            $img = New-Object System.Windows.Controls.Image
            $bmp = New-Object System.Windows.Media.Imaging.BitmapImage
            $bmp.BeginInit()
            $bmp.UriSource      = [Uri]$path
            $bmp.CacheOption    = [System.Windows.Media.Imaging.BitmapCacheOption]::OnLoad
            $bmp.EndInit()
            $bmp.Freeze()
            $img.Source  = $bmp
            $img.Stretch = [System.Windows.Media.Stretch]::Uniform
            $win.Content = $img

            $t = New-Object System.Windows.Threading.DispatcherTimer
            $t.Interval = [TimeSpan]::FromSeconds($duration)
            $t.Add_Tick({
                $win.Close()
                $t.Stop()
            })
            $t.Start()
        }

        [void]$win.ShowDialog()

    }).AddParameters(@{
        path     = $path
        isVideo  = $isVideo
        winW     = $WinW
        winH     = $WinH
        duration = $DisplaySec
    })

    # Lance en arrière-plan (non bloquant)
    [void]$ps.BeginInvoke()
}

# ── Masquer la fenêtre PowerShell ───────────────────────────
Add-Type -Name Win -Namespace API -MemberDefinition @"
    [DllImport("user32.dll")]
    public static extern bool ShowWindow(IntPtr hWnd, int nCmdShow);
    [DllImport("kernel32.dll")]
    public static extern IntPtr GetConsoleWindow();
"@
$consoleHwnd = [API.Win]::GetConsoleWindow()
[API.Win]::ShowWindow($consoleHwnd, 2) | Out-Null  # 2 = minimisé

# ── Boucle principale ────────────────────────────────────────
Write-Host ""
Write-Host "  ✅ PRANK TIMER actif — fenêtre minimisée" -ForegroundColor Green
Write-Host ""

$triggered = @{}

while ($true) {
    $now = Get-Date

    foreach ($t in $Triggers) {
        $key = "$($t.H):$($t.M)"
        if ($now.Hour -eq $t.H -and $now.Minute -eq $t.M -and -not $triggered[$key]) {
            $triggered[$key] = $true
            Show-Prank
        }
    }

    # Reset chaque jour à minuit
    if ($now.Hour -eq 0 -and $now.Minute -eq 0 -and $now.Second -lt 30) {
        $triggered = @{}
    }

    Start-Sleep -Seconds 20
}
