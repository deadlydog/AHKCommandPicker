! Tips And Tricks


!! How To Reference The Currently Active Window
If you try to reference the currently active window to perform a command on it (e.g. using WinActive("A")), you will instead get a reference to the AHK Command Picker window since it was the last one opened (in order for you to run the command).  Instead you need to use the _cpAciveWindowID global variable.  Here is an example of creating a command to use this global variable to close the currently active window:
{{
AddCommand("CloseWindow", "Closes the currently active window")
CloseWindow()
{   global _cpActiveWindowID
    WinClose, ahk_id %_cpActiveWindowID%
}
}}In this example you can see that the global variable "_cpActiveWindowID" contains the AHK ID of the window that was active before the AHK Command Picker window was opened.  Use this variable whenever you need to reference the last active window from a AHK Command Picker command.


!! How To Send A Virtual Escape Key Press Without Reloading The Script
If you have the "Allow the Escape key to kill all currently running commands" setting enabled, but need one of your commands to send an Escape key press to a window (e.g. SendInput, {Esc}), then use:
{{
_cpDisableEscapeKeyScriptReloadUntilAllCommandsComplete := true ; Prevent Escape key from reloading the script.
SendInput, {Esc} ; Send an Escape key press to the active window.
_cpDisableEscapeKeyScriptReloadUntilAllCommandsComplete := false ; Allow Escape key to reload the script again.
}}This will prevent the virtual Escape key press from reloading the script, and then will re-enable the Escape key press to kill currently running commands again.

If you just use *_cpDisableEscapeKeyScriptReloadUntilAllCommandsComplete := true*, but never set it back to false, it will automatically be set back to false once there are no longer any commands running. Keep in mind though, the Escape key will not be able to kill any running commands until this happens.


!! Reporting Errors Or Extra Information From A Command
After a command runs its name and description are displayed for a short period to give the user confirmation that the actions were indeed performed.  If a command returns some text, this text will also be displayed.

For example, if we wanted our ExploreDirectory command to tell us which directories it is opening, we could add the line "return %directories%" to the bottom of the ExploreDirectory() function, like so:
{{
ExploreDirectory(directoriesToOpen = "")
{
	Loop, Parse, directoriesToOpen, CSV
	{
		directoryToOpen := A_LoopField
		Run, explore "%directoryToOpen%"
	}
	return Opening %directoriesToOpen%
}
}}

!! Have AHK Command Picker Automatically Start When You Log Into Windows
If you do not require the AHKCommandPicker.ahk script to run as an admin (see below), it is fairly straight forward to have AHK Command PIcker (or any program) start when you log into Windows:

Open up the Windows Start Menu, navigate to the Startup folder within All Programs, right-click on it and choose Open All Users (or navigate to "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\StartUp").  Then simply paste a shortcut to AHK Command Picker's "AHKCommandPicker.ahk" file in this folder.  That's it; the script will now launch whenever any user logs into Windows.  If you only want the script to run when YOU log into Windows (no other users), then just choose Open instead of Open All Users when right-clicking on the Startup folder (or navigate to "C:\Users\<User Name>\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup").

!! Have AHK Command Picker Run As An Administrator
In order to launch the AHK Command Picker GUI when an application running as administrator has focus (such as the Control Panel or Windows Explorer / File Explorer, in Windows 8), either the [url:AutoHotkey executable will need to be signed|http://blog.danskingdom.com/get-autohotkey-to-interact-with-admin-windows-without-running-ahk-script-as-admin/] (preferred method), or the AHKCommandPicker.ahk script will also need to be running as an administrator.

You can check out [url:my blog post|http://blog.danskingdom.com/get-autohotkey-script-to-run-as-admin-at-startup/] to see how to have the script automatically run as an administrator at login.  If you want to run the script as an admin, but don't want it to automatically start when you log into Windows, you can simply right-click on the AHKCommandPicker.ahk file and choose Run As Admin.  However, it will likely be more convenient for you to create a shortcut to that file, place the shortcut somewhere easily accessible (such as on your desktop), and set the shortcut properties to always launch the script as an admin.  Part of [url:my other blog post|http://blog.danskingdom.com/autohotkey-cannot-interact-with-windows-8-windowsor-can-it/] contains similar instructions and a screenshot on how to do this.


