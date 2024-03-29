# Migrating from AHK Command Picker v1 to v2

There were some breaking changes made in v2, so if you are upgrading from v1 to v2, you will need to make the following changes.

## Script files location changed

In v1 all command scripts were placed in a `Commands` directory.
In v2 we have separated the built-in default commands from the user commands to make updating to new versions easier in the future.
The built-in default commands are now located in the `DefaultCommands` directory, and these should not be modified.
All user commands should now be placed in the `UserCommands` directory.

The `CommandScriptsToInclude.ahk` file was also removed in v2; instead those include statements should be moved to the `MyCommands.ahk` and `MyHotkeys.ahk` files.

To migrate your customizations from v1 to v2:

1. Copy the contents of your `Commands\MyCommands.ahk` file to the new `UserCommands\MyCommands.ahk` file.
1. Copy the contents of your `Commands\MyHotkeys.ahk` file to the new `UserCommands\MyHotkeys.ahk` file.
1. Copy any additional scripts you had in the `Commands` directory to the `UserCommands` directory.
1. In `UserCommands\MyCommands.ahk` remove the `EditMyCommands` and `EditMyHotkeys` commands (if they are present) that were brought over from the old `Commands\MyCommands.ahk` file.
   These commands are now defined directly in the application.
   If you do not remove these commands from your `MyCommands.ahk` file, you will get a "duplicate function definition" error when the script is reloaded.
1. If you had added `#Include` statements to the `CommandScriptsToInclude.ahk` file, you will need to move those include statement lines to:
   - `UserCommands\MyCommands.ahk`: For including scripts containing Commands.
   - `UserCommands\MyHotkeys.ahk`: For including scripts containing hotkeys and hotstrings.
1. If you were using the `#Include` command to reference other scripts, you will need to update the path of the included script to use the `UserCommands` directory instead of the `Commands` directory.
   So for every ahk script that is now in the `UserCommands` directory, you will want to find `\Commands\` and replace it with `\UserCommands\`.
   e.g.

   ```AutoHotkey
   #Include %A_ScriptDir%\Commands\WorkRelatedCommands.ahk
   ```

   Should be changed to:

   ```AutoHotkey
   #Include %A_ScriptDir%\UserCommands\WorkRelatedCommands.ahk
   ```
