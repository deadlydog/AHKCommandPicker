# Best Practices

## Use multiple files to organize your commands

While you could dump all of your commands into the `UserCommands\MyCommands.ahk` file, that file may soon become large and unwieldy.
You may instead want to create new .ahk files in the `UserCommands` folder and `#Include` them from the `UserCommands\MyCommands.ahk` file.
For example, put commands you typically use at work in a `UserCommands\Work.ahk` file, and home ones in `UserCommands\Home.ahk`.
However you want to organize them is up to you, but new files should always be created in the `UserCommands` directory.

## Do not add Hotkeys int the Command files

One important thing to note is that whenever a `hotkey` (e.g. _^j::_) or `hotstring` (e.g. _::btw::by the way_) is encountered, any commands that may have been defined after it will not be processed and added to the AHK Command Picker's list of commands.
So it is important that all hotkeys and hotstrings be declared **AFTER** all commands.
**To do this, ensure that hotkeys and hotstrings are defined or `#Include`d in the `UserCommands\MyHotkeys.ahk` file.**

## Do not edit the Default Commands

Do not edit the `AhkCommandPicker.ahk` file or any files in the `DefaultCommands` directory, as they may be updated when new versions of AHK Command Picker are released, so you may run into conflicts (or lose your customizations) when updating these files.
Only edit the `UserCommands\MyCommands.ahk` and `UserCommands\MyHotkeys.ahk` files, as well as any other files you create in the `UserCommands` directory.

## Next Steps

That's it.
Congrats!
You've read all of the documentation! 🎉👏

Return to [the table of contents][DocumentationTableOfContents].

<!-- Links -->
[DocumentationTableOfContents]: DocumentationHomePage.md
