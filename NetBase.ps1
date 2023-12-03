param (
    [string]$location = $null,
    [switch]$baselineOnly,
    [switch]$timestamp
)

# Function to get timestamp
function Get-Timestamp {
    return Get-Date -Format "yyyy-MM-dd HH:mm:ss"
}

# Check if the -l flag is provided
if ($location) {
    $baselinePath = Join-Path $location "baseline.csv"
    $suspectPath = Join-Path $location "suspect.csv"
} else {
    $baselinePath = ".\baseline.csv"
    $suspectPath = ".\suspect.csv"
}

function Update-SuspectData {
    # Load baseline data
    $baselineData = Import-Csv $baselinePath

    # Load suspect data
    $suspectData = Import-Csv $suspectPath -ErrorAction SilentlyContinue

    # Get current connections
    $currentConnections = Get-NetTCPConnection | Where-Object { $_.State -eq "Established" -and $_.RemoteAddress -ne "127.0.0.1" } | ForEach-Object {
        $process = Get-Process -Id $_.OwningProcess | Where-Object { $_.Path }
        $_ | Select-Object RemoteAddress, RemotePort, @{Name="Process";Expression={$process.Path}}
    }

    # Compare with baseline data and suspect data, add new connections to suspect.csv
    $newConnections = $currentConnections | Where-Object {
        $match = $false
        foreach ($baselineEntry in $baselineData) {
            if (
                $_.RemoteAddress -eq $baselineEntry.RemoteAddress -and
                $_.RemotePort -eq $baselineEntry.RemotePort -and
                $_.Process -eq $baselineEntry.Process
            ) {
                $match = $true
                break
            }
        }
        
        foreach ($suspectEntry in $suspectData) {
            if (
                $_.RemoteAddress -eq $suspectEntry.RemoteAddress -and
                $_.RemotePort -eq $suspectEntry.RemotePort -and
                $_.Process -eq $suspectEntry.Process
            ) {
                $match = $true
                break
            }
        }

        -not $match
    }

    # Add timestamp if the -t flag is provided
    if ($timestamp -and $newConnections) {
        $newConnections | ForEach-Object { $_ | Add-Member -MemberType NoteProperty -Name "Timestamp" -Value (Get-Timestamp) -PassThru } | Export-Csv -Path $suspectPath -NoTypeInformation -Append
    } elseif ($newConnections) {
        $newConnections | Export-Csv -Path $suspectPath -NoTypeInformation -Append
    }
}

# Check if the -b flag is provided
if ($baselineOnly) {
    # Get current connections
    $currentConnections = Get-NetTCPConnection | Where-Object { $_.State -eq "Established" -and $_.RemoteAddress -ne "127.0.0.1" } | ForEach-Object {
        $process = Get-Process -Id $_.OwningProcess | Where-Object { $_.Path }
        $_ | Select-Object RemoteAddress, RemotePort, @{Name="Process";Expression={$process.Path}}
    }

    # Add timestamp if the -t flag is provided
    if ($timestamp) {
        $currentConnections | ForEach-Object { $_ | Add-Member -MemberType NoteProperty -Name "Timestamp" -Value (Get-Timestamp) -PassThru } | Export-Csv -Path $baselinePath -NoTypeInformation -Append
    } else {
        $currentConnections | Export-Csv -Path $baselinePath -NoTypeInformation -Append
    }
} else {
    Update-SuspectData
}
