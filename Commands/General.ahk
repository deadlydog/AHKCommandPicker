
AddCommand("ReloadAHKScript", "Reloads this AutoHotKey script")
ReloadAHKScript()
{
	Run, %A_ScriptFullPath%	
}

AddCommand("HomeAddressWithURL", "Pastes my home address with a URL to the Google Map")
HomeAddressWithURL()
{
	SendInput, 227 Hamilton St. N. (http://maps.google.com/maps?q=227+Hamilton+st+n&hl=en&ll=50.479425,-104.60922&spn=0.005708,0.016512&sll=50.49506,-104.599759&sspn=0.011412,0.033023&hnear=227+Hamilton+St+N,+Regina,+Saskatchewan+S4R+0J6,+Canada&t=m&z=17)
}

AddCommand("eMyComputer", "Explore My Computer")
eMyComputer()
{ 
	Run ::{20d04fe0-3aea-1069-a2d8-08002b30309d}  ; Opens the "My Computer" folder.
}

AddCommand("eRecycleBin", "Explore the Recycle Bin")
eRecycleBin()
{ 
	Run ::{645ff040-5081-101b-9f08-00aa002f954e}  ; Opens the Recycle Bin.
}

AddCommand("eC", "Explorer C:\")
eC()
{
	Run, explore C:\
}

AddCommand("eClipboard", "Explore whatever path is in the Clipboard")
eClipboard()
{
	; If the path exists, open it, otherwise just exit.
	; Always display what path we try to open.
	IfExist, %clipboard%
	{
		Run, explore %clipboard%
		msg = Opening location: %clipboard%
		return %msg%
	}
	else
	{
		msg = PATH DOES NOT EXIST: %clipboard%
		return %msg%
	}
}

AddCommand("eWindows", "Explore C:\Windows")
eWindows()
{
	Run, explore C:\Windows
}

AddCommand("eProgramFiles", "Explore C:\Program Files")
eProgramFiles()
{
	Run, explore "C:\Program Files"
}

AddCommand("eProgramFilesx86", "Explore C:\Program Files (x86)")
eProgramFilesx86()
{
	Run, explore "C:\Program Files (x86)"
}

AddCommand("NewEmail", "Opens a new email in the default main program")
NewEmail()
{
	Run, mailto:
}

AddCommand("CloseWindow", "Closes the currently active window")
CloseWindow()
{	global _cpActiveWindowID
	WinClose, ahk_id %_cpActiveWindowID%
}

AddCommand("MinimizeWindow", "Minimizes the currently active window")
MinimizeWindow()
{	global _cpActiveWindowID
	WinMinimize, ahk_id %_cpActiveWindowID%
}

AddCommand("MaximizeWindow", "Maximizes the currently active window")
MaximizeWindow()
{	global _cpActiveWindowID
	WinMaximize, ahk_id %_cpActiveWindowID%
}

AddCommand("AlwaysOnTopOn", "Sets the window to always be on top of others")
AlwaysOnTopOn()
{	global _cpActiveWindowID
	WinSet, AlwaysOnTop, On, ahk_id %_cpActiveWindowID%
}

AddCommand("AlwaysOnTopOff", "Sets the window to no longer always be on top of others")
AlwaysOnTopOff()
{	global _cpActiveWindowID
	WinSet, AlwaysOnTop, Off, ahk_id %_cpActiveWindowID%
}

AddCommand("Outlook", "Opens Outlook making sure it is maximized")
Outlook()
{
	windowID := PutWindowInFocus("Microsoft Outlook", "C:\Program Files\Microsoft Office\Office14\OUTLOOK.EXE")
	if (windowID)
	{
		WinMaximize, ahk_id %windowID%
	}
}

AddCommand("ContextMenu", "Simulates a right-click by using Shift+F10")
ContextMenu()
{
	SendInput, +{F10}	; Shift + F10 to simulate right mouse click
}

AddCommand("FireFox", "Launches Firefox, or if already open just puts it in focus")
FireFox()
{
	PutWindowInFocus("Mozilla Firefox", "C:\Program Files (x86)\Mozilla Firefox\firefox.exe")
}

AddCommand("FireFoxNewWindow", "Launches a new instance of Firefox")
FireFoxNewWindow()
{
	Run, "C:\Program Files (x86)\Mozilla Firefox\firefox.exe"
}



AddCommand("SplashText", "Display a Splash Text Window")
SplashText()
{
	SplashTextOn, , , Displays only a title bar.
	Sleep, 2000
	SplashTextOn, 400, 300, Clipboard, The clipboard contains:`n%clipboard%
	WinMove, Clipboard, , 0, 0  ; Move the splash window to the top left corner.
	Msgbox, Press OK to dismiss the SplashText
	SplashTextOff	
}





AddCommand("ShortenURL", "Replaces the long URL in the clipboard with a shortened one")
ShortenURL()
{
	; Get the URL from the clipboard
	longURL = %clipboard%	
	
	; Try and shorten the URL
	URL = http://tinyurl.com/api-create.php?url=%longURL%
	UrlDownloadToVar(URL,shortURL)

	; If the URL was shortened, go to Success, otherwise try again
	StringLeft, prefix, shortURL, 4
	if (%prefix% = http)
		Goto, ShortenURL_Shortened
	
	; Try and shorten the URL
	URL = http://is.gd/api.php?longurl=%longURL%
	UrlDownloadToVar(URL,shortURL)

	; If the URL was shortened, go to Success, otherwise try again
	if (%prefix% = http)
		Goto, ShortenURL_Shortened

	; Try and shorten the URL
	URL = http://api.tr.im/api/trim_simple?url=%longURL%
	UrlDownloadToVar(URL,shortURL)

	; If the URL was shortened, go to Success, otherwise try again
	StringLeft, prefix, shortURL, 4
	if (%prefix% = http)
		Goto, ShortenURL_Shortened
	
	
	ShortenURL_ERROR:
		msg = Could not shorten the URL: `r`n %longURL%
	return %msg%
	
	ShortenURL_Shortened:
		Clipboard = %shortURL%
		SendInput, %shortURL%
		msg = Shortened %longURL% `r`n to %shortURL%
	return %msg%
}

UrlDownloadToVar(URL, ByRef Result, UserAgent = "", Proxy = "", ProxyBypass = "") {
    ; Requires Windows Vista, Windows XP, Windows 2000 Professional, Windows NT Workstation 4.0,
    ; Windows Me, Windows 98, or Windows 95.
    ; Requires Internet Explorer 3.0 or later.
    pFix:=a_isunicode ? "W" : "A"
    hModule := DllCall("LoadLibrary", "Str", "wininet.dll")

    AccessType := Proxy != "" ? 3 : 1
    ;INTERNET_OPEN_TYPE_PRECONFIG                    0   // use registry configuration
    ;INTERNET_OPEN_TYPE_DIRECT                       1   // direct to net
    ;INTERNET_OPEN_TYPE_PROXY                        3   // via named proxy
    ;INTERNET_OPEN_TYPE_PRECONFIG_WITH_NO_AUTOPROXY  4   // prevent using java/script/INS

    io := DllCall("wininet\InternetOpen" . pFix
    , "Str", UserAgent ;lpszAgent
    , "UInt", AccessType
    , "Str", Proxy
    , "Str", ProxyBypass
    , "UInt", 0) ;dwFlags

    iou := DllCall("wininet\InternetOpenUrl" . pFix
    , "UInt", io
    , "Str", url
    , "Str", "" ;lpszHeaders
    , "UInt", 0 ;dwHeadersLength
    , "UInt", 0x80000000 ;dwFlags: INTERNET_FLAG_RELOAD = 0x80000000 // retrieve the original item
    , "UInt", 0) ;dwContext

    If (ErrorLevel != 0 or iou = 0) {
        DllCall("FreeLibrary", "UInt", hModule)
        return 0
    }

    VarSetCapacity(buffer, 10240, 0)
    VarSetCapacity(BytesRead, 4, 0)

	Result := ""

    Loop
    {
        ;http://msdn.microsoft.com/library/en-us/wininet/wininet/internetreadfile.asp
        irf := DllCall("wininet\InternetReadFile", "UInt", iou, "UInt", &buffer, "UInt", 10240, "UInt", &BytesRead)
        VarSetCapacity(buffer, -1) ;to update the variable's internally-stored length

        BytesRead_ = 0 ; reset
        Loop, 4  ; Build the integer by adding up its bytes. (From ExtractInteger-function)
            BytesRead_ += *(&BytesRead + A_Index-1) << 8*(A_Index-1) ;Bytes read in this very DllCall

        ; To ensure all data is retrieved, an application must continue to call the
        ; InternetReadFile function until the function returns TRUE and the lpdwNumberOfBytesRead parameter equals zero.
        If (irf = 1 and BytesRead_ = 0)
            break
        Else ; append the buffer's contents
        {
            a_isunicode ? buffer:=StrGet(&buffer, "CP0")
            Result .= SubStr(buffer, 1, BytesRead_ * (a_isunicode ? 2 : 1))
        }

        /* optional: retrieve only a part of the file
        BytesReadTotal += BytesRead_
        If (BytesReadTotal >= 30000) ; only read the first x bytes
        break                      ; (will be a multiple of the buffer size, if the file is not smaller; trim if neccessary)
        */
    }

    DllCall("wininet\InternetCloseHandle",  "UInt", iou)
    DllCall("wininet\InternetCloseHandle",  "UInt", io)
    DllCall("FreeLibrary", "UInt", hModule)
}
