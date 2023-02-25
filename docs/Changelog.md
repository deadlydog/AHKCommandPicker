# Changelog

This page is a list of _notable_ changes made in each version.

## vNext

### App

Features:

- Updated file structure to separate User Commands from the built-in Default Commands to make updating to new versions easier in the future (BREAKING CHANGE).

Fixes:

- Fix issue where the wrong command is sometimes selected when typing quickly ([GitHub issue #3](https://github.com/deadlydog/AHKCommandPicker/issues/3)).

Breaking changes ([see the v1 to v2 migration guide](MigrateFromV1ToV2.md)):

- Removed the `CommandScriptsToInclude.ahk` file.
  If you had added lines to that file to include other scripts, you will need to move those include statements to the `MyCommands.ahk` file.
- Moved the `MyCommands.ahk` and `MyHotkeys.ahk` files to the `UserCommands` directory.
  If you had customized the `MyCommands.ahk` or `MyHotkeys.ahk` files, you will need to copy their contents into the new equivalent files in the `UserCommands` directory.
  If you had added lines to include other scripts, you will need to update the include statement's directory path from `Commands` to `UserCommands`.

### Default Commands

Features:

- Added support for Outlook 2016.
- Add commands for creating an Outlook appointment and opening the Outlook calendar.

Fixes:

- Make Outlook commands more resilient.

Breaking changes:

- Changed the Default Hotkey for moving a window with your mouse by grabbing it anywhere (not just the title bar) from `Alt`+`MouseDrag` to `LeftWin`+`MouseDrag`.

## v1.3.2 - May 4, 2016

Fixes:

- Changed file paths to use an absolute path (via `A_ScriptDir`) instead of a relative path to fix issues when the working directory is not the same as the directory that the AHKCommandPicker.ahk script is in.

## v1.3.1 - January 12, 2014

Features:

- Renamed General.ahk to DefaultCommands.ahk and GeneralHotKeys.ahk to DefaultHotkeys.ahk.
- Added new MyCommands.ahk and MyHotkeys.ahk files, and associated EditMyCommands and EditMyHotkeys commands, to help new users get started faster.

## v1.3.0 - November 24, 2013

Features:

- Added new setting to have Escape key kill all current Commands and reload script (i.e. panic kill).
  Escape key only has an effect if a command is currently running.
- Added Sleep timer to allow hotkeys and hotstrings to still be processed when in a long-running loop in a user's command.

## CodePlex to GitHub migration

This project was originally created in January 2012 using TFVC (Team Foundation Version Control) and hosted on CodePlex, which is now defunct.
The project was migrated to git and moved to GitHub in September 2017.

Unfortunately I did not keep a proper changelog for a long time, so for earlier versions and changes you will need to view the git commit history.
