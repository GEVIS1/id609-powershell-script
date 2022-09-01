<#
.SYNOPSIS

Reads in a log file and returns the file additions, file deletions and file modifications.

.DESCRIPTION

TODO

.PARAMETER InputPath
Specifies the path to the CSV-based input file.

.PARAMETER OutputPath
Specifies the name and path for the CSV-based output file. By default,
MonthlyUpdates.ps1 generates a name from the date and time it runs, and
saves the output in the local directory.

.INPUTS

None. You cannot pipe objects to Get-LogData.

.OUTPUTS

TODO

.EXAMPLE

PS> .\Update-Month.ps1

.EXAMPLE

PS> .\Update-Month.ps1 -inputpath C:\Data\January.csv

.EXAMPLE

PS> .\Update-Month.ps1 -inputpath C:\Data\January.csv -outputPath `
C:\Reports\2009\January.csv
#>
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