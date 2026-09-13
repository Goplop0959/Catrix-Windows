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
  [switch]$Update,
  [switch]$Diag,
  [switch]$ShowVersion
)

$Version = '1.1.0'
$InstallUrl = 'https://raw.githubusercontent.com/Goplop0959/Catrix-Windows/refs/heads/master/Install.ps1'
$esc = [char]27
$reset = "$esc[0m"

if ($ShowVersion) { Write-Host "catrix $Version"; return }

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

if ($Color -eq 'update') {
  # `catrix update` positional form (matches the Debian edition).
  Write-Host 'catrix: updating...'
  $tmp = Join-Path $env:TEMP 'Catrix-Install.ps1'
  Invoke-WebRequest -Uri $InstallUrl -OutFile $tmp
  & $tmp
  return
}

if ($Update) {
  Write-Host 'catrix: updating...'
  $tmp = Join-Path $env:TEMP 'Catrix-Install.ps1'
  Invoke-WebRequest -Uri $InstallUrl -OutFile $tmp
  & $tmp
  return
}

if ($Diag) {
  $raw = $Host.UI.RawUI
  Write-Host "host=$($Host.Name)"
  try { Write-Host "window=$($raw.WindowSize.Width)x$($raw.WindowSize.Height) buffer=$($raw.BufferSize.Width)x$($raw.BufferSize.Height)" } catch { Write-Host "size-query-failed: $_" }
  Write-Host "colors=$($Codes.Count) faces=$($Faces.Count) ansi-test=$esc[32mGREEN$reset"
  Write-Host 'DIAG-OK'
  return
}

if (-not $Codes.ContainsKey($Color)) { Write-Error "unknown color '$Color'"; return }
if ($Delay -lt 1) { $Delay = 1 }
if ($Density -gt 100) { $Density = 100 }
if ($Density -lt 0) { $Density = 0 }

$code = $Codes[$Color]
$boldOn = -not $NoBold
function Get-HeadAttr { if ($script:boldOn) { "$esc[1;${script:code}m" } else { "$esc[${script:code}m" } }
function Get-BodyAttr { "$esc[${script:code}m" }
$ci = [Array]::IndexOf($Order, $Color)
function Get-CellWidth([string]$s) {
  # Terminal cell width the PS1-native way: text elements, combining
  # marks (Mn/Me) take 0 cells, East-Asian wide/fullwidth take 2.
  $w = 0
  $en = [Globalization.StringInfo]::GetTextElementEnumerator($s)
  while ($en.MoveNext()) {
    $el = $en.GetTextElement()
    try {
      $cat = [Globalization.CharUnicodeInfo]::GetUnicodeCategory($el, 0)
      if ($cat -eq 'NonSpacingMark' -or $cat -eq 'EnclosingMark') { continue }
      $code = [char]::ConvertToUtf32($el, 0)
      if (($code -ge 0x1100 -and $code -le 0x115F) -or $code -eq 0x2329 -or $code -eq 0x232A -or `
          ($code -ge 0x2E80 -and $code -le 0x303E) -or ($code -ge 0x3041 -and $code -le 0x33FF) -or `
          ($code -ge 0x3400 -and $code -le 0x4DBF) -or ($code -ge 0x4E00 -and $code -le 0x9FFF) -or `
          ($code -ge 0xA000 -and $code -le 0xA4CF) -or ($code -ge 0xAC00 -and $code -le 0xD7A3) -or `
          ($code -ge 0xF900 -and $code -le 0xFAFF) -or ($code -ge 0xFE10 -and $code -le 0xFE1F) -or `
          ($code -ge 0xFE30 -and $code -le 0xFE4F) -or ($code -ge 0xFF00 -and $code -le 0xFF60) -or `
          ($code -ge 0xFFE0 -and $code -le 0xFFE6) -or ($code -ge 0x1F300 -and $code -le 0x1FAFF) -or `
          ($code -ge 0x20000 -and $code -le 0x3FFFD)) { $w += 2 } else { $w += 1 }
    } catch { $w += 1 }
  }
  return $w
}
$FaceW = @{}
$MaxW = 0
foreach ($f in $Faces) { $ww = Get-CellWidth $f; $FaceW[$f] = $ww; if ($ww -gt $MaxW) { $MaxW = $ww } }

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
  $x += $MaxW + 2 + $rng.Next(0, 4)
}

if ($cols.Count -eq 0) { Write-Warning 'catrix: no rain columns created (check terminal size)'; return }
$paused = $false
$script:frame = 0
Add-Type @'
using System;
using System.Runtime.InteropServices;
public static class ConIn {
  [DllImport("kernel32.dll")] public static extern IntPtr GetStdHandle(int n);
  [DllImport("kernel32.dll")] public static extern bool GetNumberOfConsoleInputEvents(IntPtr h, out uint n);
  [DllImport("kernel32.dll")] public static extern bool PeekConsoleInputW(IntPtr h, [Out] INPUT_RECORD[] buf, uint len, out uint read);
  [DllImport("kernel32.dll")] public static extern bool ReadConsoleInputW(IntPtr h, [Out] INPUT_RECORD[] buf, uint len, out uint read);
  [StructLayout(LayoutKind.Explicit)] public struct INPUT_RECORD {
    [FieldOffset(0)] public ushort EventType;
    [FieldOffset(4)] public KEY_EVENT Key;
  }
  [StructLayout(LayoutKind.Sequential)] public struct KEY_EVENT {
    public bool bKeyDown; public ushort wRepeatCount, wVirtualKeyCode, wVirtualScanCode;
    public char UnicodeChar; public uint dwControlKeyState;
  }
}
'@
function Poll-Key {
  # Raw peek: returns one key-DOWN record per call, discards mouse/focus/
  # menu junk that otherwise wedges KeyAvailable forever. Never blocks.
  try {
    $h = [ConIn]::GetStdHandle(-10)
  while ($true) {
    $n = 0u
    if (-not [ConIn]::GetNumberOfConsoleInputEvents($h, [ref]$n)) { return $null }
    if ($n -eq 0) { return $null }
    $buf = New-Object ConIn+INPUT_RECORD[] 1
    $r = 0u
    if (-not [ConIn]::PeekConsoleInputW($h, $buf, 1, [ref]$r)) { return $null }
    if ($buf[0].EventType -eq 1 -and $buf[0].Key.bKeyDown) {
      [ConIn]::ReadConsoleInputW($h, $buf, 1, [ref]$r) | Out-Null
      return $buf[0].Key
    }
    [ConIn]::ReadConsoleInputW($h, $buf, 1, [ref]$r) | Out-Null
  }
  } catch { return $null }
}
$started = [DateTime]::UtcNow
function Set-Pos([int]$x, [int]$y) { try { [Console]::SetCursorPosition($x, $y) } catch {} }
function Set-Cursor([bool]$v) { try { [Console]::CursorVisible = $v } catch {} }
try {
  Set-Cursor $false
  try { Clear-Host } catch {}
  while ($true) {
    if ($Seconds -gt 0 -and ([DateTime]::UtcNow - $started).TotalSeconds -ge $Seconds) { break }
    $k = Poll-Key
    if ($k) {
      $ch = $k.UnicodeChar
      if ($k.VirtualKeyCode -eq 27 -or $ch -eq 'q' -or $ch -eq 'Q' -or $ch -eq [char]3) { break }
      elseif ($ch -eq ' ') { $paused = -not $paused }
      elseif ($ch -eq '+' -or $ch -eq '=') { $Delay = [Math]::Max(1, $Delay - 5) }
      elseif ($ch -eq '-' -or $ch -eq '_') { $Delay += 5 }
      elseif ($ch -eq 'c' -or $ch -eq 'C') {
        $ci = ($ci + 1) % $Order.Count
        $script:code = $Codes[$Order[$ci]]
      }
      elseif ($ch -eq 'b' -or $ch -eq 'B') { $script:boldOn = -not $script:boldOn }
    }
    if ($paused) { Start-Sleep -Milliseconds 50; continue }
    $headAttr = if ($script:boldOn) { "$esc[1;${script:code}m" } else { "$esc[${script:code}m" }
    $bodyAttr = "$esc[${script:code}m"
    $sb = [Text.StringBuilder]::new(8192)
    foreach ($c in $cols) {
      $c.Tick++
      if ($c.Tick -lt $c.Speed) { continue }
      $c.Tick = 0
      while ($c.Trail.Count -gt 7) {
        $old = $c.Trail[0]; $c.Trail.RemoveAt(0)
        if ($old.Y -ge 0 -and $old.Y -lt $h) {
          [void]$sb.Append("$esc[$($old.Y + 1);$($c.X + 1)H")
          [void]$sb.Append((' ' * $FaceW[$old.Face]))
        }
      }
      $c.Y++
      if ($c.Y - 7 -gt $h) { $c.Y = $rng.Next(-9, 0); $c.Trail.Clear(); continue }
      $face = $Faces[$rng.Next($Faces.Count)]
      if ($c.Trail.Count -gt 0) {
        $prev = $c.Trail[$c.Trail.Count - 1]
        if ($prev.Y -ge 0 -and $prev.Y -lt $h) {
          [void]$sb.Append("$esc[$($prev.Y + 1);$($c.X + 1)H$bodyAttr$($prev.Face)$reset")
        }
      }
      if ($c.Y -ge 0 -and $c.Y -lt $h) {
        [void]$sb.Append("$esc[$($c.Y + 1);$($c.X + 1)H$headAttr$face$reset")
      }
      $null = $c.Trail.Add([PSCustomObject]@{ Y = $c.Y; Face = $face })
    }
    try { Write-Host $sb.ToString() -NoNewline } catch { Write-Error "catrix draw failed: $_"; break }
    $script:frame = [int]$script:frame + 1
    try { $Host.UI.RawUI.WindowTitle = "catrix frame $script:frame" } catch {}
    Start-Sleep -Milliseconds $Delay
  }
}
catch { Write-Error "catrix stopped on error: $_" }
finally {
  try { Clear-Host } catch {}
  Set-Cursor $true
  try { [Console]::ResetColor() } catch {}
}
