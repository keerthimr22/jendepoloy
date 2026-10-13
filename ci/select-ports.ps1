$ErrorActionPreference = 'Stop'
$selectedPorts = [System.Collections.Generic.List[int]]::new()

for ($port = 5000; $port -le 5100 -and $selectedPorts.Count -lt 2; $port++) {
    $listener = [System.Net.Sockets.TcpListener]::new([System.Net.IPAddress]::Loopback, $port)
    try {
        $listener.Start()
        $selectedPorts.Add($port)
    }
    catch {
        # The port is already in use or unavailable; try the next one.
    }
    finally {
        $listener.Stop()
    }
}

if ($selectedPorts.Count -ne 2) {
    throw 'No two free localhost ports were found between 5000 and 5100.'
}

$selectedPorts | ForEach-Object { Write-Output $_ }
