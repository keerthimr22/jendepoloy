$ErrorActionPreference = 'Stop'
$expected = 'Hello from Jenkins Docker Pipeline'

foreach ($port in @(5000, 5001)) {
    $uri = "http://localhost:$port/"
    $deadline = (Get-Date).AddSeconds(60)
    $verified = $false

    while ((Get-Date) -lt $deadline) {
        $response = $null
        try {
            $response = Invoke-WebRequest -UseBasicParsing -Uri $uri -TimeoutSec 5
        }
        catch {
            if ((Get-Date) -ge $deadline) {
                throw "Container at $uri did not become healthy within 60 seconds. $($_.Exception.Message)"
            }
            Start-Sleep -Seconds 2
            continue
        }

        if ($response.StatusCode -ne 200 -or $response.Content.Trim() -ne $expected) {
            throw "Unexpected response from ${uri}: $($response.StatusCode) $($response.Content)"
        }

        Write-Host "Verified $uri"
        $verified = $true
        break
    }

    if (-not $verified) {
        throw "Container at $uri did not become healthy within 60 seconds."
    }
}
