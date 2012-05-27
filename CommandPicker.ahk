/*
IDEAS:
- Save config to .properties or .config file:
	- _cpShowSelectedCommandAfterWindowCloses - Duration

- Have the GUI optional. Instead can just press CapsLock to bring up tooltip that says "Enter Command", and then user types in the tooltip instead of popping the large GUI. Could still autocomplete the command and show it in the tooltip though.
- Maybe just hide the GUI instead of actually closing it every time; this would be good for tooltip mode too, since the tooltip could show the currently selected command from the window.
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
_cpParameterDelimiter := ","			; The character used to separate the parameter list from the command.
_cpCommandDescriptionSeparator := "=>"	; The character or string used to separate the function name from the description of what the function does.
_cpCommandSelected := ""				; Will hold the command selected by the user.
_cpSearchedString := ""					; Will hold the actual string that the user entered.
_cpActiveWindowID := ""					; Will hold the ID of the Window that was Active when this picker was launched.
_cpCommandArray := Object()				; Will hold the array of all Command objects.

; Specify the default Command Picker Settings, then load any existing settings from the settings file.
_cpSettingsFileName := "CommandPicker.settings"
_cpWindowWidthInPixels := 700
_cpFontSize := 10
_cpNumberOfCommandsToShow := 20
_cpShowAHKScriptInSystemTray := true
_cpShowSelectedCommandAfterWindowCloses := true
_cpCommandMatchMethod := "Type Ahead"
CPLoadSettings()

;==========================================================
; Load Command Picker Settings From File.
;==========================================================
CPLoadSettings()
{
	; Include any global setting variables the we need.
	global _cpSettingsFileName, _cpWindowWidthInPixels, _cpNumberOfCommandsToShow, _cpShowAHKScriptInSystemTray, _cpShowSelectedCommandAfterWindowCloses, _cpCommandMatchMethod
	
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
	CPShowAHKScriptInSystemTray(_cpShowAHKScriptInSystemTray)
}

;==========================================================
; Save Command Picker Settings To File.
;==========================================================
CPSaveSettings()
{
	; Include any global setting variables the we need.
	global _cpSettingsFileName, _cpWindowWidthInPixels, _cpNumberOfCommandsToShow, _cpShowAHKScriptInSystemTray, _cpShowSelectedCommandAfterWindowCloses, _cpCommandMatchMethod
	
	; Delete and recreate the settings file every time so that if new settings were added to code they will get written to the file.
	If (FileExist(_cpSettingsFileName))
	{
		FileDelete, %_cpSettingsFileName%
	}
	
	; Write the settings to the file (will be created automatically if needed)
	; Setting name in file should be the variable name, without the "_cp" prefix.
	FileAppend, WindowWidthInPixels=%_cpWindowWidthInPixels%`n, %_cpSettingsFileName%
	FileAppend, NumberOfCommandsToShow=%_cpNumberOfCommandsToShow%`n, %_cpSettingsFileName%
	FileAppend, CPShowAHKScriptInSystemTray=%_cpShowAHKScriptInSystemTray%`n, %_cpSettingsFileName%
	FileAppend, ShowSelectedCommandAfterWindowCloses=%_cpShowSelectedCommandAfterWindowCloses%`n, %_cpSettingsFileName%
	FileAppend, CommandMatchMethod=%_cpCommandMatchMethod%`n, %_cpSettingsFileName%
}

;==========================================================
; Add a Dummy command to use for debugging.
;==========================================================
AddCommand("DummyCommand", "A command that doesn't do anything, but can be useful for testing and debugging")
DummyCommand(parameters)
{
	; Example of how to loop through the parameters
	For index, value in parameters
		MsgBox % "Item " index " is '" value "'"
	
	return, "This is some text returned by the dummy command."
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

;==========================================================
; Hotkey to launch the Command Picker window.
;==========================================================
CapsLock::
	SetCapslockState, Off				; Turn CapsLock off after it was pressed
	CPLaunchCommandPicker()	
return

;==========================================================
; Launch the Command Picker window.
;==========================================================
CPLaunchCommandPicker()
{
	; Let this function know about the necessary global variables.
	global _cpWindowName, _cpActiveWindowID
	
	; If the Command Picker Window is not already open and in focus.
	if !WinActive(_cpWindowName)
	{
		_cpActiveWindowID := WinExist("A")	; Save the ID of the Window that was active when the picker was launched.
	}
	CPPutCommandPickerWindowInFocus()
}

;++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
; Only process the following hotkeys in this Command Picker window.
;++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#IfWinActive, Choose a command to run

;==========================================================
; Intercept the Up and Down arrows to move through the commands.
;==========================================================
Up::CPForwardKeyPressToListBox("Up")return
Down::CPForwardKeyPressToListBox("Down")return
PgUp::CPForwardKeyPressToListBox("PgUp")return
PgDn::CPForwardKeyPressToListBox("PgDn")return
^Home::CPForwardKeyPressToListBox("Home")return	; Ctrl+Home to jump to top of list.
^End::CPForwardKeyPressToListBox("End")return		; Ctrl+End to jump to bottom of list.

CPForwardKeyPressToListBox(key = "Down")
{
	global _cpWindowName
	
	; If the Command Picker window is active and the Edit box (i.e. search box) has focus.
	ControlGetFocus, control, %_cpWindowName%
	if (%control% = Edit1)
	{
		; Move the selected command to the previous/next command in the list.
		ControlSend, ListBox1, {%key%}, %_cpWindowName%
	}
}
;++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
; Return hotkeys back to being processed in all windows.
;++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#IfWinActive
   
;==========================================================
; Create the Command Picker window if necessary and put it in focus.
;==========================================================
CPPutCommandPickerWindowInFocus()
{
	; Let this function know that all variables except the passed in parameters are global variables.
	global _cpWindowName, _cpSearchedString
	
	; If the window is already open
	if WinExist(_cpWindowName)
	{		
		; Put the window in focus, and give focus to the text box.
		WinActivate, %_cpWindowName%
		ControlFocus, Edit1, %_cpWindowName%
	}
	; Else the window is not already open
	else
	{
		; Create the window	
		CPCreateCommandPickerWindow()

		; Make sure this window is in focus before sending commands
		WinWaitActive, %_cpWindowName%
		
		; If the window wasn't opened for some reason
		if Not WinExist(_cpWindowName)
		{
			; Display an error message that the window couldn't be opened
			MsgBox, There was a problem opening "%_cpWindowName%"
		
			; Exit, returning failure
			return false
		}
	}
}

;==========================================================
; Create and show the Command Picker Window.
;==========================================================
CPCreateCommandPickerWindow()
{
	; Let this function know about the necessary global variables.
	global _cpWindowName, _cpCommandList, _cpCommandDelimiter, _cpCommandSelected, _cpSearchedString, _cpNumberOfCommandsToShow, _cpWindowWidthInPixels, _cpFontSize, _cpShowAHKScriptInSystemTray, _cpShowSelectedCommandAfterWindowCloses, _cpParameterDelimiter, _cpCommandMatchMethod
	
	; Define any static variables needed for the GUI.
	static commandListBoxContents := ""	; Will hold the commands currently being shown in the command list.

	; Create the GUI.
	Gui 1:Default
	Gui, +AlwaysOnTop +Owner +OwnDialogs ToolWindow ; +Owner avoids a taskbar button ; +OwnDialogs makes any windows launched by this one modal ; ToolWindow makes border smaller and hides the min/maximize buttons.
	Gui, font, S%_cpFontSize%	; S=Size

	; Add the controls to the GUI.
	Gui Add, Edit, w%_cpWindowWidthInPixels% h20 v_cpSearchedString gSearchForCommand
	Gui Add, ListBox, Sort v_cpCommandSelected gCommandSubmittedByListBoxClick w%_cpWindowWidthInPixels% r%_cpNumberOfCommandsToShow% hscroll vscroll
	Gui Add, Button, gCommandSubmittedByButton Default, Run Command		; default makes this the default action when Enter is pressed.
	
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
	
	; Display a tooltip that we are waiting for a command to be entered.
	ToolTip, Enter a command
	
	return  ; End of auto-execute section. The script is idle until the user does something.

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
			CPShowSettingsWindow()	; Show the Settings window so the user can change settings if they want.
		}
	return
	
	SearchForCommand:
		Gui 1:Submit, NoHide		; Get the values from the GUI controls without closing the GUI.
	
		indexThatShouldBeSelected := 0		; Assume that there are no matches for the given user string.
		currentSelectionsText := ""			; The text of the selected command that will be run.
	
		; Get the user's search string, stripping off any parameters that may have been provided.
		searchedCommand := _cpSearchedString
		StringGetPos, firstCommaPosition, _cpSearchedString, `,
		if (firstCommaPosition >= 0)
		{
			searchedCommand := SubStr(_cpSearchedString, 1, firstCommaPosition)
		}

		; Do the search using whatever search method is specified in the settings.
		if (_cpCommandMatchMethod = "Incremental")
			gosub, IncrementalSearch
		else
			gosub, CamelCaseSearch
		
		
		; Select the command in the list, using the index if we have it (faster than using string).
		if (indexThatShouldBeSelected > 0 || currentSelectionsText = "")
			GuiControl Choose, _cpCommandSelected, %indexThatShouldBeSelected%
		else
			GuiControl Choose, _cpCommandSelected, %currentSelectionsText%
		
		; Display the currently selected command in the tooltip.
		Tooltip %_cpSearchedString% (%currentSelectionsText%)
		SetTimer, HideTooltip, 3000
	return

	IncrementalSearch:			; The user changed the text in the Edit box.
		searchedStringLength := StrLen(searchedCommand)	; Get the length of the string the user entered.

		; Loop through each item in the ListBox to see if the typed text matches any of the items.
		Loop Parse, commandListBoxContents, %_cpCommandDelimiter%
		{
			StringLeft part, A_LoopField, searchedStringLength
			If (part = searchedCommand)
			{
				indexThatShouldBeSelected := A_Index
				currentSelectionsText := A_LoopField
				break
			}
		}
	return
	
	CamelCaseSearch:
		matchingCommands := ""					; Will hold all of the commands that match the search string, so we know which ones to keep in the ListBox.
		lowestWordIndexMatchedAgainst = 9999	; Used to keep track of which command matched against the string in the least number of words (as we want to select that command by default).
		
		; Loop through each item in the ListBox to see if the typed text matches any of the items.
		Loop Parse, _cpCommandList, %_cpCommandDelimiter%
		{
			; Skip empty entries (somehow an empty one gets added after backspacing out the entire search string).
			if (A_LoopField = "")
				continue
			
			; Strip the Description off the command to get just the Command Name.
			commandName := CPGetCommandName(A_LoopField)
			
			; Break each camel-case word out of the Command Name by separating them with a space.
			; Regex Breakdown:	This will match against each word in Camel and Pascal case strings, while properly handling acrynoms.
			;	(^[a-z]+)								Match against any lower-case letters at the start of the command.
			;	([0-9]+)								Match against one or more consecutive numbers (anywhere in the string, including at the start).
			;	([A-Z]{1}[a-z]+)						Match against Title case words (one upper case followed by lower case letters).
			;	([A-Z]+(?=([A-Z][a-z])|($)|([0-9])))	Match against multiple consecutive upper-case letters, leaving the last upper case letter out the match if it is followed by lower case letters, and including it if it's followed by the end of the string or a number.
			words := RegExReplace(commandName, "((^[a-z]+)|([0-9]+)|([A-Z]{1}[a-z]+)|([A-Z]+(?=([A-Z][a-z])|($)|([0-9]))))", "$1 ")
			words := Trim(words)
			
			; Split the string into an array at each space.
			StringSplit, wordArray, words, %A_Space%
			
			; Throw the array of words into an object so that we can pass it into the function below (array can't be passed directly by itself).
			camelCaseWordsInCommandName := {}					; Create a new object to hold the array of words.
			camelCaseWordsInCommandName.Length := wordArray0	; Record how many words are in the array.
			camelCaseWordsInCommandName.Words := Object()		; Will hold the array of all words in the Command.
			Loop, %wordArray0%
			{
				camelCaseWordsInCommandName.Words[%a_index%] := wordArray%a_index%
			}
			
			; If this Command matches the search string, add it to our list of Commands to be displayed.
			lastWordIndexMatchedAgainst := CPCommandIsPossibleMatch(searchedCommand, camelCaseWordsInCommandName)
			if (lastWordIndexMatchedAgainst > 0)
			{
				; Add this command to the list of matching commands.
				matchingCommands .= _cpCommandDelimiter . A_LoopField
				
				; We want to select the command whose match is closest to the start of the string.
				if (lastWordIndexMatchedAgainst < lowestWordIndexMatchedAgainst)
				{
					; Record the LowestWordIndex to beat and the command that should be selected so far.
					lowestWordIndexMatchedAgainst := lastWordIndexMatchedAgainst
					currentSelectionsText := A_LoopField
				}
				; If these two commands match against the same word index, pick the one that is lowest alphabetically.
				else if(lastWordIndexMatchedAgainst = lowestWordIndexMatchedAgainst)
				{
					if (A_LoopField < currentSelectionsText)
					{
						currentSelectionsText := A_LoopField
					}
				}
			}
		}

		; If we have some matches, copy the matches into the ListBox contents (leaving the leading delimiter as a signal to overwrite the existing contents), otherwise leave a delimiter character to clear the list.
		if (matchingCommands != "")
			commandListBoxContents := matchingCommands
		else
			commandListBoxContents := _cpCommandDelimiter

		; Refresh the list of words in the ListBox.
		GuiControl, -Redraw, _cpCommandSelected		; To improve performance, don't redraw the list box until all items have been added.
		GuiControl, , _cpCommandSelected, %commandListBoxContents%
		GuiControl, +Redraw, _cpCommandSelected
	return

HideTooltip:
   SetTimer HideTooltip, Off
   Tooltip
return


	GuiSize:	; The user resized the window.
	
	return


	CommandSubmittedByButton:		; The user submitted a selection using the Enter key or the Run Command button.		
	   gosub, CommandSubmitted
	return
	
	CommandSubmittedByListBoxClick:	; The user submitted a selection by clicking in the ListBox.
		; Only allow double clicks to run a command.
		if (A_GuiEvent != "DoubleClick")
			return
		
		gosub, CommandSubmitted
	return
		
	CommandSubmitted:
		Gui 1:Submit, NoHide			; Get the values from the GUI controls without closing the GUI.	
		commandWasSubmitted := true		; Record that the user actually wants to run the selected command (e.g. not just exit).
		
	GuiClose:			; The window was closed (by clicking X or through task manager).
	GuiEscape:			; The Escape key was pressed.
		Gui, 1:Destroy	; Close the GUI, but leave the script running.
		gosub, HideTooltip	; Hide the tooltip that we were showing.
		
		; If the user submitted a command.
		if (commandWasSubmitted = true)
		{
			; If the user did not specify a valid command
			if (_cpCommandSelected = "")
			{
				MsgBox,, Invalid Selection, The specified text "%searchedCommand%" does not correspond to any commands.
			}
			; Else the command is valid, so execute it.
			else
			{
				; Strip the Description off the command to get just the Command Name.
				commandName := CPGetCommandName(_cpCommandSelected)			
				
				; Grab any parameters that were supplied (CSV) and store them in an array.
				parameters := [] ; creates initialy empty object (simple array).
				Loop, parse, _cpSearchedString, `,, %A_Space%
				{   
					; Skip the first element as it is the command name (or part of the command name).
					if (A_index > 1)
						parameters.Insert(A_LoopField)
				}
				
				; Run the command with the given parameters.
				CPRunCommand(commandName, parameters)
			}
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

; Returns whether the given searchString matches against the words in the Array or not.
CPCommandIsPossibleMatch(searchedCommand, camelCaseWordsInCommandName)
{	
	; Get the number of characters that will need to be checked.
	lengthOfUsersString := StrLen(searchedCommand)
	
	; Call recursive function to roll through each letter the user typed, checking to see if it's part of one of the command's words
	return CPLetterMatchesPartOfCurrentWordOrBeginningOfNextWord(searchedCommand, 1, lengthOfUsersString, camelCaseWordsInCommandName.Words, 1, camelCaseWordsInCommandName.Length, 1)
}

; Recursive function to see if the searchString characters sequentially match characters in the word array, where as long as the first character in the word
; was matched again, the searchString could then match against the next sequential characters in that word, or match against the start of the next word in the array.
CPLetterMatchesPartOfCurrentWordOrBeginningOfNextWord(searchString, searchCharacterIndex, searchStringLength, wordArray, wordIndex, numberOfWordsInArray, wordCharacterIndex)
{	
	; If all of the characters in the search string were matched, return true that this command is a possible match.
	if (searchCharacterIndex > searchStringLength)
	{
		; Return the index of the word that was last matched against.
		return %wordIndex%
	}
	
	; If we were asked to look against a word that doesn't exist, or past the last character in the word, just return false since we can't go any further on this path.
	if (wordIndex > numberOfWordsInArray || wordCharacterIndex > StrLen(wordArray%wordIndex%))
	{
		return 0
	}
	
	; Get the character at the specified character index
	character := SubStr(searchString, searchCharacterIndex, 1)
	
	; If the character matches in this word, then keep going down this path.
	if (character = SubStr(wordArray%wordIndex%, wordCharacterIndex, 1))
	{		
		; See if the next character matches the next character in the current word, or the start of the next word.
		match1 := CPLetterMatchesPartOfCurrentWordOrBeginningOfNextWord(searchString, searchCharacterIndex + 1, searchStringLength, wordArray, wordIndex, numberOfWordsInArray, wordCharacterIndex + 1)
		match2 := CPLetterMatchesPartOfCurrentWordOrBeginningOfNextWord(searchString, searchCharacterIndex + 1, searchStringLength, wordArray, wordIndex + 1, numberOfWordsInArray, 1)
		
		; If one or both of the paths returned a match.
		if (match1 > 0 || match2 > 0)
		{
			; Return the match with the lowest word index above zero.
			if (match1 > 0 && match2 > 0)
				return match1 < match2 ? match1 : match2	; Returns the Min out of match1 and match2.
			else
				return match1 < match2 ? match2 : match1	; Returns the Max out of match1 and match2, since one of them is zero.
		}
		; Else neither path found a match so return zero.
		else
			return 0
	}
	; Otherwise the character doesn't match the current word.
	else
	{
		; See if this character matches the start of the next word.
		return CPLetterMatchesPartOfCurrentWordOrBeginningOfNextWord(searchString, searchCharacterIndex, searchStringLength, wordArray, wordIndex + 1, numberOfWordsInArray, 1)
		;~ return false
	}
}

;==========================================================
; Run the given command.
;==========================================================
CPRunCommand(commandName, parameters)
{
	global _cpShowSelectedCommandAfterWindowCloses, _cpCommandArray
	static _cpListOfFunctionsCurrentlyRunning, _cpListOfFunctionsCurrentlyRunningDelimiter := "|"

	; If the Command to run doesn't exist, display error and exit.
	if (!_cpCommandArray[commandName])
	{
		MsgBox, Command "%commandName%" does not exist.
		return
	}

	; Get the Command's Function to call.
	commandFunction := _cpCommandArray[commandName].FunctionName

	; If the Function to call doesn't exist, display an error and exit.
	if (!IsFunc(commandFunction))
	{	
		MsgBox Function "%commandFunction%" does not exist.
		return
	}

	; If we are already running the given function then exit with an error message, as running the same function concurrently may crash the AHK script.
	Loop Parse, _cpListOfFunctionsCurrentlyRunning, %_cpListOfFunctionsCurrentlyRunningDelimiter%
	{
		; Skip empty entries (somehow an empty one gets added after backspacing out the entire search string).
		if (A_LoopField = commandFunction)
		{
			CPDisplayTextOnScreen("COMMAND NOT CALLED!", "'" . commandName . "' is currently running so it will not be called again.")
			return
		}
	}

	; Record that we are running this function.
	_cpListOfFunctionsCurrentlyRunning .= commandFunction . _cpListOfFunctionsCurrentlyRunningDelimiter

	; Call the Command's function, passing in any supplied parameters.
	displayCommandText := %commandFunction%(parameters)

	; Now that we are done running the function, remove it from our list of functions currently running.
	functionNameAndDelimeter := commandFunction . _cpListOfFunctionsCurrentlyRunningDelimiter
	StringReplace, _cpListOfFunctionsCurrentlyRunning, _cpListOfFunctionsCurrentlyRunning, %functionNameAndDelimeter%

	;~ ; Example of how to loop through the parameters
	;~ For index, value in parameters
		;~ MsgBox % "Item " index " is '" value "'"

	; If the setting to show which command was ran is enabled, and the command did not explicitly return telling us to not show the text, display the command text.
	if (_cpShowSelectedCommandAfterWindowCloses && displayCommandText != false)
	{
		; Get the command's text to show.
		command := _cpCommandArray[commandName].ToString()
		
		; Display the Command's text on the screen, as well as any text returned from the command (i.e. the displayCommandText).
		CPDisplayTextOnScreen(command, displayCommandText)
	}
}

;==========================================================
; Parse the given command to pull the Command Name from it.
;==========================================================
CPGetCommandName(command)
{
	; Let this function know about the necessary global variables.
	global _cpCommandDescriptionSeparator
	
	; Replace each Command-Description separator string with an accent symbol so that it is easy to split against (since we can only split against characters, not strings).
	StringReplace, command, command, %_cpCommandDescriptionSeparator%, ``, All
	
	; Split the string at the accent symbol, and strip spaces and tabs off each element.
	StringSplit, commandArray, command,``, %A_Space%%A_Tab%
	
	; return the first element of the array, as that should be the function name.
	return %commandArray1%
}

;==========================================================
; Displays the Settings window to allow user to change settings.
;==========================================================
CPShowSettingsWindow()
{
	; Let this function know about the necessary global variables.
	global _cpWindowName, _cpNumberOfCommandsToShow, _cpWindowWidthInPixels, _cpFontSize, _cpShowAHKScriptInSystemTray, _cpShowSelectedCommandAfterWindowCloses, _cpCommandMatchMethod
	
	; Define any static variables needed for the GUI.
	static commandMatchMethodDescription
	
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
	
	Gui, Add, Text, xm, Command search method:
	Gui, Add, DropDownList, x+5 v_cpCommandMatchMethod gCommandMatchMethodChanged Sort, Type Ahead|Incremental
	Gui, Add, Text, xm vcommandMatchMethodDescription w450 h45,
	
	Gui, Add, Button, gSettingsCancelButton xm, Cancel
	Gui, Add, Button, gSettingsSaveButton x+400, Save
	
	GuiControl, Choose, _cpCommandMatchMethod, %_cpCommandMatchMethod%
	gosub, CommandMatchMethodChanged	; Display the description of the currently selected Command Match Method.
	
	; Show the GUI, set focus to the input box, and wait for input.
	Gui, Show, AutoSize Center, %_cpWindowName% - Settings
	
	return  ; End of auto-execute section. The script is idle until the user does something.
	
	CommandMatchMethodChanged:
		Gui 2:Submit, NoHide	; Get the values from the GUI controls without closing the GUI.

		if (_cpCommandMatchMethod = "Type Ahead")	
			GuiControl, , static5, Type ahead mode will match against Camel/Pascal Casing of any part of the command name, and filter the list as you type.`nE.g. 'WebBro', 'WB', 'B', and 'Brow' would all match against a 'WebBrowser' command.
		else
			GuiControl, , static5, Incremental mode will only match against the start of the command name, and will not filter the list as you type.`nE.g. only 'WebBro' would match against a 'WebBrowser' command.
	return
		
	SettingsSaveButton:		; Settings Save button was clicked.
		Gui 2:Submit, NoHide	; Get the values from the GUI controls without closing the GUI.
		CPSaveSettings()	; Save the settings before loading them again.
	
	SettingsCancelButton:	; Settings Cancel button was clicked.
	2GuiClose:				; The window was closed (by clicking X or through task manager).
	2GuiEscape:				; The Escape key was pressed.
		CPLoadSettings()	; If user pressed Cancel the old settings will be loaded. If they pressed Save the saved settings will be loaded.
		Gui, 2:Destroy		; Close the GUI, but leave the script running.
		CPLaunchCommandPicker()	; Re-launch the Command Picker.
	return	
}

;==========================================================
; Displays the given text on the screen for a given duration.
;==========================================================
CPDisplayTextOnScreen(title, text = "")
{
	titleFontSize := 24
	textFontSize := 16
	
	; Shrink the margin so that the text goes up close to the edge of the window border.
	windowMargin := titleFontSize * 0.1
	
	Gui 3:Default	; Specify that these controls are for window #3.
	
	; Create the transparent window to display the text
	backgroundColor = DDDDDD  ; Can be any RGB color (it will be made transparent below).
	Gui +LastFound +AlwaysOnTop -Caption +ToolWindow +Border  ; +ToolWindow avoids a taskbar button and an alt-tab menu item.
	Gui, Margin, %windowMargin%, %windowMargin%
	Gui, Color, %backgroundColor%
	Gui, Font, s%titleFontSize% bold
	Gui, Add, Text,, %title%
	Gui, Font, s%textFontSize% norm
	if (text != "")
		Gui, Add, Text,, %text%
	WinSet, TransColor, FFFFFF 180	; Make all pixels of this color transparent (shouldn't be any with color FFFFFF) and make all other pixels semi-transparent.
	Gui, Show, AutoSize Center NoActivate  ; NoActivate avoids deactivating the currently active window.
	
	; Set the window to close after the given duration.
	SetTimer, CloseWindow, 2000
	;SetTimer, FadeOutText, 200	; Update every 200ms.
	return

	FadeOutText:
		
	return

	CloseWindow:
		SetTimer, CloseWindow, Off		; Make sure the timer doesn't fire again.
		Gui, 3:Destroy					; Close the GUI, but leave the script running.
	return
}


;~ CPDisplayTextOnScreen(title, text = "")
;~ {	
	;~ global _cpFontSize
	
	;~ ; Calculate the width and height that each character should take up.
	;~ charWidth := _cpFontSize
	;~ charHeight := _cpFontSize * 2.5
	;~ titleCharWidth := 7		; Not sure how to get the window title's font size, so take our best guess.

	;~ ; Loop through each line in the text to display and find the longest one.
	;~ numberOfCharactersInLongestLine := 0
	;~ StringSplit, lines, text, `n
	;~ Loop, %lines0%
	;~ {
		;~ StringLen, numberOfCharactersInLine, lines%A_Index%
		;~ if (numberOfCharactersInLine > numberOfCharactersInLongestLine)
			;~ numberOfCharactersInLongestLine := numberOfCharactersInLine
	;~ }

	;~ ; Calculate the width and height of the window to accomodate the text to display.
	;~ windowHeight := charHeight * lines0
	;~ windowWidth := charWidth * numberOfCharactersInLongestLine
	
	;~ ; The window title uses smaller font, so calculate how much width it will need and use it if necessary.
	;~ StringLen, numberOfCharactersInTitle, title
	;~ titleWidth := titleCharWidth * numberOfCharactersInTitle
	;~ if (titleWidth > windowWidth)
		;~ windowWidth := titleWidth

	;~ ; Make sure the window doens't expand wider than the monitor.
	;~ if (windowWidth > (A_ScreenWidth - 100))
		;~ windowWidth = (A_ScreenWidth - 100)
	
	
	;~ ; Display the text. We use a Progress window instead of the Splash Text Window so that we have more control over the appearance (font size, color, etc.).
	;~ Progress, zh0 fm%_cpFontSize% h%windowHeight% w%windowWidth% c00,, %text%, %title%
	;~ WinSet, Transparent, 200, %title%		; Make the window slightly transparent.

	;~ ; Set the window to close after the given duration.
	;~ SetTimer, CPDTOSCloseWindow2, 2000
	;~ return

	;~ CPDTOSCloseWindow2:
		;~ SetTimer, CPDTOSCloseWindow2, Off		; Make sure the timer doesn't fire again.
		;~ Progress, Off
	;~ return
;~ }


;~ CPDisplayTextOnScreen(title, text = "")
;~ {	
	;~ global _cpFontSize
	
	;~ ; Calculate the width and height that each character should take up.
	;~ charWidth := _cpFontSize
	;~ charHeight := _cpFontSize * 2.5

	;~ ; Loop through each line in the text to display and find the longest one.
	;~ StringLen, numberOfCharactersInLongestLine, title
	;~ StringSplit, lines, text, `n
	;~ Loop, %lines0%
	;~ {
		;~ StringLen, numberOfCharactersInLine, lines%A_Index%
		;~ if (numberOfCharactersInLine > numberOfCharactersInLongestLine)
			;~ numberOfCharactersInLongestLine := numberOfCharactersInLine
	;~ }

	;~ ; Calculate the width and height of the window to accomodate the text to display.
	;~ windowHeight := charHeight * (lines0 + 2)
	;~ windowWidth := charWidth * numberOfCharactersInLongestLine
	
	;~ ; Make sure the window doens't expand wider than the monitor.
	;~ if (windowWidth > (A_ScreenWidth - 100))
		;~ windowWidth = (A_ScreenWidth - 100)
	
	
	;~ ; Display the text. We use a Progress window instead of the Splash Text Window so that we have more control over the appearance (font size, color, etc.).
	;~ Progress, zh0 fm%_cpFontSize% h%windowHeight% w%windowWidth% c00 b1,, %title%`n`n%text%, %title%
	;~ WinSet, Transparent, 200, %title%		; Make the window slightly transparent.

	;~ ; Set the window to close after the given duration.
	;~ SetTimer, CPDTOSCloseWindow, 2000
	;~ return

	;~ CPDTOSCloseWindow:
		;~ SetTimer, CPDTOSCloseWindow, Off		; Make sure the timer doesn't fire again.
		;~ Progress, Off
	;~ return
;~ }



;==========================================================
; Adds the given command to our global list of commands.
;==========================================================
AddCommand(functionName, descriptionOfWhatFunctionDoes = "", parameterList = "")
{
	AddNamedCommand(functionName, functionName, descriptionOfWhatFunctionDoes, parameterList)
}

AddNamedCommand(commandName, functionName, descriptionOfWhatFunctionDoes = "", parameterList = "")
{
	global _cpCommandList, _cpCommandDelimiter, _cpCommandDescriptionSeparator, _cpCommandArray
	;~ _cpCommandList := _cpCommandList . _cpCommandDelimiter . functionName . " " . _cpCommandDescriptionSeparator . " " . descriptionOfWhatFunctionDoes
	
	; The Command Names should be unique, so make sure it is not already in the list
	if (_cpCommandArray[commandName])
	{
		MsgBox, The command '%commandName%' has already been added to the list of commands. Command names should be unique.
		return
	}
	
	; Create the command object and fill its properties.
	command := {}
	command.CommandName := commandName
	command.FunctionName := functionName
	command.Description := descriptionOfWhatFunctionDoes
	command.Parameters := parameterList
	command.ToString := Func("CPCommand_ToString")
	
	; Add the command into the Command Array
	_cpCommandArray[commandName] := command
	
	_cpCommandList := _cpCommandList . _cpCommandDelimiter . commandName . " " . _cpCommandDescriptionSeparator . " " . descriptionOfWhatFunctionDoes
}

; Defines the ToString() function for our Command objects.
CPCommand_ToString(this)
{	global _cpCommandDescriptionSeparator
	return this.CommandName . " " . _cpCommandDescriptionSeparator . " " . this.Description
}

;~ AddNamedCommand("FF", "FireFox", "Opens Firefox", "xnaparticles.com, dpsf.com, digg.com")
;~ FireFox(website = "")
;~ {
	
;~ }

;~ FF, dpsf.com

;==========================================================
; Shows or Hides the Tray Icon for this AHK Script.
;==========================================================
CPShowAHKScriptInSystemTray(show)
{
	; If we should show the Tray Icon.
	if (show)
		menu, tray, Icon
	; Else hide the Tray Icon.
	else
		menu, tray, NoIcon
}
