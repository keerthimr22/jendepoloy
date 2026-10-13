$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'

$pythonRoot = Join-Path $env:WORKSPACE '.python'
$pythonExe = Join-Path $pythonRoot 'python.exe'
$installer = Join-Path $env:WORKSPACE 'python-3.14.8-amd64.exe'

if (-not (Test-Path -LiteralPath $pythonExe)) {
    $downloadUrl = 'https://www.python.org/ftp/python/3.14.8/python-3.14.8-amd64.exe'
    $expectedSha256 = '759be887b96e736a3ca886daf8d575f18fcae1a09efab6902f42d59e8999f8ef'

    Write-Host 'Downloading Python 3.14.8 from python.org...'
    Invoke-WebRequest -Uri $downloadUrl -OutFile $installer

    $actualSha256 = (Get-FileHash -LiteralPath $installer -Algorithm SHA256).Hash.ToLowerInvariant()
    if ($actualSha256 -ne $expectedSha256) {
        Remove-Item -LiteralPath $installer -Force
        throw "Python installer checksum mismatch. Expected $expectedSha256, got $actualSha256."
    }

    Write-Host 'Installing Python into the Jenkins workspace...'
    $installArgs = @(
        '/quiet'
        'InstallAllUsers=0'
        "TargetDir=$pythonRoot"
        'Include_pip=1'
        'Include_test=0'
        'PrependPath=0'
        'Shortcuts=0'
    )
    $process = Start-Process -FilePath $installer -ArgumentList $installArgs -Wait -PassThru
    if ($process.ExitCode -ne 0) {
        throw "Python installer failed with exit code $($process.ExitCode)."
    }
}

if (-not (Test-Path -LiteralPath $pythonExe)) {
    throw "Python installation did not create $pythonExe."
}

& $pythonExe --version
if ($LASTEXITCODE -ne 0) {
    throw 'The workspace Python installation could not start.'
}
