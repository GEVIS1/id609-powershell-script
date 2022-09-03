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

    # Turn the LogData into an array for easier manipulation
    $data = $LogData -split "`n"

    # Extract all the lines with new files and deleted files (extra files)
    # Matching on a string[] will return a string[] where the match is true
    $data = $data -match "(\*EXTRA)|(New File)"
        
    # Loop for each found line
    ($data | ForEach-Object {
        # Regex lines that have extra or new files and use capture groups to capture the operation, filetype and filename
        $_ -match "(?<Op>EXTRA|New) (?<Type>File|Dir).*\t(?<Name>[^\t\n]*$)" | Out-Null
        if ($Matches.Op -contains "New") {
            "CREATED `t" + $Matches.Type + "`t" + $Matches.Name 
        }
        elseif ($Matches.Op -contains "EXTRA") { 
            "DELETED `t" + $Matches.Type + "`t" + $Matches.Name 
        }
    }) -join "`n" # Return one string with newlines
}
