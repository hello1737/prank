# ════════════════════════════════════════════════════════════
#   PRANK TIMER — Lance une page web en plein écran à l'heure
#   Inoffensif — ouvre juste le navigateur  |  by taco_tunisia
# ════════════════════════════════════════════════════════════

# ── CONFIG ── Modifie ces valeurs ───────────────────────────

# Heure de déclenchement (format 24h)
$HeureH  = 10   # heure
$HeureM  = 30   # minutes
$HeureS  = 0    # secondes (laisse 0)

# URL de ta page GitHub Pages (remplace par la tienne)
$URL = "https://TON_USERNAME.github.io/TON_REPO/"

# Navigateur : "msedge" (Edge), "chrome", "firefox"
$Browser = "msedge"

# ─────────────────────────────────────────────────────────────

Write-Host ""
Write-Host "  ██████╗ ██████╗  █████╗ ███╗   ██╗██╗  ██╗" -ForegroundColor Red
Write-Host "  ██╔══██╗██╔══██╗██╔══██╗████╗  ██║██║ ██╔╝" -ForegroundColor Yellow
Write-Host "  ██████╔╝██████╔╝███████║██╔██╗ ██║█████╔╝ " -ForegroundColor Green
Write-Host "  ██╔═══╝ ██╔══██╗██╔══██║██║╚██╗██║██╔═██╗ " -ForegroundColor Cyan
Write-Host "  ██║     ██║  ██║██║  ██║██║ ╚████║██║  ██╗" -ForegroundColor Blue
Write-Host "  ╚═╝     ╚═╝  ╚═╝╚═╝  ╚═╝╚═╝  ╚═══╝╚═╝  ╚═╝" -ForegroundColor Magenta
Write-Host ""
Write-Host "  PRANK TIMER — Prêt." -ForegroundColor White
Write-Host ""

$cible = [DateTime]::Today.AddHours($HeureH).AddMinutes($HeureM).AddSeconds($HeureS)

# Si l'heure est déjà passée aujourd'hui → demain
if ((Get-Date) -gt $cible) {
    $cible = $cible.AddDays(1)
    Write-Host "  L'heure est déjà passée → déclenchement DEMAIN à $($cible.ToString('HH:mm:ss'))" -ForegroundColor Yellow
} else {
    Write-Host "  Déclenchement prévu à : $($cible.ToString('HH:mm:ss'))" -ForegroundColor Cyan
}

Write-Host "  Heure actuelle       : $(Get-Date -Format 'HH:mm:ss')" -ForegroundColor Gray
Write-Host ""

# Compte à rebours
while ((Get-Date) -lt $cible) {
    $reste = $cible - (Get-Date)
    $msg = "  ⏳ Temps restant : {0:D2}h {1:D2}m {2:D2}s" -f $reste.Hours, $reste.Minutes, $reste.Seconds
    Write-Host "`r$msg" -NoNewline -ForegroundColor DarkYellow
    Start-Sleep -Seconds 1
}

Write-Host ""
Write-Host ""
Write-Host "  🔥 DÉCLENCHEMENT ! 🔥" -ForegroundColor Red
Write-Host ""

# Lance le navigateur en plein écran sur l'URL
try {
    switch ($Browser) {
        "msedge"  { Start-Process "msedge"   "--start-fullscreen `"$URL`"" }
        "chrome"  { Start-Process "chrome"   "--start-fullscreen `"$URL`"" }
        "firefox" { Start-Process "firefox"  "-kiosk `"$URL`"" }
        default   { Start-Process $Browser   "--start-fullscreen `"$URL`"" }
    }
    Write-Host "  Navigateur lancé : $Browser" -ForegroundColor Green
} catch {
    # Fallback : ouvre avec le navigateur par défaut
    Start-Process $URL
    Write-Host "  Fallback : navigateur par défaut" -ForegroundColor Yellow
}

Write-Host "  ✅ Prank déclenché. Tu peux fermer cette fenêtre." -ForegroundColor Green
Start-Sleep -Seconds 5
