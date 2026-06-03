# ════════════════════════════════════════════════════════════
#   PRANK POPUP TIMER v3 — Planning fixe
#   hello1737/prank
# ════════════════════════════════════════════════════════════

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

# ── Planning fixe ────────────────────────────────────────────
# Type    : "image" ou "video"
# Mode    : "fullscreen" ou "coin"
# File    : nom exact OU "random_image" / "random_video"
# Dur     : durée en secondes (pour fullscreen seulement)

$Schedule = @(

    # ── COURS 1 (8h50 → 9h20) ───────────────────────────────
    @{ H=8;  M=50; S=0;  Type="video"; Mode="fullscreen"; File="Huh.mp4";       Dur=0.1 },
    @{ H=9;  M=0;  S=0;  Type="image"; Mode="coin";       File="random_image";  Dur=0   },
    @{ H=9;  M=5;  S=0;  Type="image"; Mode="coin";       File="random_image";  Dur=0   },
    @{ H=9;  M=6;  S=0;  Type="image"; Mode="coin";       File="random_image";  Dur=0   },
    @{ H=9;  M=7;  S=0;  Type="image"; Mode="coin";       File="random_image";  Dur=0   },
    @{ H=9;  M=17; S=0;  Type="image"; Mode="coin";       File="random_image";  Dur=0   },
    @{ H=9;  M=19; S=0;  Type="video"; Mode="fullscreen"; File="random_video";  Dur=0.1 },
    @{ H=9;  M=20; S=0;  Type="image"; Mode="coin";       File="random_image";  Dur=0   },
    @{ H=9;  M=25; S=0;  Type="image"; Mode="coin";       File="random_image";  Dur=0   },
    @{ H=9;  M=30; S=0;  Type="image"; Mode="coin";       File="random_image";  Dur=0   },

    # ── COURS 2 — Anglais (8h55 → 9h55) ─────────────────────
    @{ H=9;  M=28; S=0;  Type="image"; Mode="fullscreen"; File="random_image";  Dur=0.1 },

    # ── COURS 3 (10h00 → 11h00) ─────────────────────────────
    @{ H=10; M=2;  S=0;  Type="image"; Mode="coin";       File="random_image";  Dur=0   },
    @{ H=10; M=5;  S=0;  Type="image"; Mode="coin";       File="random_image";  Dur=0   },
    @{ H=10; M=8;  S=0;  Type="image"; Mode="coin";       File="random_image";  Dur=0   },
    @{ H=10; M=31; S=0;  Type="video"; Mode="fullscreen"; File="random_video";  Dur=3   },
    @{ H=10; M=52; S=0;  Type="image"; Mode="coin";       File="random_image";  Dur=0   },
    @{ H=10; M=55; S=0;  Type="image"; Mode="coin";       File="random_image";  Dur=0   },
    @{ H=10; M=58; S=0;  Type="image"; Mode="coin";       File="random_image";  Dur=0   }
)

# ────────────────────────────────────────────────────────────

$Cache = "$env:TEMP\prank_popup"
New-Item -ItemType Directory -Force -Path $Cache | Out-Null

Write-Host ""
Write-Host "  Téléchargement médias..." -ForegroundColor Cyan

foreach ($f in $MediaFiles) {
    $filename = Split-Path $f -Leaf
    $dest = Join-Path $Cache $filename
    if (-not (Test-Path $dest)) {
        $url = "https://raw.githubusercontent.com/$GitHubUser/$GitHubRepo/main/$f"
        try {
            Invoke-WebRequest -Uri $url -OutFile $dest -UseBasicParsing -ErrorAction Stop
            Write-Host "  ✓ $filename" -ForegroundColor Green
        } catch {
            Write-Host "  ✗ Echec : $filename" -ForegroundColor Red
        }
    } else {
        Write-Host "  ✓ $filename (cache)" -ForegroundColor DarkGreen
    }
}

# Listes image / video
$imageFiles = $MediaFiles | Where-Object { $_ -match '\.(jpg|jpeg|png|gif)$' } |
    ForEach-Object { Join-Path $Cache (Split-Path $_ -Leaf) } |
    Where-Object { Test-Path $_ }

$videoFiles = $MediaFiles | Where-Object { $_ -match '\.(mp4|webm|mov|avi)$' } |
    ForEach-Object { Join-Path $Cache (Split-Path $_ -Leaf) } |
    Where-Object { Test-Path $_ }

function Resolve-File($name) {
    if ($name -eq "random_image") { return ($imageFiles | Get-Random) }
    if ($name -eq "random_video") { return ($videoFiles | Get-Random) }
    return Join-Path $Cache $name
}

function Set-VolumeMax {
    $wsh = New-Object -ComObject WScript.Shell
    1..50 | ForEach-Object { $wsh.SendKeys([char]0xAF) }
}

function Show-Popup($path, $isVideo, $mode, $dur) {

    Set-VolumeMax

    $rs = [System.Management.Automation.Runspaces.RunspaceFactory]::CreateRunspace()
    $rs.ApartmentState = "STA"
    $rs.Open()
    $ps = [PowerShell]::Create()
    $ps.Runspace = $rs

    [void]$ps.AddScript({
        param($path, $isVideo, $mode, $dur)

        Add-Type -AssemblyName PresentationCore,PresentationFramework,WindowsBase,System.Windows.Forms

        $SW = [System.Windows.Forms.Screen]::PrimaryScreen.Bounds.Width
        $SH = [System.Windows.Forms.Screen]::PrimaryScreen.Bounds.Height

        $win = New-Object System.Windows.Window
        $win.WindowStyle   = 'None'
        $win.Topmost       = $true
        $win.ShowInTaskbar = $false
        $win.Background    = [System.Windows.Media.Brushes]::Black

        if ($mode -eq "fullscreen") {
            $win.Left        = 0
            $win.Top         = 0
            $win.Width       = $SW
            $win.Height      = $SH
            $win.WindowState = 'Maximized'
        } else {
            # Tout petit, dans l'un des 4 coins
            $winW = Get-Random -Min 120 -Max 220
            $winH = Get-Random -Min 90  -Max 170
            $win.Width  = $winW
            $win.Height = $winH
            $corner = Get-Random -Min 0 -Max 4
            switch ($corner) {
                0 { $win.Left = 4;              $win.Top = 4              }  # haut-gauche
                1 { $win.Left = $SW-$winW-4;    $win.Top = 4              }  # haut-droite
                2 { $win.Left = 4;              $win.Top = $SH-$winH-50   }  # bas-gauche
                3 { $win.Left = $SW-$winW-4;    $win.Top = $SH-$winH-50   }  # bas-droite
            }
        }

        if ($isVideo) {
            $m = New-Object System.Windows.Controls.MediaElement
            $m.Source         = [Uri]$path
            $m.Volume         = 1.0
            $m.LoadedBehavior = [System.Windows.Controls.MediaState]::Play
            $m.Stretch        = [System.Windows.Media.Stretch]::Uniform
            $win.Content      = $m

            if ($dur -gt 0) {
                $t = New-Object System.Windows.Threading.DispatcherTimer
                $t.Interval = [TimeSpan]::FromSeconds($dur)
                $t.Add_Tick({ $win.Close(); $t.Stop() })
                $t.Start()
            } else {
                $m.Add_MediaEnded({ $win.Close() })
            }
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

            $closeSec = if ($mode -eq "fullscreen") { 0.1 } else { Get-Random -Min 1 -Max 3 }
            $t = New-Object System.Windows.Threading.DispatcherTimer
            $t.Interval = [TimeSpan]::FromSeconds($closeSec)
            $t.Add_Tick({ $win.Close(); $t.Stop() })
            $t.Start()
        }

        [void]$win.ShowDialog()

    }).AddParameters(@{ path=$path; isVideo=$isVideo; mode=$mode; dur=$dur })

    [void]$ps.BeginInvoke()
}

# ── Masquer PowerShell ───────────────────────────────────────
Add-Type -Name Win -Namespace API -MemberDefinition @"
    [DllImport("user32.dll")]
    public static extern bool ShowWindow(IntPtr hWnd, int nCmdShow);
    [DllImport("kernel32.dll")]
    public static extern IntPtr GetConsoleWindow();
"@
[API.Win]::ShowWindow([API.Win]::GetConsoleWindow(), 2) | Out-Null

# ── Afficher le planning ─────────────────────────────────────
Write-Host ""
Write-Host "  ══════ PLANNING ══════" -ForegroundColor Magenta
foreach ($e in $Schedule) {
    $icon = if ($e.Type -eq "video") { "🎬" } else { "🖼 " }
    $time = "{0:D2}h{1:D2}" -f $e.H, $e.M
    Write-Host ("  $icon  $time  [$($e.Mode.PadRight(10))]  $($e.File)") -ForegroundColor Yellow
}
Write-Host ""
Write-Host "  ✅ Timer actif — fenêtre minimisée" -ForegroundColor Green

# ── Boucle principale ────────────────────────────────────────
$fired = [System.Collections.Generic.HashSet[int]]@()

while ($true) {
    $now = Get-Date

    for ($i = 0; $i -lt $Schedule.Count; $i++) {
        if ($fired.Contains($i)) { continue }
        $e = $Schedule[$i]
        if ($now.Hour -eq $e.H -and $now.Minute -eq $e.M) {
            $fired.Add($i) | Out-Null
            $path    = Resolve-File $e.File
            $isVideo = $e.Type -eq "video"
            if ($path) {
                Write-Host ("  🔥 FIRE {0:D2}h{1:D2} — {2}" -f $e.H, $e.M, (Split-Path $path -Leaf)) -ForegroundColor Red
                Show-Popup $path $isVideo $e.Mode $e.Dur
            }
        }
    }

    # Reset chaque nuit à minuit
    if ($now.Hour -eq 0 -and $now.Minute -eq 0) { $fired.Clear() }

    Start-Sleep -Seconds 8
}
