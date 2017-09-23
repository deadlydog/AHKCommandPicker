; ===============================================
; Add your custom Commands to this file.
; If you want to break your commands up over multiple files, simply include a reference to them here.
;	e.g. #Include MyWorkRelatedCommands.ahk	; MyWorkRelatedCommands.ahk should be in the Commands directory along with this MyCommands.ahk file.
; ===============================================

AddCommand("EditMyCommands", "Opens the MyCommands.ahk script for editing in the default editor, or notepad.")
EditMyCommands()
{
	filePath = %A_ScriptDir%\Commands\MyCommands.ahk
	Run, edit %filePath%,,UseErrorLevel
	if (%ErrorLevel% = ERROR)
		Run, "notepad" "%filePath%"
}

AddCommand("EditMyHotkeys", "Opens the MyHotkeys.ahk script for editing in the default editor, or notepad.")
EditMyHotkeys()
{
	filePath = %A_ScriptDir%\Commands\MyHotkeys.ahk
	Run, edit %filePath%,,UseErrorLevel
	if (%ErrorLevel% = ERROR)
		Run, "notepad" "%filePath%"
}
