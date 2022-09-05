<#  
    Make sure our path is set to the root of the script,
    so paths to modules and log files are correct.
#>
if ((Get-Location) -Ne $PSScriptRoot) {
    Set-Location $PSScriptRoot
}

<# 
    Check for eleveated privileges. 
    These are necessary to create an Event Viewer Application log source.
    If not elevated, try starting the program again as administrator.
#>
if (!(New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host -NoNewLine "This script needs to run with elevated privileges, restarting in 3 seconds"

    for ($i = 0; $i -lt 3; $i++) {
        Start-Sleep -Seconds 1
        Write-Host -NoNewLine "."
    }

    Start-Process -FilePath "Powershell" -ArgumentList "$PSScriptRoot\$($MyInvocation.MyCommand)" -Verb Runas
    exit
}


Import-Module ".\src\ParseLog.psd1" -Force
Import-Module ".\src\EventLog.psd1" -Force
Import-Module ".\src\SendEmail.psd1" -Force


# Configuration variables
$ever = ";;"
$sleepseconds = 60
$logdir = ".\logs\"
$readtoken = "<DATA LAST READ HERE>"

# Create Event log source if it does not exist
if (!(Test-EventLogSource)) {
    Write-Host "Event log source not found. Creating."
    New-EventLogSource
}

# Set window title
$host.ui.RawUI.WindowTitle = "ID609_OE1 File logging script assignment"

Write-Host "All checks ok. Starting logging."

# This program is meant to run indefinitely, so wrap everything in a for loop that never ends.
for ($ever) {

    # Make sure we update the log file path so we follow day changes
    $logfile = "log-$(Get-Date -Format "yyyy-MM-dd").txt"

    # Check if log file exists
    if (!(Test-Path -Path "$logdir$logfile")) {
        New-EventLogMessage -Type Error -Message "Could not find logfile: $logdir$logfile.`nIs Robocopy running?"
    }

    # Get log file data
    Write-Host "Reading log data from: $logdir$logfile"
    $filedata = Get-Content -Path "$logdir$logfile"

    # Only grab data after $readtoken, we do this by getting the index of the token
    $start = $filedata.IndexOf($($filedata | Select-String -Pattern "^$readtoken$"))
    $end = $filedata.Count - 1

    <# 
        If no token was found ($start is -1 or $null), the file hasn't been read before, so let's read the entire file by setting start to 0.
        Else remove token.
    #>
    if ($start -le 0) {
        Write-Host "Could not find token, reading from start of file."
        $start = 0 
    } else {
        Write-Host "Found token, stored index and removed token."
        $filedata[$start] = ""
    }
    
    # We now have the index, so we can move the token to the bottom and write back to file
    Write-Host "Appended token to log file data."
    $filedata += $readtoken
    Write-Host "Writing log file data back to original log file."
    Set-Content -Path "$logdir$logfile" -Value $filedata

    # Extract only the bit we are interested in by ranging the array
    $logdata = $filedata[$start..$end]
    
    # Our data is in a string array but we need a single string, so join the strings with a newline character
    $parsedData = ConvertFrom-RobocopyLog -LogData ($logdata -join "`n")

    # Only log if $parsedData is not an empty string
    if ($parsedData) {
        Write-Host "Found changes. Writing to Event Log and Sending email."
        New-EventLogMessage -Type Information -Message "$parsedData"

        # Append <CR><LF>.<CR><LF> to appease email gods
        $parsedData += "`r`n.`r`n"

        try {
            Send-FileLogEmail -MessageBody "$parsedData"
        }
        catch {
            Write-Warning "Could not send Email.. is the SMTP server running?"
            New-EventLogMessage -Type Error -Message "Could not send Email.. is the SMTP server running?"
        }
    } else {
        Write-Host "No changes found."
        New-EventLogMessage -Type Information -Message "No new changes to report."
    }
    
    Write-Host "All operations finished. Restarting in $sleepseconds seconds.`n`n"
    Start-Sleep -Seconds $sleepseconds
}
