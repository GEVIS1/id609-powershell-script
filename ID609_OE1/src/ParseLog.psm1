function Get-LogData {
    [CmdletBinding()]
    param (
        # Path to the log file
        [Parameter(
            Mandatory = $true,
            Position = 0)]
        [String]
        $LogFile,
        # The time to report logdata from. If empty return entire file.
        [Parameter(
            Mandatory = $false,
            Position = 1)]
        [DateTime]
        $StartTime
    )

    # Exit if LogFile does not exist
    if (!(Test-Path -Path $LogFile)) {
        $errormsg = "Could not parse LogFile: $LogFile"
        throw $errormsg
    }
    
    $data = Get-Content -Path $LogFile

    if ($StartTime) {
                        Write-Host "Start time given! Looking for correct time."
        # Regular expression matching the lines where robocopy started
        $regex = "^.*Started : .*$"

        # Get all robocopy starting lines
        $starttimes = $data -match $regex

        Write-Host "Matches in starttimes: $($starttimes.Count)"

        # Iterate the matched end times to find the date closest to and also before the start time
        $regex2 = "^.{2}Started : "
        for ($i = 0; $i -lt $starttimes.Count; $i++) {
            $iterationtime = ([DateTime]($starttimes[$i] -split $regex2)[1])
            <# 
                $date1 = [DateTime]"9999-00-00T00:00"
                $date2 = [DateTime]"2000-00-00T00:00"
                $date1.CompareTo($date2) will return 1 because $date1 is a later date than $date2
                Possible results for [DateTime].CompareTo():
                $date1 -lt $date2 = -1
                $date1 -eq $date2 = 0
                $date1 -gt $date2 = 1
            #>
            # This debug string is too handy to delete.
            #"$($i.ToString().PadLeft(2,"0"))`: $([DateTime]($starttimes[$i] -split "^.{3}Ended : ")[1])"
            <#  
                If the result of this comparison is -1, I.E. the iteration time is older than the StartTime,
                then the previous endtime is the one we care about, since we want the last data just before StartTime.
            #>
            Write-Host "====================$($i.ToString().PadLeft(2,"0"))======================"
            Write-Host "Start time: $starttime"
            Write-Host "Iteration time: $iterationtime"
            Write-Host "Is start time earlier than this time? $(($StartTime).CompareTo($iterationtime))"

            if (($StartTime).CompareTo($iterationtime) -eq -1) {
                # Get the index of that line in the string array
                $startindex = $data.IndexOf($starttimes[$i - 1])
                # Break here, so we don't overwrite the start index with any later entries.
                                Write-Host "Found start line!: $($starttimes[$i - 1]).`nBreaking!"
                break
            }
        }

        # If there is no start index, either the robocopy script is not running or something went wrong.
        if ($null -eq $startindex) {
            Write-Host "It empty."
            return $null
        }

        # Get array end index
        $endindex = $data.Count - 1

                    Write-Host "Start index: $startindex"
                    Write-Host "End index: $endindex"
                    Write-Host "Line at Start index: $($data[$startindex])"
                    Write-Host "Last text line: $($data[$endindex - 1])"
                    Write-Host "Wrote data to: ..\logs\output.txt"
                    $data[$startindex..$endindex] > .\logs\output.txt    

        # Return all the data from the matched regex line to the end of the array
        $data = $data[$startindex..$endindex]
    }

    return $data -join "`n"
}

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
