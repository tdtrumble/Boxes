Persistent
#Requires AutoHotkey v2.0
#SingleInstance Force

TraySetIcon ".\CustomIcons\RemapWindowsKey.ico"

if (A_Args.Length = 0)
{
	toggle := 1 ;1=window is down and needs to come up
}
else
{
	toggle := A_Args[1] 
}

LWin::
{
	if (toggle = 1) 
	{
		Run "C:\Program Files\Rainmeter\Rainmeter.exe [!HideGroup Boxes][!ZPosGroup 1 Boxes][!FadeDurationGroup 50 Boxes][!ShowFadeGroup Boxes]"
		global toggle := 0
	}
	else 
	{
		Run "C:\Program Files\Rainmeter\Rainmeter.exe [!FadeDurationGroup 50 Boxes][!HideFadeGroup Boxes]"
		Sleep 800
		Run "C:\Program Files\Rainmeter\Rainmeter.exe [!ZPosGroup -2 Boxes][!ShowGroup Boxes]"
		global toggle := 1
	}
}

RWin::
{
	if (toggle = 1) 
	{
		Run "C:\Program Files\Rainmeter\Rainmeter.exe [!HideGroup Boxes][!ZPosGroup 1 Boxes][!FadeDurationGroup 50 Boxes][!ShowFadeGroup Boxes]"
		global toggle := 0
	}
	else 
	{
		Run "C:\Program Files\Rainmeter\Rainmeter.exe [!FadeDurationGroup 50 Boxes][!HideFadeGroup Boxes]"
		Sleep 800
		Run "C:\Program Files\Rainmeter\Rainmeter.exe [!ZPosGroup -2 Boxes][!ShowGroup Boxes]"
		global toggle := 1
	}
}

<^Esc::Esc