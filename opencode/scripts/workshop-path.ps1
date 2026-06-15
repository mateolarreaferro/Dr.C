# Shared PATH for Dr.C Terminal launchers (Windows).
#   . "$PSScriptRoot\workshop-path.ps1"

function Add-WorkshopPath {
    param([string]$Dir)
    if (-not $Dir) { return }
    if (Test-Path -LiteralPath $Dir) {
        if ($env:PATH -notlike "*$Dir*") {
            $env:PATH = "$Dir;$env:PATH"
        }
    }
}

$home = $env:USERPROFILE
$local = $env:LOCALAPPDATA
$pf = ${env:ProgramFiles}
$pfx86 = ${env:ProgramFiles(x86)}

Add-WorkshopPath (Join-Path $home "bin")
if ($local) { Add-WorkshopPath (Join-Path $local "Csound") }
if ($pf) {
    Add-WorkshopPath (Join-Path $pf "Csound")
    Add-WorkshopPath (Join-Path $pf "Csound-x64")
}
if ($pfx86) { Add-WorkshopPath (Join-Path $pfx86 "Csound") }
