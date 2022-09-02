<#
    Elevation check. This script should run as administrator.
    Source: https://superuser.com/a/756696
#>
if (!([Security.Principal.WindowsPrincipal] `
    [Security.Principal.WindowsIdentity]::GetCurrent() `
    ).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    throw "This script needs Adminstrator privileges."
}

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
$sleep = 60 # How many seconds between each loop
$logdir = ".\logs\"
$logfile = "log-$(Get-Date -Format "yyyy-MM-dd").txt"

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
    Get-LogData -Logfile "$logdir$logfile" -StartTime (Get-Date)
    New-EventLogMessage -Type Information -Message "Wrote some stuff to the event log!"
    Start-Sleep -Seconds 60
}