* Do not edit the "AhkCommandPicker.ahk", "CommandScriptsToInclude.ahk", "Commands\DefaultCommands.ahk", and "Commands\DefaultHotkeys.ahk" files, as they may be updated when new versions of AHK Command Picker are released, so you may run into conflicts (or lose your customizations) when updating these files.

* While you could dump all of your commands into the "Commands\MyCommands.ahk" file, that file may soon become large and unwieldy. You will likely want to create some new .ahk files in the Commands folder and #Include the new files in the "MyCommands.ahk" file. Maybe try to keep them logically separated, such as putting commands you typically use at work in a "Commands\Work.ahk" file, and home ones in "Commands\Home.ahk".  However you want to organize them is up to you.

* One important thing to note is that whenever a hotkey is encountered, any commands that may have been defined after it will not be processed and added to the AHK Command Picker's list of commands.  So it is important that all hotkeys and hotstrings be declared AFTER ALL commands.  This is why it is crucial that hotkeys and hot-strings are defined from the MyHotkeys.ahk file.


