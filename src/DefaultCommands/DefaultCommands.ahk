;==========================================================
; Commands that will work without any additional things installed.
;==========================================================
AddCommand("ReloadAHKScript", "Reloads this AutoHotKey script")
ReloadAHKScript()
{
	Run, %A_ScriptFullPath%
}

AddCommand("ExitAHKScript", "Stops and closes this AutoHotKey script")
ExitAHKScript()
{
	ExitApp
}

AddCommand("PauseAHKScript", "Pauses this AutoHotKey script")
PauseAHKScript()
{
	Pause
}

AddCommand("PCShutdown", "Turns the computer off")
PCShutdown()
{
	Run, shutdown.exe -s -t 00
}

AddCommand("PCRestart", "Restarts the computer")
PCRestart()
{
	Run, shutdown.exe -r -t 00
}

AddCommand("ExploreMyComputer", "Explore My Computer")
ExploreMyComputer()
{
	Run, ::{20d04fe0-3aea-1069-a2d8-08002b30309d} ; Opens the "My Computer" folder.
}

AddCommand("ExploreRecycleBin", "Explore the Recycle Bin")
ExploreRecycleBin()
{
	Run, ::{645ff040-5081-101b-9f08-00aa002f954e} ; Opens the Recycle Bin.
}

AddCommand("ExploreMyDocuments", "Explore the user's My Documents folder.")
ExploreMyDocuments()
{
	Run, explore %A_MyDocuments%
}

AddCommand("ExploreDesktop", "Explore the user's Desktop folder.")
OpenDesktop()
{
	Run, explore %A_Desktop%
}

AddCommand("ExploreCDrive", "Explore C:\")
ExploreCDrive()
{
	Run, explore C:\
}

AddCommand("OpenClipboard", "Opens whatever file/folder/url path is in the Clipboard, if it is valid")
OpenClipboard()
{
	; Trim any whitespace, tabs, single-quotes and double-quotes off of the clipboard text before processing it.
	clipboardText := Trim(clipboard, " `t`'`"`"")

	; If the file/folder path exists, open it.
	IfExist, %clipboardText%
	{
		Run, %clipboardText%
	}
	else
	{
		; Determine if the clipboard contains a URL.
		urlRegex := "((https?|ftp|gopher|telnet|file|notes|ms-help):((//)|(\\\\))+[\w\d:#@%/;$()~_?\+-=\\\.&]*)"
		foundPosition := RegExMatch(clipboardText, urlRegex)

		; If the start of the clipboard is a URL, open it.
		if (foundPosition = 1)
			Run, %clipboardText%
		; Else this is not a file/folder path or a URL, so return error.
		else
		{
			return, "PATH DOES NOT EXIST:`r`n" . clipboardText
		}
	}
}

AddCommand("NewEmail", "Opens a new email in the default email program")
NewEmail()
{
	Run, mailto:
}

AddCommand("WindowClose", "Closes the currently active window")
WindowClose()
{	global _cpActiveWindowID
	WinClose, ahk_id %_cpActiveWindowID%
}

AddNamedCommand("WindowCloseAll", "CloseAllWindows", "Closes all open windows")
CloseAllWindows()
{
	MatchList = AutoHotKey Help, Any Other Window Names To Leave Open

	WinGet, ID, List, , , Program Manager
	Loop, %ID%
	{
		StringTrimRight, This_ID, ID%A_Index%, 0
		WinGetTitle, This_Title, ahk_id %This_ID%
		If This_Title in %MatchList%
			Continue
		WinClose, %This_Title%
	}
}

AddCommand("WindowMinimize", "Minimizes the currently active window")
WindowMinimize()
{	global _cpActiveWindowID
	WinMinimize, ahk_id %_cpActiveWindowID%
}

AddCommand("WindowMaximize", "Maximizes the currently active window")
WindowMaximize()
{	global _cpActiveWindowID
	WinMaximize, ahk_id %_cpActiveWindowID%
}

AddCommand("WindowAlwaysOnTop", "Sets the active window to always be on top of others")
WindowAlwaysOnTop()
{	global _cpActiveWindowID
	WinSet, AlwaysOnTop, On, ahk_id %_cpActiveWindowID%
}

AddCommand("WindowNotAlwaysOnTop", "Sets the active window to no longer always be on top of others")
WindowNotAlwaysOnTop()
{	global _cpActiveWindowID
	WinSet, AlwaysOnTop, Off, ahk_id %_cpActiveWindowID%
}

AddCommand("ContextMenu", "Simulates a right-click by using Shift+F10")
ContextMenu()
{
	SendInput, +{F10}	; Shift + F10 to simulate right mouse click
}

AddCommand("WebBrowser", "Opens the default internet browser and searches for any comma-separated queries")
WebBrowser(queries = "")
{
	; If queries were supplied, run them.
	if (queries != "")
		querySupplied := DoWebSearch(queries)
	; Otherwise the user didn't supply a query, so just open the browser up to Google.
	else
		Run, www.google.com
}

; Sends each of the supplied queries to the default web browser and returns if any queries were supplied or not (true/false).
DoWebSearch(queries = "")
{
	; Loop through each of the terms to search for.
	Loop, Parse, queries, CSV
	{
		query := A_LoopField

		; If this query is actually a URL, just go to the URL directly.
		if (RegExMatch(query, "^(https?://|www\.)|([a-zA-Z0-9\-\.]+\.[a-zA-Z]{2,3}(/\S*)?)$"))
		{
			address := query
		}
		; Else the query is not a URL, so Google it.
		else
		{
			; If the query starts with a "1", then do an "I'm feeling lucky" search.
			firstChar := SubStr(query, 1, 1)
			imFeelingLucky := false
			if (firstChar = 1)
			{
				StringTrimLeft, query, query, 1
				imFeelingLucky = true
			}

			; Construct the address and then go to.
			address = www.google.ca/search?q=%query%

			; If we should use the I'm Feeling Lucky, enable it.
			if (imFeelingLucky)
				address .= "&btnI=745"	; Adding &btnI=745 to the end of the URL uses Google's I'm Feeling Lucky.
		}

		; Open up the address in a new tab.
		Run, %address%
	}
}

AddCommand("MonitorOff", "Turns the monitor off")
MonitorOff()
{
	Sleep 500 ; if you use this with a hotkey, not sleeping will make it so your keyboard input wakes up the monitor immediately.
	SendMessage 0x112, 0xF170, 2,,Program Manager ; send the monitor into standby (off) mode.
}

AddCommand("MuteSpeakersToggle", "Mutes/Un-mutes the volume on your computer")
MuteSpeakersToggle()
{
	;SoundSet, +1, , mute	; Toggle volume mute on and off.
	SendInput, {Volume_Mute}
}

AddCommand("MediaNext", "Moves to the next track")
MediaNext()
{
	SendInput, {Media_Next}
}

AddCommand("MediaPrevious", "Moves to the previous track")
MediaPrevious()
{
	SendInput, {Media_Prev}
}

AddCommand("MediaPlayPause", "Plays/Pauses the current track")
MediaPlayPause()
{
	SendInput, {Media_Play_Pause}
}

AddCommand("MediaStop", "Stops the current track from playing")
MediaStop()
{
	SendInput, {Media_Stop}
}

AddCommand("ShowClipboardText", "Shows the text that is currently in the clipboard. Parameter specifies how many seconds before auto-closing it.", "3 seconds|3")
ShowClipboardText(displayLengthInSeconds = 0)
{
	MsgBox, , Clipboard Text (other content such as images are not shown here), %Clipboard%, %displayLengthInSeconds%
}

AddCommand("URLShortenAndPaste", "Replaces the long URL in the clipboard with a shortened one and pastes it")
URLShortenAndPaste()
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

AddCommand("PastePlainText", "Pastes the contents of the clipboard as plain text, with all special formatting removed")
PastePlainText()
{
	originalClipboardContents = %ClipBoardAll%

	ClipBoard = %ClipBoard%					; Convert to text
	Send ^v									; Paste the text

	Sleep 50								; Don't change clipboard until it is done pasting
	ClipBoard := OriginalClipboardContents	; Restore original clipboard contents
	originalClipboardContents =				; Free memory
}

;==========================================================
; Commands that require Outlook to be installed.
;==========================================================

AddCommand("Outlook", "Opens Outlook making sure it is maximized")
Outlook()
{
	outlookExecutablePath := GetOutlookExecutablePath()

	; Try finding the window using the process name first (rather than matching the window title).
	windowID := PutWindowInFocus("ahk_exe OUTLOOK.EXE", outlookExecutablePath . " /recycle", 2)

	; If we found a window using the process name, make sure it's the main Outlook window and not the Reminders or other window.
	if (windowID > 0)
	{
		; If this isn't the main Outlook window, reset the windowID so we can search for it by window title.
		WinGetTitle, windowTitle, A
		IfNotInString, windowTitle, "Outlook"
			windowID := 0
	}

	; If not found, try looking for Outlook 2013+.
	if (windowID < 1)
		windowID := PutWindowInFocus("- Outlook", outlookExecutablePath . " /recycle", 2)

	; If not found, try looking for Outlook 2010.
	if (windowID < 1)
		windowID := PutWindowInFocus("Microsoft Outlook", outlookExecutablePath . " /recycle", 2)

	; If not found, try looking for any version of Outlook.
	if (windowID < 1)
		windowID := PutWindowInFocus("Outlook", outlookExecutablePath . " /recycle", 2)

	; If we have a handle to the Outlook window, make sure it is maximized.
	if (windowID > 0)
	{
		; Get the active window's Title to ensure it has "Outlook" in the name so we don't maximize the Reminders or other windows.
		WinGetTitle, windowTitle, A
		IfNotInString, windowTitle, "Outlook"
			return

		; Maximize the window if it is not already maximized.
		WinGet, maximized, MinMax, ahk_id %windowID%
		if (maximized != 1)
		{
			WinMaximize, ahk_id %windowID%
		}
	}
}

GetOutlookExecutablePath()
{
	outlookExecutablePaths := [ "C:\Program Files\Microsoft Office\root\Office16\OUTLOOK.EXE"
		, "C:\Program Files\Microsoft Office\Office15\OUTLOOK.EXE"
		, "C:\Program Files\Microsoft Office\Office14\OUTLOOK.EXE"
		, "C:\Program Files\Microsoft Office\Office12\OUTLOOK.EXE"
		, "C:\Program Files\Microsoft Office\Office11\OUTLOOK.EXE"
		, "C:\Program Files\Microsoft Office\Office10\OUTLOOK.EXE" ]

	; Look for the executable in known locations, starting with the newest version.
	for index, outlookExecutablePath in outlookExecutablePaths
	{
		IfExist, %outlookExecutablePath%
			return %outlookExecutablePath%
	}

	; If we couldn't find it in known locations, look for it dynamically (future proofing a bit).
	Loop Files, %A_ProgramFiles%\Microsoft Office\*Outlook.exe, R
	{
		return %A_LoopFileFullPath%
	}
}

AddCommand("NewOutlookAppointment", "Creates a new Appointment in Outlook")
NewOutlookAppointment()
{
	outlookExecutablePath := GetOutlookExecutablePath()
	Run, "%outlookExecutablePath%" /recycle /c ipm.appointment
}

AddCommand("OutlookCalendar", "Opens Outlook to the calendar view")
OutlookCalendar()
{
	outlookExecutablePath := GetOutlookExecutablePath()
	Run, "%outlookExecutablePath%" /recycle /select outlook:calendar
}
