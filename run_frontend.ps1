$ErrorActionPreference = 'Stop'

$repoRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$drive = 'N:'

if (Test-Path "$drive\") {
  subst $drive /d | Out-Null
}

subst $drive $repoRoot | Out-Null

try {
  $flutter = Join-Path $drive 'tools\flutter\bin\flutter.bat'
  Push-Location (Join-Path $drive 'frontend')
  & $flutter run -d chrome
}
finally {
  Pop-Location -ErrorAction SilentlyContinue
  subst $drive /d | Out-Null
}
