## `Robocopy`
The robocopy script will open a terminal and run robocopy indefinitely

## `Start-RobocopyReport`
The Start-RobocopyReport script will check if an instance of robocopy is running and while it is running it will indefinitely run.
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

