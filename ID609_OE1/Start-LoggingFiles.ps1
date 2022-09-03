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
$begin = $true

# Create Event log source if it does not exist
if (!(Test-EventLogSource)) {
    Write-Host "Event log source not found. Creating."
    New-EventLogSource
}

if (!(Test-Path -Path "$logdir$logfile")) {
    throw [System.IO.FileNotFoundException]"Could not find logfile. Is Robocopy running?"
    # TODO: Write to event log
}

# Set window title
$host.ui.RawUI.WindowTitle = "File logger script"

# This program is meant to run indefinitely, so wrap everything in a for loop that never ends.
for ($ever) {
    # If no starttime is set, we are in the first iteration of the loop, so read from lastdate.txt
    if (!$starttime -and $begin) {
        # If a lastdate file exists
        if (Test-Path -Path $logdir\lastdate.txt) {
            # Read it to $starttime
            $starttime = Get-Content -Path $logdir\lastdate.txt

            Write-Host "Loaded start time: $starttime"
        } else {
            # No lastdate found, use current time
            $starttime = (Get-Date).AddMinutes(-1)
        }
        $begin = $false
    } else {
        # If no start time could be loaded, just start from now.
        New-EventLogMessage -Type Information -Message "No lastdate.txt found. Starting logging from current time."
        $starttime = (Get-Date).AddMinutes(-1)
        $begin = $false
    }

    Write-Host "Calling Get-LogData with starttime: $starttime"
    $logdata = Get-LogData -Logfile "$logdir$logfile" -StartTime $starttime

    # If Get-LogData returns null, the data could not be read and we should not move the start time forward
    if (!$logdata) {
        New-EventLogMessage -Type Warning -Message "Could not find any log data after start time. Is the logger running?"
    } else {
        $starttime = (Get-Date).AddMinutes(-1)
    }
    
    $parsedData = ConvertFrom-RobocopyLog -LogData $logdata
    New-EventLogMessage -Type Information -Message "$parsedData"

    # Write previous start time to logs so we can pick back up where we left if the program stops/restarts
    New-Item -Path $logdir\lastdate.txt -ItemType File -Value $starttime -Force | Out-Null

    Start-Sleep -Seconds $sleepseconds
}
