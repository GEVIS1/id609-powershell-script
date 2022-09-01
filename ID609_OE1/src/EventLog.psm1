

$LogSource = "ID609FileLogger"

function Test-EventLogSource {
    # Try to get the ID609FileLogger event source
    $_result = Get-WinEvent -ListProvider $LogSource -ErrorAction Ignore

    <# 
        If the log source does not exist, then result will be null.
        So if _result is not equal to null that means it exists and we
        return true.
    #>
    
    return $null -Ne $_result
}
function New-EventLogSource {New-EventLog -LogName 'Application' -Source $LogSource -ErrorAction Stop}

function New-EventLogMessage {
    param(
        # The Type of the message
        [Parameter(Mandatory=$false)]
        [System.Diagnostics.EventLogEntryType]
        $Type,
        # The message of the log entry
        [Parameter(
            Mandatory=$true,
            HelpMessage="A message is required!"
        )]
        [string]
        $Message
    )

    if ($null -Eq $Type) {
        $Type = [System.Diagnostics.EventLogEntryType]"Information"
    }
    Write-EventLog -LogName Application -Source "ID609FileLogger" -EventID 3001 -Message $Message -EntryType $Type
}
