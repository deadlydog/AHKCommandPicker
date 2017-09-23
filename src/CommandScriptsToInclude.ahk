;====================================================================
; Include our utility functions used by some of the Commands first.
;====================================================================
#Include %A_ScriptDir%\Commands\UtilityFunctions.ahk


;====================================================================
; Include the files with the Commands we want to include in the picker.
; You can put all of your commands in a single file, or break them into
; separate files (e.g General.ahk, Work.ahk, Personal.ahk, HomePC.ahk, etc.).
;====================================================================
#Include %A_ScriptDir%\Commands\DefaultCommands.ahk
#Include %A_ScriptDir%\Commands\MyCommands.ahk


;====================================================================
; Include any files containing HotKeys/HotStrings last, as any AddCommand 
; functions defined after a HotKey/HotString won't be loaded at startup,
; and hence, won't show up in the Command Picker list.
;====================================================================
#Include %A_ScriptDir%\Commands\DefaultHotkeys.ahk
#Include %A_ScriptDir%\Commands\MyHotkeys.ahk
