#Requires AutoHotkey v2.0
Persistent
TraySetIcon ".\CustomIcons\ChangeRainmeterLayoutDetectResolution.ico"

OnMessage 0x7E, WM_DISPLAYCHANGE
return

WM_DISPLAYCHANGE(wParam, lParam, msg, hwnd)
{
	resolution := (lParam >> 16) & 0xffff
	
	if (resolution = 1080) {
		Run "C:\Program Files\Rainmeter\Rainmeter.exe [!LoadLayout `"Boxes 1080p`"]"
	}
	
	if (resolution = 1440) {
    	Run "C:\Program Files\Rainmeter\Rainmeter.exe [!LoadLayout `"Boxes 1440p`"]"
	}
}