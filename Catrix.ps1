<#
.SYNOPSIS
  Catrix for Windows - Matrix-style falling cat faces. Like cmatrix, but cats.
.DESCRIPTION
  Random cat faces rain down the console in columns, default color green.
  Keys: q quit | space pause | +/- speed | c color | b bold
  Requires PowerShell 7+ (for UTF-8 faces).
.EXAMPLE
  .\Catrix.ps1
  .\Catrix.ps1 -Color magenta -Delay 50
  Catrix -Update
#>
[CmdletBinding()]
param(
  [string]$Color = 'green',
  [switch]$NoBold,
  [int]$Delay = 21,
  [int]$Density = 70,
  [int]$Seconds = 0,
  [switch]$Update
)

$Version = '1.0.0'
$InstallUrl = 'https://raw.githubusercontent.com/Goplop0959/Catrix-Windows/refs/heads/master/Install.ps1'

$Faces = @(
  '(≽^•˕•^≼)',
  'ᨐᵐᵉᵒʷ',
  '≽^•⩊•^≼',
  'ฅ^>⩊<^ ฅ',
  '(＾• ω •＾)',
  '₍^. .^₎Ⳋ',
  '₍^ >⩊< ^₎Ⳋ',
  'ᓚ₍つ^. .^₎っ♡',
  '(=ↀωↀ=)▄︻┻┳═一',
  '(=^･^=)',
  '(=^･ω･^=)',
  '(=①ω①=)',
  '(^･o･^)ﾉ”',
  '(ΦωΦ)',
  'd(=^･ω･^=)b',
  'ฅ•ω•ฅ',
  'ฅ(´・ω・｀)ฅ',
  '(^._.^)ﾉ',
  'ヾ(*ΦωΦ)ﾉ',
  'ミ๏ｖ๏彡',
  '(=ↀωↀ=)',
  '⊱ฅ•ω•ฅ⊰',
  '❤(´ω｀*)',
  'V(=^･ω･^=)v',
  '(=^ ◡ ^=)',
  'ฅ(´-ω-`)ฅ',
  '(●ↀωↀ●)',
  '(^・ω・^ )'
)

$Codes = @{
  green = 32; red = 31; blue = 34; white = 37
  yellow = 33; magenta = 35; cyan = 36
}
$Order = @('green', 'red', 'blue', 'white', 'yellow', 'magenta', 'cyan')

if ($Update) {
  Write-Host 'catrix: updating...'
  $tmp = Join-Path $env:TEMP 'Catrix-Install.ps1'
  Invoke-WebRequest -Uri $InstallUrl -OutFile $tmp
  & $tmp
  return
}

if (-not $Codes.ContainsKey($Color)) { Write-Error "unknown color '$Color'"; return }
if ($Delay -lt 1) { $Delay = 1 }
if ($Density -gt 100) { $Density = 100 }
if ($Density -lt 0) { $Density = 0 }

$esc = [char]27
$reset = "$esc[0m"
$code = $Codes[$Color]
$boldOn = -not $NoBold
function Get-HeadAttr { if ($script:boldOn) { "$esc[1;${script:code}m" } else { "$esc[${script:code}m" } }
function Get-BodyAttr { "$esc[${script:code}m" }
$ci = [Array]::IndexOf($Order, $Color)

$raw = $Host.UI.RawUI
$w = $raw.WindowSize.Width
$h = $raw.WindowSize.Height
if ($w -lt 24 -or $h -lt 6) { Write-Error 'terminal too small (need 24x6)'; return }

$rng = [Random]::new()
$cols = [Collections.ArrayList]::new()
$x = 0
while ($x -lt ($w - 2)) {
  if ($rng.Next(100) -lt $Density) {
    $null = $cols.Add([PSCustomObject]@{
      X = $x; Y = $rng.Next(-$h, 1); Speed = @(1, 1, 2, 3)[$rng.Next(4)]
      Tick = 0; Trail = [Collections.ArrayList]::new()
    })
  }
  $x += $rng.Next(5, 12)
}

$paused = $false
$started = [DateTime]::UtcNow
function Set-Pos([int]$x, [int]$y) { try { [Console]::SetCursorPosition($x, $y) } catch {} }
function Set-Cursor([bool]$v) { try { [Console]::CursorVisible = $v } catch {} }
try {
  Set-Cursor $false
  try { Clear-Host } catch {}
  while ($true) {
    if ($Seconds -gt 0 -and ([DateTime]::UtcNow - $started).TotalSeconds -ge $Seconds) { break }
    if ($raw.KeyAvailable) {
      $k = $raw.ReadKey('NoEcho,IncludeKeyDown')
      $ch = $k.Character
      if ($k.VirtualKeyCode -eq 27 -or $ch -eq 'q' -or $ch -eq 'Q') { break }
      elseif ($ch -eq ' ') { $paused = -not $paused }
      elseif ($ch -eq '+' -or $ch -eq '=') { $Delay = [Math]::Max(1, $Delay - 5) }
      elseif ($ch -eq '-' -or $ch -eq '_') { $Delay += 5 }
      elseif ($ch -eq 'c' -or $ch -eq 'C') {
        $ci = ($ci + 1) % $Order.Count
        $script:code = $Codes[$Order[$ci]]
      }
      elseif ($ch -eq 'b' -or $ch -eq 'B') { $script:boldOn = -not $script:boldOn }
      elseif ($k.VirtualKeyCode -eq 3) { break }  # Ctrl+C delivered as key
    }
    if ($paused) { Start-Sleep -Milliseconds 50; continue }
    foreach ($c in $cols) {
      $c.Tick++
      if ($c.Tick -lt $c.Speed) { continue }
      $c.Tick = 0
      while ($c.Trail.Count -gt 7) {
        $old = $c.Trail[0]; $c.Trail.RemoveAt(0)
        if ($old.Y -ge 0 -and $old.Y -lt $h) {
          Set-Pos $c.X $old.Y
          Write-Host (' ' * ($old.Face.Length + 4)) -NoNewline
        }
      }
      $c.Y++
      if ($c.Y - 7 -gt $h) { $c.Y = $rng.Next(-9, 0); $c.Trail.Clear(); continue }
      $face = $Faces[$rng.Next($Faces.Count)]
      if ($c.Trail.Count -gt 0) {
        $prev = $c.Trail[$c.Trail.Count - 1]
        if ($prev.Y -ge 0 -and $prev.Y -lt $h) {
          Set-Pos $c.X $prev.Y
          Write-Host "$(Get-BodyAttr)$($prev.Face)$reset" -NoNewline
        }
      }
      if ($c.Y -ge 0 -and $c.Y -lt $h) {
        Set-Pos $c.X $c.Y
        Write-Host "$(Get-HeadAttr)$face$reset" -NoNewline
      }
      $null = $c.Trail.Add([PSCustomObject]@{ Y = $c.Y; Face = $face })
    }
    Start-Sleep -Milliseconds $Delay
  }
}
finally {
  Set-Cursor $true
  try { [Console]::ResetColor() } catch {}
  Write-Host ''
}
