## `Robocopy`
The robocopy script will open a terminal and run robocopy every minute, logging to a log file stamped with the current day.
Doing this will be an elegant way of having a new log file created every day. 
It will also avoid the log file eventually becoming unwieldy and increasing parsing times significantly.

```mermaid
stateDiagram-v2
    state "Get timestamp" as s0
    state "Check if Robocopy is running" as s1
    state if_rc_running <<choice>>
    [*] --> s0
    s0 --> s1
    s1 --> if_rc_running
    if_rc_running --> s1: is running
    state "Compare timestamps" as s2
    if_rc_running --> s2: is not running
    state if_timestamp <<choice>>
    s2 --> if_timestamp
    if_timestamp --> s1: no change
    state "Parse new log data" as s3
    if_timestamp --> s3: change
    state "Send email" as s4
    s3 --> s4
    state "Get timestamp" as s5
    s4 --> s5
    s5 --> s1
```

## `Start-RobocopyReport`
The Start-RobocopyReport script will run indefinitely run.
check if an instance of robocopy is running and while it is not running it will indefinitely run.
It's mode of action is:
```mermaid
stateDiagram-v2
    state "Check if Robocopy is running" as s1
    state if_state <<choice>>
    [*] --> s1
    s1 --> if_state
    if_state --> [*]: Robocopy is not running
    state "Wait for log file to be modified" as s2
    if_state --> s2: Robocopy is running
```

