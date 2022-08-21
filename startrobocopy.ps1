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

Write-Host "Executing robocopy from $Source to $Destination"
}

Start-Robocopy -Source ID609_OE1 -Destination ID609_OE1_backup
#& robocopy $sourcepath $destinationpath /E /ZB 

# Calling robocopy with & opens it in a 
# The /E flag copies subdirectories including empty ones
# The /ZB flag continues interrupted copies from their previous progress and attempts to copy files ignoring permissions, assuming you have sufficient elevation


