<#  
    Make sure our path is set to the root of the script,
    so paths to modules and log files are correct.
#>
if ((Get-Location) -Ne $PSScriptRoot) {
    Set-Location $PSScriptRoot
}

Import-Module ".\src\ParseLog.psd1" -Force
Import-Module ".\src\EventLog.psd1" -Force
#Import-Module ".\src\SendEmail.psd1"


# Configuration variables
$ever = ";;"
$sleepseconds = 60
$logdir = ".\logs\"
$logfile = "log-$(Get-Date -Format "yyyy-MM-dd").txt"
$readtoken = "<DATA LAST READ HERE>"

# Create Event log source if it does not exist
if (!(Test-EventLogSource)) {
    Write-Host "Event log source not found. Creating."
    New-EventLogSource
}

# Set window title
$host.ui.RawUI.WindowTitle = "ID609_OE1 File logging script assignment"

# This program is meant to run indefinitely, so wrap everything in a for loop that never ends.
for ($ever) {

    # Check if log file exists
    if (!(Test-Path -Path "$logdir$logfile")) {
        New-EventLogMessage -Type Error -Message "Could not find logfile: $logdir$logfile.`nIs Robocopy running?"
    }

    # Get log file data
    $filedata = Get-Content -Path "$logdir$logfile"

    # Only grab data after $readtoken, we do this by getting the index of the token
    $start = $filedata.IndexOf($($filedata | Select-String -Pattern "^$readtoken$"))
    $end = $filedata.Count - 1

    <# 
        If no token was found ($start is -1 or $null), the file hasn't been read before, so let's read the entire file by setting start to 0.
        Else remove token.
    #>
    if ($start -le 0) { 
        $start = 0 
    } else {
        $filedata[$start] = ""
    }
    
    # We now have the index, so we can move the token to the bottom and write back to file
    $filedata += $readtoken
    Set-Content -Path "$logdir$logfile" -Value $filedata

    # Extract only the bit we are interested in by ranging the array
    $logdata = $filedata[$start..$end]
    
    # Our data is in a string array but we need a single string, so join the strings with a newline character
    $parsedData = ConvertFrom-RobocopyLog -LogData ($logdata -join "`n")

    # Only log if $parsedData is not an empty string
    if ($parsedData) {
        New-EventLogMessage -Type Information -Message "$parsedData"

        # Append <CR><LF>.<CR><LF> to appease email gods
        $parsedData += "`r`n.`r`n"
    } else {
        New-EventLogMessage -Type Information -Message "No new changes to report."
    }
    
    Start-Sleep -Seconds $sleepseconds
}
