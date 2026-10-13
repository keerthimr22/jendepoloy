$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'

$pythonRoot = Join-Path $env:WORKSPACE '.python'
$pythonExe = Join-Path $pythonRoot 'python.exe'
$archive = Join-Path $env:WORKSPACE 'python-3.14.8-embed-amd64.zip'
$pythonPathFile = Join-Path $pythonRoot 'python314._pth'
$stdlibZip = Join-Path $pythonRoot 'python314.zip'

if (-not ((Test-Path -LiteralPath $pythonExe) -and
          (Test-Path -LiteralPath $pythonPathFile) -and
          (Test-Path -LiteralPath $stdlibZip))) {
    if (Test-Path -LiteralPath $pythonRoot) {
        Remove-Item -LiteralPath $pythonRoot -Recurse -Force
    }

    $downloadUrl = 'https://www.python.org/ftp/python/3.14.8/python-3.14.8-embed-amd64.zip'
    $expectedSha256 = 'a93abe456ab01bd96d7a085b3cdb6566b3063f4241360d114142fbdb07f0a310'

    Write-Host 'Downloading the Python 3.14.8 embeddable package from python.org...'
    Invoke-WebRequest -UseBasicParsing -Uri $downloadUrl -OutFile $archive

    $actualSha256 = (Get-FileHash -LiteralPath $archive -Algorithm SHA256).Hash.ToLowerInvariant()
    if ($actualSha256 -ne $expectedSha256) {
        Remove-Item -LiteralPath $archive -Force
        throw "Python archive checksum mismatch. Expected $expectedSha256, got $actualSha256."
    }

    New-Item -ItemType Directory -Path $pythonRoot -Force | Out-Null
    Expand-Archive -LiteralPath $archive -DestinationPath $pythonRoot -Force
    Remove-Item -LiteralPath $archive -Force
}

if (-not (Test-Path -LiteralPath $pythonExe)) {
    throw "Python archive did not contain $pythonExe."
}

# Enable site-packages and add the package directory to this isolated runtime.
$pythonPaths = @(Get-Content -LiteralPath $pythonPathFile)
if ($pythonPaths -notcontains 'packages') {
    $pythonPaths += 'packages'
}
if ($pythonPaths -notcontains 'import site') {
    $pythonPaths += 'import site'
}
Set-Content -LiteralPath $pythonPathFile -Value $pythonPaths -Encoding ASCII

# The embeddable distribution omits pip. Bootstrap it from the Python Packaging Authority.
& $pythonExe -m pip --version 2>$null
if ($LASTEXITCODE -ne 0) {
    $getPip = Join-Path $env:WORKSPACE 'get-pip.py'
    Write-Host 'Bootstrapping pip...'
    Invoke-WebRequest -UseBasicParsing -Uri 'https://bootstrap.pypa.io/get-pip.py' -OutFile $getPip
    & $pythonExe $getPip --disable-pip-version-check
    if ($LASTEXITCODE -ne 0) {
        throw 'Could not bootstrap pip in the workspace Python runtime.'
    }
}

& $pythonExe --version
if ($LASTEXITCODE -ne 0) {
    throw 'The workspace Python runtime could not start.'
}
