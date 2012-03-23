;==========================================================
; Create the window if necessary and put it in focus.
;
; windowName = Name of the window to put in focus.
; applicationPath = Path to the application to launch if the windowName window is not found.
; titleMatchMode = The title match mode to use when looking for the windowName window.
;					1 = Match the start of window's title.
;					2 = Match any part of the window's title.
;					3 = Match the window's title exactly.
;					New = Open a new instance of the application, ignoring currently running instances.
;==========================================================
PutWindowInFocus(windowName, applicationPath = "", titleMatchMode = "")
{
	; Store the current values for the global modes, since we will be overwriting them.
	previousTitleMatchMode := A_TitleMatchMode
	previousDetectHiddenWindowsMode := A_DetectHiddenWindows

	; Used to tell when we have succeeded and stop trying.
	windowActivated := false

	; If the user did not specify a specific match mode to use, try them all starting with the most specific ones.
	if (titleMatchMode = "")
	{
		SetTitleMatchMode, 3	; Start by trying to match the window's title exactly.
		gosub, PWIFTryActivateWindow
	
		if (!windowActivated)
		{
			SetTitleMatchMode, 1	; Next try to match the start of the window's title.
			gosub, PWIFTryActivateWindow
		}
		
		if (!windowActivated)
		{
			SetTitleMatchMode, 2	; Next try to match any part of the window's title.
			gosub, PWIFTryActivateWindow
		}
		
		if (!windowActivated)
		{
			DetectHiddenWindows, On		; Lastly try searching hidden windows as well.
			gosub, PWIFTryActivateWindow
		}
	}
	else
	{
		; If we do want to try and match against an existing window
		if (titleMatchMode != "New")
		{
			SetTitleMatchMode, %titleMatchMode%		; Try to activate the window using the specified match mode.
			gosub, PWIFTryActivateWindow
		}
	}
	
	; If the window is not already open
	if (!windowActivated)
	{	
		; If we were given a program to launch as a backup in case the wanted window wasn't found, then try and launch it.
		if (applicationPath != "")
		{
			; Create the window	
			Run %applicationPath%

			; Make sure this window is in focus before sending commands
			WinWaitActive, %windowName%
			
			; If the window wasn't opened for some reason
			IfWinNotExist
			{
				; Display an error message that the window couldn't be opened
				MsgBox, There was a problem opening "%windowName%"
			}
			; Else the program was launched and the window opened.
			else
			{
				WinShow
				windowActivated := true
			}
		}
	}
	
	; Restore the previous global modes that we might have changed.
	SetTitleMatchMode, %previousTitleMatchMode%
	DetectHiddenWindows, %previousDetectHiddenWindowsMode%
	
	; Return the handle of the window that was activated
	if (windowActivated)
	{
		return WinExist("A")
	}
	
	; Else the window was not activated, so return 0 (i.e. false).
	return 0
	
	; Tries to activate the window and exits the function if successful.
	PWIFTryActivateWindow:
		; If the window is already open
		IfWinExist, %windowName%
		{			
			; Put the window in focus.
			WinActivate
			WinShow
			
			; Record success
			windowActivated := true
		}
	return
}

