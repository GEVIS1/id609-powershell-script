function ConvertFrom-RobocopyLog {
    param (
        # Robocopy log data
        [CmdletBinding()]
        [Parameter(Mandatory = $true,
            ValueFromPipeline = $true)]
        [AllowEmptyString()]
        [string]
        $LogData
    )

    $data = $LogData -split "`n"

    # Extract all the lines with new files and deleted files (extra files)
    # Matching on a string[] will return a string[] where the match is true
    $data = $data -match "(\*EXTRA)|(New File)"

    # $data
    # throw "StopPls"
        
    # Loop for each found line
    ($data | ForEach-Object {
        $_ -match "(?<Op>EXTRA|New) (?<Type>File|Dir).*\t(?<Name>[^\t\n]*$)" | Out-Null
        # "Line: $_"
        # "Matches.Type: $($Matches.Type)"
        # "Matches.Name: $($Matches.Name)"
        if ($Matches.Op -contains "New") {
            "CREATED " + $Matches.Type + " " + $Matches.Name 
        }
        elseif ($Matches.Op -contains "EXTRA") { 
            "DELETED " + $Matches.Type + " " + $Matches.Name 
        }
    }) -join "`n" # Return one string with newlines
}
