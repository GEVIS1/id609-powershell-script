<#
	This script starts all the parts necessary to verify the functionality of the assignment.
	It will:
	1. Start the file modifier applet.
	2. Start the mail server.
	3. Start the robocopy script.
	4. Start the main logging script.
#>

<#  
    Make sure our path is set to the root of the script,
    so paths to modules and log files are correct.
#>
if ((Get-Location) -Ne $PSScriptRoot) {
    Set-Location $PSScriptRoot
}

Start-Process -FilePath .\Start-FileModifier.lnk
Start-Process -FilePath .\Start-MailServer.lnk
Start-Process Powershell .\Start-Robocopy.ps1
Start-Process Powershell .\Start-LoggingFiles.ps1

Start-Sleep -Seconds 1
