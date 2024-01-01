#Requires AutoHotkey v2.0
Persistent
TraySetIcon ".\CustomIcons\ShowIdleBoxWhenIdle.ico"

;timeout = 10 minutes
TimeLimit := 600000 

CommandExecuted := false

; Check every minute
SetTimer CheckIdle, 60000 

CheckIdle()
{
	global CommandExecuted
	
    if ((A_TimeIdle > TimeLimit) and (CommandExecuted = false)) 
	{
        Run "C:\Program Files\Rainmeter\Rainmeter.exe [!LoadLayout `"Boxes Idle`"]"
        CommandExecuted := true
    }
	
	if ((A_TimeIdle < TimeLimit) and (CommandExecuted = true)) 
	{
        CommandExecuted := false
    }

	return
}
