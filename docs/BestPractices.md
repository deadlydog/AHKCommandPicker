# Best Practices

- While you could dump all of your commands into the `UserCommands\MyCommands.ahk` file, that file may soon become large and unwieldy.
  You may instead want to create new .ahk files in the `UserCommands` folder and `#Include` them from the `UserCommands\MyCommands.ahk` file.
  For example, put commands you typically use at work in a `UserCommands\Work.ahk` file, and home ones in `UserCommands\Home.ahk`.
  However you want to organize them is up to you, but new files should always be created in the `UserCommands` directory.
- One important thing to note is that whenever a `hotkey` is encountered, any commands that may have been defined after it will not be processed and added to the AHK Command Picker's list of commands.
  So it is important that all hotkeys and hotstrings be declared **AFTER** all commands.
  **This is why it is crucial that hotkeys and hotstrings are defined or `#Include`d in the `MyHotkeys.ahk` file.**
- Do not edit the `AhkCommandPicker.ahk` file or any files in the `DefaultCommands` directory, as they may be updated when new versions of AHK Command Picker are released, so you may run into conflicts (or lose your customizations) when updating these files.
Only edit the `UserCommands\MyCommands.ahk` and `UserCommands\MyHotkeys.ahk` files, as well as any other files you create in the `UserCommands` directory.
