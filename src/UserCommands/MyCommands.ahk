; ===============================================
; Add your custom Commands to this file.
; If you want to break your commands up over multiple files, simply include a reference to them here.
;	e.g. #Include %A_ScriptDir%\UserCommands\WorkRelatedCommands.ahk
;	WorkRelatedCommands.ahk should be in the UserCommands directory along with this MyCommands.ahk file.
;
; After modifying this file (or any included files), run the `ReloadAHKScript` Command to apply the changes.
; ===============================================

; Example of including another script that contains Commands.
;#Include %A_ScriptDir%\UserCommands\WorkRelatedCommands.ahk

; Example of creating a command that does not take any parameters. Feel free to delete this.
AddCommand("DisplayLoggedInUser", "Displays the username of the logged in user.")
DisplayLoggedInUser()
{
	MsgBox, % "You are logged in as: " . A_UserName
}

; Example of creating a command that takes a parameter. Feel free to delete this.
AddCommand("DisplayMessage", "Displays a message box.", "These, are, preset, parameter, values", "Default parameter value")
DisplayMessage(message)
{
	MsgBox % "Parameter passed in was: " . message
}
