# ════════════════════════════════════════════════════════════
#   PRANK POPUP TIMER — Images & Vidéos à heures fixes
#   Fenêtre aléatoire sur l'écran, son au max, disparaît vite
# ════════════════════════════════════════════════════════════

# ── CONFIG ──────────────────────────────────────────────────

$GitHubUser = "hello1737"
$GitHubRepo = "prank"

$MediaFiles = @(
    "media/meme1.jpg",
    "media/meme2.jpg",
    "media/meme3.jpg",
    "media/Huh.mp4",
    "media/Non.mp4",
    "media/chipichapa.mp4"
)

$Triggers = @(
    @{ H = 8;  M = 0  },
    @{ H = 8;  M = 55 },
    @{ H = 9;  M = 55 }
)

$DisplaySec = 3
$WinW = 520
$WinH = 400

# ────────────────────────────────────────────────────────────

$Cache = "$env:TEMP\prank_popup"
New-Item -ItemType Directory -Force -Path $Cache | Out-Null

Write-Host ""
Write-Host "  Téléchargement des médias depuis GitHub..." -ForegroundColor Cyan

foreach ($f in $MediaFiles) {
    $filename = Split-Path $f -Leaf
    $dest = Join-Path $Cache $filename
    if (-not (Test-Path $dest)) {
        $url = "https://raw.githubusercontent.com/$GitHubUser/$GitHubRepo/main/$f"
        try {
            Invoke-WebRequest -Uri $url -OutFile $dest -UseBasicParsing -ErrorAction Stop
            Write-Host "  ✓ $filename" -ForegroundColor Green
        } catch {
            Write-Host "  ✗ Impossible de télécharger $filename" -ForegroundColor Red
        }
    } else {
        Write-Host "  ✓ $filename (cache)" -ForegroundColor DarkGreen
    }
}

function Set-VolumeMax {
    $wsh = New-Object -ComObject WScript.Shell
    1..50 | ForEach-Object { $wsh.SendKeys([char]0xAF) }
}

function Show-Prank {
    $filenames = $MediaFiles | ForEach-Object { Split-Path $_ -Leaf }
    $available = $filenames | Where-Object { Test-Path (Join-Path $Cache $_) }
    if (-not $available) { Write-Host "  Aucun média dispo" -ForegroundColor Red; return }

    $chosen  = $available | Get-Random
    $path    = Join-Path $Cache $chosen
    $ext     = [System.IO.Path]::GetExtension($chosen).ToLower()
    $isVideo = $ext -in @('.mp4', '.webm', '.avi', '.mov', '.mkv')

    Write-Host "  🔥 POPUP → $chosen" -ForegroundColor Red

    Set-VolumeMax

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
            $bmp.UriSource   = [Uri]$path
            $bmp.CacheOption = [System.Windows.Media.Imaging.BitmapCacheOption]::OnLoad
            $bmp.EndInit()
            $bmp.Freeze()
            $img.Source  = $bmp
            $img.Stretch = [System.Windows.Media.Stretch]::Uniform
            $win.Content = $img

            $t = New-Object System.Windows.Threading.DispatcherTimer
            $t.Interval = [TimeSpan]::FromSeconds($duration)
            $t.Add_Tick({ $win.Close(); $t.Stop() })
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

    [void]$ps.BeginInvoke()
}

Add-Type -Name Win -Namespace API -MemberDefinition @"
    [DllImport("user32.dll")]
    public static extern bool ShowWindow(IntPtr hWnd, int nCmdShow);
    [DllImport("kernel32.dll")]
    public static extern IntPtr GetConsoleWindow();
"@
$consoleHwnd = [API.Win]::GetConsoleWindow()
[API.Win]::ShowWindow($consoleHwnd, 2) | Out-Null

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

    if ($now.Hour -eq 0 -and $now.Minute -eq 0 -and $now.Second -lt 30) {
        $triggered = @{}
    }

    Start-Sleep -Seconds 20
}
