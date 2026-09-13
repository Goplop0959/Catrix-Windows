# Catrix installer for Windows - the supported install method:
#   irm https://raw.githubusercontent.com/Goplop0959/Catrix-Windows/refs/heads/master/Install.ps1 | iex
#
# Installs Catrix.ps1 to %LOCALAPPDATA%\Catrix and adds a `catrix` shim
# directory to the current user's PATH. No admin needed.
$ErrorActionPreference = 'Stop'
$Repo = 'Goplop0959/Catrix-Windows'
$Branch = 'master'
$Base = "https://raw.githubusercontent.com/$Repo/refs/heads/$Branch"

$dir = Join-Path $env:LOCALAPPDATA 'Catrix'
New-Item -ItemType Directory -Force -Path $dir | Out-Null
Write-Host 'catrix: downloading...'
Invoke-WebRequest -Uri "$Base/Catrix.ps1" -OutFile (Join-Path $dir 'Catrix.ps1')

$shim = "@echo off`r`npwsh -NoProfile -ExecutionPolicy Bypass -File `"%LOCALAPPDATA%\Catrix\Catrix.ps1`" %*`r`n"
[IO.File]::WriteAllText((Join-Path $dir 'catrix.cmd'), $shim)

$userPath = [Environment]::GetEnvironmentVariable('Path', 'User')
if ($userPath -notlike "*$dir*") {
  [Environment]::SetEnvironmentVariable('Path', "$userPath;$dir", 'User')
  Write-Host 'catrix: added to user PATH (restart your terminal).'
}
Write-Host 'catrix: done. Run: catrix'
Write-Host 'catrix: needs PowerShell 7+ for the cat faces (winget install Microsoft.PowerShell).'
