;==========================================================
; Create the window if necessary and put it in focus.
;==========================================================
PutWindowInFocus(windowName, applicationPath = "", titleMatchMode = "")
{
	; Store the current values for the global modes, since we will be overwriting them.
	previousTitleMatchMode = %A_TitleMatchMode%

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
			SetTitleMatchMode, 2	; Lastly try to match any part of the window's title.
			gosub, PWIFTryActivateWindow
		}
	}
	else
	{
		SetTitleMatchMode, %titleMatchMode%		; Try to activate the window using the specified match mode.
		gosub, PWIFTryActivateWindow
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




;~ ;==========================================================
;~ ; Create the window if necessary and put it in focus.
;~ ;==========================================================
;~ PutWindowInFocus(windowName, applicationPath = "", titleMatchMode = "")
;~ {
	;~ ; Store the current values for the global modes, since we will be overwriting them.
	;~ previousTitleMatchMode = %A_TitleMatchMode%
	;~ previousDetectHiddenWindowsMode = %A_DetectHiddenWindows%

	;~ ; We want to detect hidden windows.
	;~ DetectHiddenWindows, On

	;~ ; Used to tell when we have succeeded and stop trying.
	;~ windowActivated := false

	;~ ; If the user did not specify a specific match mode to use, try them all starting with the most specific ones.
	;~ if (titleMatchMode = "")
	;~ {
		;~ SetTitleMatchMode, 3	; Start by trying to match the window's title exactly.
		;~ gosub, PWIFTryActivateWindow
	
		;~ if (!windowActivated)
		;~ {
			;~ SetTitleMatchMode, 1	; Next try to match the start of the window's title.
			;~ gosub, PWIFTryActivateWindow
		;~ }
		
		;~ if (!windowActivated)
		;~ {
			;~ SetTitleMatchMode, 2	; Lastly try to match any part of the window's title.
			;~ gosub, PWIFTryActivateWindow
		;~ }
	;~ }
	;~ else
	;~ {
		;~ SetTitleMatchMode, %titleMatchMode%		; Try to activate the window using the specified match mode.
		;~ gosub, PWIFTryActivateWindow
	;~ }
	
	;~ ; If the window is not already open
	;~ if (!windowActivated)
	;~ {		
		;~ ; If we were given a program to launch as a backup, then try and launch it.
		;~ if (applicationPath != "")
		;~ {
			;~ ; Create the window	
			;~ Run %applicationPath%

			;~ ; Make sure this window is in focus before sending commands
			;~ WinWaitActive, %windowName%
			
			;~ ; If the window wasn't opened for some reason
			;~ IfWinNotExist, %windowName%
			;~ {
				;~ ; Display an error message that the window couldn't be opened
				;~ MsgBox, There was a problem opening "%windowName%"
			;~ }
			;~ ; Else the program was launched and the window opened.
			;~ else
			;~ {
				;~ WinShow, %windowName%
				;~ windowActivated := true
			;~ }
		;~ }
	;~ }
	
	;~ ; Restore the previous global modes that we might have changed.
	;~ SetTitleMatchMode, %previousTitleMatchMode%
	;~ DetectHiddenWindows, %previousDetectHiddenWindowsMode%
	
	;~ ; Return if the window was activated or not.
	;~ return windowActivated	
	
	;~ ; Tries to activate the window and exits the function if successful.
	;~ PWIFTryActivateWindow:
		;~ ; If the window is already open
		;~ IfWinExist, %windowName%
		;~ {			
			;~ ; Put the window in focus.
			;~ WinShow, %windowName%
			;~ WinActivate, , %windowName%
			
			;~ ; Record success
			;~ windowActivated := true
		;~ }
	;~ return
;~ }
