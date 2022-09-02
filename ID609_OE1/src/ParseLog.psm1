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

    if (!$StartTime) {
        return $data
    }
    else {
        # Regular expression matching the lines where robocopy started
        $regex = "^.*Started : .*$"

        # Get all robocopy starting lines
        $starttimes = $data -match $regex

        # Iterate the matched end times in reverse to find the date closest to and also before the start time
        for ($i = $starttimes.Count - 1; $i -ge 0 ; $i--) {
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
                If the result of this comparison is -1, I.E. the current end time is older than the StartTime,
                then the previous endtime is the one we care about, since we want the last data just before StartTime.
            #>
            if (($StartTime).CompareTo(([DateTime]($starttimes[$i] -split "^.{2}Started : ")[1])) -eq -1) {
                # Get the index of that line in the string array
                $startindex = $data.IndexOf($starttimes[$i - 1])
            }
        }

        # Return all the data from the matched regex line to the end of the array
        return $data[$startindex..$data.Length]
    }
    }
}