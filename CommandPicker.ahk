/*
IDEAS:
- Have listbox filter the results and get smaller as user types.
- Save config to .properties or .config file:
	- _cpShowSelectedCommandAfterWindowCloses - Duration
- Be able to pass in parameters, such as "winamp kings of leon" -> might need a parameters input box (that only shows up when a command that takes parameters is selected).
- Have the GUI optional. Instead can just press CapsLock to bring up tooltip that says "Enter Command", and then user types in the tooltip instead of popping the large GUI.
- Maybe just hide the GUI instead of actually closing it every time.
- Allow user to create new simple commands easily from the GUI and save them in their own file (open file/program, path, website).

*/

; Use the two following commands to debug a script.
;ListVars
;Pause

#SingleInstance force	; Make it so only one instance of this script can run at a time (and reload the script if another instance of it tries to run).
#NoEnv					; Avoid checking empty variables to see if they are environment variables (better performance).

;==========================================================
; Global Variables - prefix "cp" for Command Picker.
;==========================================================
_cpWindowName := "Choose a command to run"
_cpCommandList := ""					; Will hold the list of all available commands.
_cpCommandDelimiter := "|"				; The character used to separate each command in the _cpCommandList. This MUST be the pipe character in order to work with a ListBox/ComboBox/DropDownList/Tab.
_cpCommandDescriptionSeparator := "=>"	; The character or string used to separate the function name from the description of what the function does.
_cpCommandSelected := ""				; Will hold the command selected by the user.
_cpSearchedString := ""					; Will hold the actual string that the user entered.
_cpActiveWindowID := ""					; Will hold the ID of the Window that was Active when this picker was launched.

; Load the Command Picker Settings from the settings file.
_cpSettingsFileName := "CommandPicker.settings"
_cpWindowWidthInPixels := 700
_cpFontSize := 10
_cpNumberOfCommandsToShow := 20
_cpShowAHKScriptInSystemTray := true
_cpShowSelectedCommandAfterWindowCloses := true
CPLoadSettings()

;==========================================================
; Load Command Picker Settings From File.
;==========================================================
CPLoadSettings()
{
	; Include any global setting variables the we need.
	global _cpSettingsFileName, _cpWindowWidthInPixels, _cpNumberOfCommandsToShow, _cpShowAHKScriptInSystemTray, _cpShowSelectedCommandAfterWindowCloses
	
	; If the file exists, read in its contents and then delete it.
	If (FileExist(_cpSettingsFileName))
	{
		; Read in each line of the file.
		Loop, Read, %_cpSettingsFileName%
		{
			; Split the string at the = sign
			StringSplit, setting, A_LoopReadLine, =
			
			; If this is a valid setting line (e.g. setting=value)
			if (setting0 = 2)
			{
				; Get the setting variable's value
				_cp%setting1% = %setting2%
			}
		}
	}

	; Save the settings.
	CPSaveSettings()
	
	; Apply any applicable settings.
	ShowAHKScriptInSystemTray(_cpShowAHKScriptInSystemTray)
}

;==========================================================
; Save Command Picker Settings To File.
;==========================================================
CPSaveSettings()
{
	; Include any global setting variables the we need.
	global _cpSettingsFileName, _cpWindowWidthInPixels, _cpNumberOfCommandsToShow, _cpShowAHKScriptInSystemTray, _cpShowSelectedCommandAfterWindowCloses
	
	; Delete and recreate the settings file every time so that if new settings were added to code they will get written to the file.
	If (FileExist(_cpSettingsFileName))
	{
		FileDelete, %_cpSettingsFileName%
	}
	
	; Write the settings to the file (will be created automatically if needed)
	; Setting name in file should be the variable name, without the "_cp" prefix.
	FileAppend, WindowWidthInPixels=%_cpWindowWidthInPixels%`n, %_cpSettingsFileName%
	FileAppend, NumberOfCommandsToShow=%_cpNumberOfCommandsToShow%`n, %_cpSettingsFileName%
	FileAppend, ShowAHKScriptInSystemTray=%_cpShowAHKScriptInSystemTray%`n, %_cpSettingsFileName%
	FileAppend, ShowSelectedCommandAfterWindowCloses=%_cpShowSelectedCommandAfterWindowCloses%`n, %_cpSettingsFileName%
}

;==========================================================
; Inserts the scripts containing the commands (i.e. string + function) to run.
; The scripts we are including should add commands and their associated functions.
;
; Example:
;	AddCommand("SQL", "Launch SQL Management Studio")
;	SQL()
;	{
;		Run "C:\Program Files (x86)\Microsoft SQL Server\100\Tools\Binn\VSShell\Common7\IDE\Ssms.exe"
;		return false	; (optional) Return false to not display the command text after runing the command.
;	}
;==========================================================
#Include CommandScriptsToInclude.txt
CPSortCommands() ; Now that all of the Commands are loaded, sort them in the picker.

;==========================================================
; Hotkey to launch the Command Picker window.
;==========================================================
CapsLock::
	SetCapslockState, Off				; Turn CapsLock off after it was pressed
	LaunchCommandPicker()	
return

;==========================================================
; Launch the Command Picker window.
;==========================================================
LaunchCommandPicker()
{
	; Let this function know about the necessary global variables.
	global _cpWindowName, _cpActiveWindowID
	
	; If the Command Picker Window is not already open and in focus.
	if !WinActive(_cpWindowName)
	{
		_cpActiveWindowID := WinExist("A")	; Save the ID of the Window that was active when the picker was launched.
	}
	PutCommandPickerWindowInFocus(_cpWindowName)
}

;==========================================================
; Intercept the Up and Down arrows to move through the commands.
; The ~ symbol allows the Up/Down key press to still be processed in the active window as normal.
; The $ symbol prevents an infinite loop, since pressing Down sends the Down key press to another control.
;==========================================================
~$Up::
~$Down::

	; If the Command Picker Window is active.
	if WinActive(_cpWindowName)
	{
		; And if the Edit box has focus
		ControlGetFocus, control, _cpWindowName
		if (control = _cpSearchedString)
		{			
			; Move the selected command
			ControlSend, _cpCommandSelected, {Down}, _cpWindowName
			
			;~ if ErrorLevel   ; i.e. it's not blank or zero.
				;~ MsgBox, There was a problem sending input to the control
		}
	}
return
   
;~ ;==========================================================
;~ ; Create and show the Command Picker Window.
;~ ;==========================================================
;~ CreateCommandPickerWindow()
;~ {
	;~ ; Let this function know about the necessary global variables.
	;~ global _cpWindowName, _cpCommandSelected, _cpCommandList
	
	;~ ; Create the GUI
	;~ Gui, +AlwaysOnTop +Owner ToolWindow ; +Owner avoids a taskbar button ; ToolWindow makes border smaller and hides the min/maximize buttons.
	;~ Gui, font, S10	; S=Size
	
	;~ ; Add the controls to the GUI
	;~ Gui, Add, ComboBox, Sort Simple v_cpCommandSelected w400 r10, %_cpCommandList%	; w=width, r=rows, v_cpCommandSelected=Store selection in a "_cpCommandSelected" variable.
	;~ Gui, Add, Button, Hide default ym gButtonOK, OK 	; default makes this the default action when Enter is pressed ; ym defines a new GUI column
	;~ Gui, Add, Button, ym gButtonCancel, Cancel

	;~ ; Change between showing 1 row or 10 in the drop down.
	;~ ;GuiControl, r10, _cpCommandSelected
	;~ ;GuiControl, r1, _cpCommandSelected
	
	;~ ; Show the GUI, set focus to the input box, and wait for input.
	;~ Gui, Show, AutoSize Center, %_cpWindowName%
	;~ GuiControl, Focus, _cpCommandSelected
	;~ return  ; End of auto-execute section. The script is idle until the user does something.
	

	;~ ; The OK button was pressed, so process the input
	;~ ButtonOK:
	;~ OKPressed := true
	
	;~ ; Save the input from the user to each control's associated variable, but leave the window open incase we need to manipulate it.
	;~ Gui, Submit, NoHide
	
	;~ ; Loop through the list of commands (separated by the pipe character) and see if the entered command is in the list.
	;~ validCommandEntered := false
	;~ Loop, parse, _cpCommandList, |
	;~ {
		;~ if (_cpCommandSelected = A_LoopField)
		;~ {
			;~ validCommandEntered := true
			;~ Break
		;~ }
	;~ }
	
	;~ ; If the user didn't enter an exact match, grab the closest match (works because list is sorted alphabetically).
	;~ if (validCommandEntered = false)
	;~ {
		;~ Send {Down}{Enter}
		;~ Gui, Submit	; Save the input from the user to each control's associated variable.
	;~ }
	
	;~ ; If a valid match was not found
	;~ if (_cpCommandSelected = "")
	;~ {
		;~ ; Make the window transparent.
		;~ ;Gui, Color, FF0000
		;~ ;Gui +LastFound  ; Make the GUI window the last found window for use by the line below.
		;~ ;WinSet, TransColor, EEAA99
		
		;~ ; Make the window giant and red before closing it to signal that an invalid command was given.
		;~ Gui, Color, FF0000
		;~ Gui, Show, Maximize
		;~ sleep, 10	; Sleep for 10 milliseconds so that the red is seen.
		;~ relaunchCommandPicker := true
	;~ }
	
;~ ;MsgBox You chose command: "%_cpCommandSelected%".

	;~ GuiClose:		; The window was closed (by clicking X or through task manager).
	;~ ButtonCancel:	; The Cancel button was pressed.
	;~ GuiEscape:		; The Escape key was pressed.
	;~ Gui, Destroy	; Close the GUI, but leave the script running.
	
	;~ ; If we should relaunch this window
	;~ if (relaunchCommandPicker = true)
	;~ {
		;~ CreateCommandPickerWindow()
	;~ }
	;~ ; Else if the user pressed OK (and selected a valid command)
	;~ else if (OKPressed = true)
	;~ {
		;~ RunCommand(_cpCommandSelected)
	;~ }
	
	;~ return
;~ }

;==========================================================
; Create the Command Picker window if necessary and put it in focus.
;==========================================================
PutCommandPickerWindowInFocus(windowName)
{
	; Let this function know that all variables except the passed in parameters are global variables.
	global
	
	; If the window is already open
	if WinExist(windowName)
	{		
		; Put the window in focus, and give focus to the text box.
		WinActivate, %windowName%
		ControlFocus, _cpSearchedString, %windowName%
		
		if ErrorLevel   ; i.e. it's not blank or zero.
			MsgBox, Error putting the textbox in focus
	}
	; Else the window is not already open
	else
	{
		; Create the window	
		if (windowName = _cpWindowName)
		{
			CreateCommandPickerWindow()
		}

		; Make sure this window is in focus before sending commands
		WinWaitActive, %windowName%
		
		; If the window wasn't opened for some reason
		if Not WinExist(windowName)
		{
			; Display an error message that the window couldn't be opened
			MsgBox, There was a problem opening "%windowName%"
		
			; Exit, returning failure
			return false
		}
	}
}

;==========================================================
; Create and show the Command Picker Window.
;==========================================================
CreateCommandPickerWindow()
{
	; Let this function know about the necessary global variables.
	global _cpWindowName, _cpCommandList, _cpCommandDelimiter, _cpCommandSelected, _cpSearchedString, _cpNumberOfCommandsToShow, _cpWindowWidthInPixels, _cpFontSize, _cpShowAHKScriptInSystemTray, _cpShowSelectedCommandAfterWindowCloses
	
	; Define any static variables needed for the GUI.
	static commandListBoxContents := ""	; Will hold the commands currently being shown in the command list.

	; Create the GUI.
	Gui 1:Default
	Gui, +AlwaysOnTop +Owner +OwnDialogs ToolWindow ; +Owner avoids a taskbar button ; +OwnDialogs makes any windows launched by this one modal ; ToolWindow makes border smaller and hides the min/maximize buttons.
	Gui, font, S%_cpFontSize%	; S=Size

	; Add the controls to the GUI.
	Gui Add, Edit, w%_cpWindowWidthInPixels% h20 v_cpSearchedString gIncrementalSearch
	;~ Gui Add, UpDown, gUpDownClicked
	Gui Add, ListBox, Sort v_cpCommandSelected gCommandSubmittedByListBoxClick w%_cpWindowWidthInPixels% r%_cpNumberOfCommandsToShow% hscroll vscroll
	Gui Add, Button, gCommandSubmittedByButton Default, Run Command		; default makes this the default action when Enter is pressed.
	;~ Gui Add, Button, gShowSettingsWindow ym, Settings
	
	; Fill the ListBox with the commands.
	gosub, FillListBox
	
	; Create and attach the Menu Bar
	Menu, FileMenu, Add, &Close Window, MenuHandler
	Menu, FileMane, Add			; Separator
	Menu, FileMenu, Add, &Exit (stop script from running), MenuHandler
	Menu, SettingsMenu, Add, Show &Settings, MenuHandler
	Menu, MyMenuBar, Add, &File, :FileMenu
	Menu, MyMenuBar, Add, &Settings, :SettingsMenu
	Gui, Menu, MyMenuBar
	
	; Show the GUI, set focus to the input box, and wait for input.
	Gui, Show, AutoSize Center, %_cpWindowName%
	GuiControl, Focus, _cpSearchedString
	return  ; End of auto-execute section. The script is idle until the user does something.

	UpDownClicked:
		
	return

	MenuHandler:
		;~ MsgBox You selected %A_ThisMenuItem% from menu %A_ThisMenu%.

		; File menu commands.
		if (A_ThisMenu = "FileMenu")
		{
			if (A_ThisMenuItem = "&Close Window")
				goto, GuiClose
			else if (A_ThisMenuItem = "&Exit (stop script from running)")
				ExitApp
		}
		; Settings menu commands.
		else if (A_ThisMenu = "SettingsMenu")
		{
			; Close this window and show the Settings window. When the Settings window is closed this window will be reloaded to show any changes.
			Gui, 1:Destroy			; Close the GUI, but leave the script running.
			ShowSettingsWindow()	; Show the Settings window so the user can change settings if they want.
		}
	return

	IncrementalSearch:			; The user changed the text in the Edit box.
		Gui 1:Submit, NoHide		; Get the values from the GUI controls without closing the GUI.

		len := StrLen(_cpSearchedString)	; Get the length of the string the user entered.
		indexThatShouldBeSelected := 0		; Assume that there are no matches for the given user string.

		; Loop through each item in the ListBox to see if the typed text matches any of the items.
		Loop Parse, commandListBoxContents, %_cpCommandDelimiter%
		{
			StringLeft part, A_LoopField, len
			If (part = _cpSearchedString)
			{
				indexThatShouldBeSelected := A_Index
				break
			}
		}

		Tooltip %_cpSearchedString% (%indexThatShouldBeSelected%)
		SetTimer HideTooltip, 1000
		
		GuiControl Choose, _cpCommandSelected, %indexThatShouldBeSelected%
	return

HideTooltip:
   SetTimer HideTooltip, Off
   Tooltip
return


	GuiSize:	; The user resized the window.
	
	return


	CommandSubmittedByButton:	; The user submitted a selection using the Enter key or the Run Command button.
		Gui 1:Submit, NoHide		; Get the values from the GUI controls without closing the GUI.
	   
	   
		; If the selected command is invalid
		
		
	   gosub, CommandSubmitted
	return
	
	CommandSubmittedByListBoxClick:	; The user submitted a selection by clicking in the ListBox.
		Gui 1:Submit, NoHide			; Get the values from the GUI controls without closing the GUI.

		; Only allow double clicks to run a command.
		if (A_GuiEvent != "DoubleClick")
			return
		
		gosub, CommandSubmitted
	return
		
	CommandSubmitted:
		commandWasSubmitted := true
		
	GuiClose:			; The window was closed (by clicking X or through task manager).
	GuiEscape:			; The Escape key was pressed.
		Gui, 1:Destroy	; Close the GUI, but leave the script running.
		
		; If we should relaunch this window (i.e. the submitted command was not valid).
		if (relaunchCommandPicker = true)
		{
			CreateCommandPickerWindow()
		}
		; Else if the user submitted a command (and it was valid).
		else if (commandWasSubmitted = true)
		{
			RunCommand(_cpCommandSelected)
		}	
	return

	FillListBox:
		; Copy the _cpCommandList into commandListBoxContents, removing the delimiter from the start of the list of commands.
		;~ If (InStr(_cpCommandList, _cpCommandDelimiter) = 1)
		StringTrimLeft, commandListBoxContents, _cpCommandList, 1
		
		; Sort the list of commands alphabetically.
		Sort, commandListBoxContents, D%_cpCommandDelimiter%
		
		; Refresh the list of words in the ListBox.
		GuiControl, -Redraw, _cpCommandSelected		; To improve performance, don't redraw the list box until all items have been added.
		GuiControl, , _cpCommandSelected, %commandListBoxContents%
		GuiControl, +Redraw, _cpCommandSelected
	return
}

;==========================================================
; Run the given command.
;==========================================================
RunCommand(command)
{
	global _cpShowSelectedCommandAfterWindowCloses
	
	; Strip the user friendly message off the command to get the function name.
	commandFunction := GetCommandFunction(command)

	; If the function exists, call it, otherwise report an error.
	if IsFunc(commandFunction)
	{	
		; Call the command function.
		displayCommandText := %commandFunction%()
		
		if (_cpShowSelectedCommandAfterWindowCloses && displayCommandText != false)
		{
			; Append any text returned from the command to the command displayed on screen (display returned text on a new line)
			if (displayCommandText)
				command := command . "`r`n" . displayCommandText
			
			DisplayTextOnScreen(command , 2000)
		}
	}
	else
		MsgBox Function "%commandFunction%" does not exist.
}

;==========================================================
; Parse the given command to pull the Function Name from it.
;==========================================================
GetCommandFunction(command)
{
	; Let this function know about the necessary global variables.
	global _cpCommandDescriptionSeparator

	; Replace each separator with an accent.
	StringReplace, command, command, %_cpCommandDescriptionSeparator%, ``, All
	
	; Split the string at the accent symbol, and strip spaces and tabs off each element.
	StringSplit, commandArray, command,``, %A_Space%%A_Tab%
	
	; return the first element of the array, as that should be the function name.
	return %commandArray1%
}

;==========================================================
; Displays the Settings window to allow user to change settings.
;==========================================================
ShowSettingsWindow()
{
	; Let this function know about the necessary global variables.
	global _cpWindowName, _cpNumberOfCommandsToShow, _cpWindowWidthInPixels, _cpFontSize, _cpShowAHKScriptInSystemTray, _cpShowSelectedCommandAfterWindowCloses
	
	Gui 2:Default	; Specify that these controls are for window #2.
	
	; Create the GUI.
	Gui, +AlwaysOnTop +Owner ToolWindow ; +Owner avoids a taskbar button ; +OwnDialogs makes any windows launched by this one modal ; ToolWindow makes border smaller and hides the min/maximize buttons.

	; Add the controls to the GUI.
	Gui, Add, Checkbox, v_cpShowAHKScriptInSystemTray Checked%_cpShowAHKScriptInSystemTray%, Show AHK script in the system tray
	Gui, Add, Checkbox, v_cpShowSelectedCommandAfterWindowCloses Checked%_cpShowSelectedCommandAfterWindowCloses%, Show selected command after window closes
	
	Gui, Add, Text,, Number of commands to show:
	Gui, Add, Edit, x+5
	Gui, Add, UpDown, v_cpNumberOfCommandsToShow Range1-50, %_cpNumberOfCommandsToShow%
	
	Gui, Add, Text, xm, Font size:
	Gui, Add, Edit, x+5
	Gui, Add, UpDown, v_cpFontSize Range5-25, %_cpFontSize%
	
	Gui, Add, Text, xm, Window width (in pixels):
	Gui, Add, Edit, x+5
	Gui, Add, UpDown, v_cpWindowWidthInPixels Range100-2000, %_cpWindowWidthInPixels%
	
	Gui, Add, Button, gSettingsSaveButton xm, Save
	Gui, Add, Button, gSettingsCancelButton x+150, Cancel
				
	; Show the GUI, set focus to the input box, and wait for input.
	Gui, Show, AutoSize Center, %_cpWindowName% - Settings
	
	return  ; End of auto-execute section. The script is idle until the user does something.
	
		
	SettingsSaveButton:		; Settings Save button was clicked.
		Gui 2:Submit, NoHide	; Get the values from the GUI controls without closing the GUI.
		CPSaveSettings()	; Save the settings before loading them again.
	
	SettingsCancelButton:	; Settings Cancel button was clicked.
	2GuiClose:				; The window was closed (by clicking X or through task manager).
	2GuiEscape:				; The Escape key was pressed.
		CPLoadSettings()	; If user pressed Cancel the old settings will be loaded. If they pressed Save the saved settings will be loaded.
		Gui, 2:Destroy		; Close the GUI, but leave the script running.
		LaunchCommandPicker()	; Re-launch the Command Picker.
	return	
}

;==========================================================
; Displays the given text on the screen for a given duration.
;==========================================================
DisplayTextOnScreen(text, durationInMilliseconds)
{
	Gui 3:Default	; Specify that these controls are for window #3.
	
	; Create the transparent window to display the text
	CustomColor = 999999  ; Can be any RGB color (it will be made transparent below).
	Gui +LastFound +AlwaysOnTop -Caption +ToolWindow  ; +ToolWindow avoids a taskbar button and an alt-tab menu item.
	Gui, Color, %CustomColor%
	Gui, Font, s32 bold ; Set a large font size (32-point).
	Gui, Add, Text, cGreen, %text%
	; Make all pixels of this color transparent and make the text itself translucent (150):
	WinSet, TransColor, %CustomColor% 150
	Gui, Show, AutoSize Center NoActivate  ; NoActivate avoids deactivating the currently active window.
	
	; Set the window to close after the given duration.
	SetTimer, CloseWindow, %durationInMilliseconds%
	;~ SetTimer, FadeOutText, 200	; Update every 200ms.
	return

	FadeOutText:
		
	return

	CloseWindow:
		SetTimer, CloseWindow, Off		; Make sure the timer doesn't fire again.
		Gui, 3:Destroy					; Close the GUI, but leave the script running.
	return
}

;==========================================================
; Adds the given command to our global list of commands.
;==========================================================
AddCommand(functionName, descriptionOfWhatFunctionDoes = "")
{
	AddCommandWithName(functionName, functionName, descriptionOfWhatFunctionDoes)
}

AddCommandWithParameter(functionName, descriptionOfWhatFunctionDoes = "", parameterList = "")
{
	AddCommandWithNameAndParameter(functionName, functionName, descriptionOfWhatFunctionDoes, parameterList)
}

AddCommandWithNameAndParameter(commandName, functionName, descriptionOfWhatFunctionDoes = "", parameterList = "")
{
	AddCommandWithName(commandName, functionName, descriptionOfWhatFunctionDoes, true, parameterList)
}

AddCommandWithName(commandName, functionName, descriptionOfWhatFunctionDoes = "", takesParameter = false, parameterList = "")
{
	global _cpCommandList, _cpCommandDelimiter, _cpCommandDescriptionSeparator
	_cpCommandList := _cpCommandList . _cpCommandDelimiter . functionName . " " . _cpCommandDescriptionSeparator . " " . descriptionOfWhatFunctionDoes
}

;==========================================================
; Sort and number all of the commands in our global list, so they display nicely in the picker.
;==========================================================
CPSortCommands()
{
	
}

;==========================================================
; Shows or Hides the Tray Icon for this AHK Script.
;==========================================================
ShowAHKScriptInSystemTray(show)
{
	; If we should show the Tray Icon.
	if (show)
		menu, tray, Icon
	; Else hide the Tray Icon.
	else
		menu, tray, NoIcon
}