<#  
    Make sure our path is set to the root of the script,
    so paths to modules and log files are correct.
#>
if ((Get-Location) -Ne $PSScriptRoot) {
    Set-Location $PSScriptRoot
}

Import-Module ".\src\ParseLog.psd1" -Force
#Import-Module ".\src\EventLog.psd1"
#Import-Module ".\src\SendEmail.psd1"

# Configuration variables
$ever = ";;"
$sleep = 60 # How many seconds between each loop
$logdir = ".\logs\"
$logfile = "log-$(Get-Date -Format "yyyy-MM-dd").txt"

# This program is meant to run indefinitely, so wrap everything in a for loop that never ends.
for ($ever) {
    Get-LogData -Logfile "$logdir$logfile"
    Start-Sleep -Seconds 1
}