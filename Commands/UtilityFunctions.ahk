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
	;~ ; Check if we are already searching for the given Window Name, and if we are just exit, as looking for the 
	;~ ; same window name simultaneously may cause a deadlock and cause the AHK script to crash.
	;~ static PWIFWindowNamesBeingSearchedFor, PWIFDelimiter := "|"
	;~ Loop Parse, PWIFWindowNamesBeingSearchedFor, %PWIFDelimiter%
	;~ {
		;~ ; Skip empty entries (somehow an empty one gets added after backspacing out the entire search string).
		;~ if (A_LoopField = windowName)
		;~ {
			;~ MsgBox, Will not open '%windowName%' because already looking for '%A_LoopField%', so exiting.
			;~ return 0
		;~ }
	;~ }
;~ MsgBox, Before addition, %PWIFWindowNamesBeingSearchedFor%
	;~ PWIFWindowNamesBeingSearchedFor .= windowName . PWIFDelimiter
;~ MsgBox, After addition, %PWIFWindowNamesBeingSearchedFor%
	
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
		; If we do want to try and match against an existing window.
		if (titleMatchMode != "New")
		{
			SetTitleMatchMode, %titleMatchMode%		; Try to activate the window using the specified match mode.
			gosub, PWIFTryActivateWindow
		}
	}

	; If the window is not already open.
	if (!windowActivated)
	{	
		; If we were given a program to launch as a backup in case the wanted window wasn't found, then try and launch it.
		if (applicationPath != "")
		{
			; Create the window.
			Run %applicationPath%

			; Make sure this window is in focus before sending commands.
			WinWaitActive, %windowName%,, 30

			; If the window wasn't opened for some reason.
			IfWinNotExist, %windowName%
			{
				; Display an error message that the window couldn't be opened.
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
	
;~ MsgBox, Before removal, %PWIFWindowNamesBeingSearchedFor%
	;~ ; Now that we are about to exit, remove this Window Name from our list of Window Names being search for.
	;~ windowNameAndDelimeter := windowName . PWIFDelimiter
	;~ StringReplace, PWIFWindowNamesBeingSearchedFor, PWIFWindowNamesBeingSearchedFor, %windowNameAndDelimeter%
;~ MsgBox, After removal, %PWIFWindowNamesBeingSearchedFor%
	
	; Return the handle of the window that was activated.
	if (windowActivated)
	{
		return WinExist("A")
	}
	
	; Else the window was not activated, so return 0 (i.e. false).
	return 0
	
	; Tries to put the window in focus if it already exists.
	PWIFTryActivateWindow:
		; If the window is already open.
		IfWinExist, %windowName%
		{			
			; Put the window in focus.
			WinActivate
			WinShow
			
			; Record success.
			windowActivated := true
		}
	return
}

;==========================================================
; Returns true if the given targetItem is found in the itemList, false if not.
;
; itemList = a string containing a list of items, each separated by the itemDelimiter. This is passed ByRef in order to allow us to modify the string list.
;	NOTE: It is not possible to pass Clipboard, built-in variables, or environment variables to a function's ByRef parameter
; targetItem = the string that we are checking is in the list.
; itemDelimiter = the string or character separating each item in the itemList. If none is provided the _cpParameterDelimiter will be used (a comma by default).
; removeTargetItem = if true and the targetItem is found, it will be removed from the itemList (which is passed in by reference).
;==========================================================
StringListContains(ByRef itemList, targetItem, itemDelimiter = "", removeTargetItem = false)
{
	global _cpParameterDelimiter
	
	; If no delimiter was supplied, use the default parameter delimiter.
	if (itemDelimiter = "")
		itemDelimiter := _cpParameterDelimiter
	
	; Trim whitespace off of the target item
	targetItem := Trim(targetItem)
	
	; Loop through each item in the list and return true if the target is found in it.
	Loop, Parse, itemList, %itemDelimiter%
	{
		if (Trim(A_LoopField) = targetItem)
		{
			; Remove the item from the list if specified to do so.
			if (removeTargetItem)
			{
				; We don't know if this item is first, last, or the only item in the list, so try and remove the itemDelimiter with the item.
				; ErrorLevel will be set to 1 if the string to replace is not found.
				StringReplace, itemList, itemList, %A_LoopField% . %itemDelimiter%
				if (ErrorLevel = 1)
					StringReplace, itemList, itemList, %itemDelimiter% . %A_LoopField%
				if (ErrorLevel = 1)
					StringReplace, itemList, itemList, %A_LoopField%
			}
			return true
		}
	}

	; The item was not found in the list, so return false.
	return false
}

StringListContainsAndRemove(ByRef itemList, targetItem, itemDelimiter = "")
{
	return StringListContains(itemList, targetItem, itemDelimiter, true)
}

;==========================================================
; Returns true if the given targetItem is found in the itemList, false if not.
;
; itemList = an array containing a list of items.
; targetItem = the item that we are checking is in the list.
;==========================================================
ArrayContains(itemList, targetItem)
{
	global _cpParameterDelimiter
	
	; If no delimiter was supplied, use the default parameter delimiter.
	if (itemDelimiter = "")
		itemDelimiter := _cpParameterDelimiter
	
	; Trim whitespace off of the target item
	targetItem := Trim(targetItem)
	
	; Loop through each item in the list and return true if the target is found in it.
	For index, value in parameters
	{
		if (Trim(value) = targetItem)
			return true
	}

	; The item was not found in the list, so return false.
	return false
}