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
<<<<<<< HEAD
Start-Process -FilePath Powershell .\Start-Robocopy.ps1
Start-Process -FilePath Powershell .\Start-LoggingFiles.ps1 -Verb RunAs

Start-Sleep -Seconds 1
=======
Start-Process Powershell .\Start-Robocopy.ps1
Start-Process Powershell .\Start-LoggingFiles.ps1
>>>>>>> b4a680461bbfb6d0816f6768d5b809052f0472e5
