# Migrating from AHK Command Picker v1 to v2

There were some breaking changes made in v2, so if you are upgrading from v1 to v2, you will need to make the following changes.

## Script files location changed

In v1 all command scripts were placed in a `Commands` directory.
In v2 we have separated the built-in default commands from the user commands to make updating to new versions easier in the future.
The built-in default commands are now located in the `DefaultCommands` directory, and these should never be modified.
All user commands should now be placed in the `UserCommands` directory.

The `CommandScriptsToInclude.ahk` file was also removed in v2.

To migrate your v1 commands to v2:

1. Copy the contents of your `Commands\MyCommands.ahk` file to the new `UserCommands\MyCommands.ahk` file.
1. Copy the contents of your `Commands\MyHotkeys.ahk` file to the new `UserCommands\MyHotkeys.ahk` file.
1. Copy any additional scripts you had in the `Commands` directory to the `UserCommands` directory.
1. If you had added `#Include` statements to the `CommandScriptsToInclude.ahk` file, you will need to move those include statement lines to:
    - `UserCommands\MyCommands.ahk`: For including scripts containing Commands.
    - `UserCommands\MyHotkeys.ahk`: For including scripts containing hotkeys and hotstrings.
1. If you were using the `#Include` command to reference other scripts, you will need to update the path of the included script to use the `UserCommands` directory instead of the `Commands` directory.
   So for every ahk script that is now in the `UserCommands` directory, you will want to find `\Commands\` and replace it with `\UserCommands\`.
   e.g.

   ```AutoHotkey
   #Include %A_ScriptDir%\Commands\WorkRelatedCommands.ahk
   ```

   Will become:

   ```AutoHotkey
   #Include %A_ScriptDir%\UserCommands\WorkRelatedCommands.ahk
   ```
