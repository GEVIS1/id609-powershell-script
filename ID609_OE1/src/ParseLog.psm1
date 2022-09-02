function Get-LogData {
    [CmdletBinding()]
    param (
        # Path to the log file
        [Parameter(
            Mandatory=$true,
            Position=0)]
        [String]
        $LogFile,
        # The time to report logdata from. If empty return entire file.
        [Parameter(
            Mandatory=$false,
            Position=1)]
        [DateTime]
        $StartTime
    )
    
    # Exit if LogFile does not exist
    if (!(Test-Path -Path $LogFile)) {
    $errormsg = "Could not parse LogFile: $LogFile"
    throw $errormsg
    }
    
    $data = Get-Content -Path $LogFile -Raw

    if (!$StartTime) {
        Write-Host $data
        Write-Host "No start time given!"
    }
    else {
        Write-Host $data
        Write-Host "Returning log data from $StartTime"
    }
}