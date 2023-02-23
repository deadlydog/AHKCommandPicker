# Changelog

This page is a list of _notable_ changes made in each version.

## vNext

Features:

- Updated file structure to make updating to new versions easier down the road.
- Added support for Outlook 2016.
- Add commands for creating an Outlook appointment and opening the Outlook calendar.

Fixes:

- Fix issue where the wrong command is sometimes selected when typing quickly ([GitHub issue #3](https://github.com/deadlydog/AHKCommandPicker/issues/3)).
- Make Outlook commands more resilient.

Breaking changes:

- Removed the `CommandScriptsToInclude.ahk` file.
  If you had added lines to that file to include other scripts, you will need to move those include statements to the `MyCommands.ahk` file.
- Changed Default Hotkey for moving a window from Alt+MouseDrag to LeftWin+MouseDrag.

## v1.3.2 - May 4, 2016

Fixes:

- Changed file paths to use an absolute path (via `A_ScriptDir`) instead of a relative path to fix issues when the working directory is not the same as the directory that the AHKCommandPicker.ahk script is in.

## v1.3.1 - January 12, 2014

Features:

- Renamed General.ahk to DefaultCommands.ahk and GeneralHotKeys.ahk to DefaultHotkeys.ahk.
- Added new MyCommands.ahk and MyHotkeys.ahk files, and associated EditMyCommands and EditMyHotkeys commands, to help new users get started faster.

## CodePlex to GitHub migration

This project was originally created in January 2012 using TFVC (Team Foundation Version Control) and hosted on CodePlex, which is now defunct.
The project was migrated to git and moved to GitHub in September 2017.

Unfortunately I did not keep a proper changelog for a long time, so for earlier versions and changes you will need to view the git commit history.
