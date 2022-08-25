# This script runs indefinitely and starts up robocopy every minute to copy from $Source to $Destination
# It is a dependency of the Start-RobocopyReport script

function Start-Robocopy {
param(
  [Parameter(Mandatory=$true,
           Position=0,
           ValueFromPipeline=$true,
           ValueFromPipelineByPropertyName=$true,
           HelpMessage="Path to source of robocopy.")]
  [Alias("PSSource")]
  [ValidateNotNullOrEmpty()]
  [string[]]
  $Source,
  [Parameter(Mandatory=$true,
           Position=1,
           ValueFromPipeline=$true,
           ValueFromPipelineByPropertyName=$true,
           HelpMessage="Path to destination of robocopy.")]
  [Alias("PSDestination")]
  [ValidateNotNullOrEmpty()]
  [string[]]
  $Destination
)

$logdir = "$PSScriptRoot\logs\"

# Create log dir if it does not exist
if (-NOT (Test-Path -Path $logdir)) {
  Write-Host "Log directory $logdir does not exist. Creating it."
  New-Item -ItemType Directory -Path $logdir
}

  while ($true) {
    $logfile = "log-$(Get-Date -Format "yyyy-MM-dd").txt"
    Write-Host "Executing robocopy from $Source to $Destination with log file at: $logdir$logfile"
    # Calling robocopy with & opens it in a child shell
    # The /Z flag continues interrupted copies from their previous progress
    # The /MIR flag implies /E and /PURGE flags
    # The /E flag copies subdirectories including empty ones
    # The /PURGE flag deletes files from the destination folder that no longer exist in the source folder
    # The /MON:n flag waits for n changes before running robocopy again
    # The /MOT:m flag waits for m minutes before running robocopy again
    # The /X flag reports all eXtra files, not just files relevant to the copy operation
    # The /FP flag reports the full path names of all files
    # The /UNILOG+:file flag logs operations in unicode format appending to the path given in "file"
    robocopy $Source $Destination /Z /MIR /X /FP /UNILOG+:$logdir$logfile

    # Add newline for pretty printing
    Write-Host
    
    # Report if robocopy exited with an error
    if (-NOT $?) {
      Write-Host "ERROR: Robocopy ran with errors. Check Log File above."
    }

    # Sleep a minute before copying again
    Start-Sleep -Seconds 60
    }
}

# Modify these variables to change the default behaviour
$Source = Files
$Destination = Files_backup

# Set window title
$host.ui.RawUI.WindowTitle = "Robocopy: $Source -> $Destination"

# Start function
Start-Robocopy -Source $Source -Destination $Destination
