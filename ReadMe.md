# AHK Command Picker description [Number of GitHub downloads](https://img.shields.io/github/downloads/deadlydog/AHKCommandPicker/total)

An [AutoHotkey][AutoHotkeyWebsiteUrl] (AHK) script that allows you to easily call AHK functions and run other AHK scripts.
(Requires [AutoHotkey v1.1][AutoHotkeyDownloadPageUrl] to be installed).

Instead of having to remember what hotkey maps to each of your AHK scripts (as you could have hundreds), this displays a list of Commands in a light-weight GUI that allows you to quickly and easily run your scripts.
Simply type part of the command name and hit enter to run your script.
You can also provide parameters to your commands, allowing you to change the functionality of a command with a few keystrokes.

For more reasons to use this with your AHK scripts, see [Why Use AHK Command Picker][WhyUseAhkCommandPickerPage].

## 🚀 How to use AHK Command Picker

Start by [downloading the latest release][DownloadLatestReleaseUrl].
To launch AHK Command Picker run the `AHKCommandPicker.ahk` script.

Press the `Caps Lock` key to bring up the AHK Command Picker GUI.
From there, just type the name of the Command that you want to run and hit Enter to run it.

Note: You can still toggle Caps Lock on and off by pressing `Shift`+`Caps Lock`.

### ✍ Adding your own Commands, hotkeys, and hotstrings

AHK Command Picker comes with many Commands out of the box, but the real power comes from adding your own Commands, hotkeys, and hotstrings.

- `UserCommands\MyCommands.ahk`: Add your own Commands here.
- `UserCommands\MyHotkeys.ahk`: Add your own hotkeys and hotstrings here.

You can use AHK Command Picker to open these files for editing by running the `EditMyCommands` and `EditMyHotkeys` Commands.
After you have modified a file, run the `ReloadAHKScript` Command to apply your changes.

For more information, see [the documentation][DocumentationPage].

### Additional tidbits

You will likely want to [have AHKCommandPicker start automatically when you log into Windows][AutomaticallyStartAtLogin].

### Upgrading versions

If you are upgrading from v1 to v2, see [the migration guide][MigrateFromV1ToV2Page].

## 🖼 Screenshots

All commands:

![All Commands][AllCommandsImage]

Commands filtered as you type:

![Filtered Commands][FilteredCommandsImage]

## 🎦 Videos

Get started with AHK Command Picker in under 2 minutes:

[![AHK Command Picker in under 2 minutes video][AhkCommandPickerInUnder2MinutesYouTubeImageUrl]][AhkCommandPickerInUnder2MinutesYouTubeUrl]

Some out of the box functionality provided by AHK Command Picker:

[![Out of the box functionality video][OutOfTheBoxFunctionalityProvidedByAhkCommandPickerYouTubeImageUrl]][OutOfTheBoxFunctionalityProvidedByAhkCommandPickerYouTubeUrl]

Motivation for creating AHK Command Picker and some AHK problems it solves:

[![Motivation for creating AHK Command Picker video][MotivationForCreatingAhkCommandPickerYouTubeImageUrl]][MotivationForCreatingAhkCommandPickerYouTubeUrl]

## 💬 Quotes / Testimonials

> I've found that by not having to find and assign a specific hotkey (i.e. keyboard combination) to each of my scripts, I am more likely to automate many more of my tasks.
> Before I would worry about having to remember too many keyboard shortcuts and the overhead involved (remembering which shortcut launches what, accidentally triggering them, etc.), so I would only use AHK to automate the tasks that I did all of the time.
> Now with AHK Command Picker these problems are gone, so I automate everything; even the tasks that I might only do once a month.

> A great tool for any AHK user: the interface is intuitive, adding your own commands\hotkeys and interacting with other AHK programs is easy, and the source code is well written and modifiable.
> Most of all, Command picker does what it claims to do: make windows automation easy by removing the need to remember hotkeys.

## ➕ How to contribute

Issues and Pull Requests are welcome.
See [the Contributing page](docs/Contributing.md) for more details.

## 📃 Changelog

See what's changed in the application over time by viewing [the Changelog](docs/Changelog.md).

## 💳 Donate

Buy me a pastry 🍰 for providing this script open source and for free 🙂

[![paypal](https://www.paypalobjects.com/en_US/i/btn/btn_donateCC_LG.gif)](https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=D7PW6YBWNDLXW)

<!-- Links -->
[AutoHotkeyWebsiteUrl]: https://www.autohotkey.com
[AutoHotkeyDownloadPageUrl]: https://www.autohotkey.com/download/

[AhkCommandPickerInUnder2MinutesYouTubeUrl]: https://www.youtube.com/watch?v=gevnQAwYLAg,type=youtube
[AhkCommandPickerInUnder2MinutesYouTubeImageUrl]: https://img.youtube.com/vi/gevnQAwYLAg/0.jpg

[OutOfTheBoxFunctionalityProvidedByAhkCommandPickerYouTubeUrl]: https://www.youtube.com/watch?v=kr5nBVOXVkE,type=youtube
[OutOfTheBoxFunctionalityProvidedByAhkCommandPickerYouTubeImageUrl]: https://img.youtube.com/vi/kr5nBVOXVkE/0.jpg

[MotivationForCreatingAhkCommandPickerYouTubeUrl]: https://www.youtube.com/watch?v=E0LnMtWVVuA,type=youtube
[MotivationForCreatingAhkCommandPickerYouTubeImageUrl]: https://img.youtube.com/vi/E0LnMtWVVuA/0.jpg

[DownloadLatestReleaseUrl]: https://github.com/deadlydog/AHKCommandPicker/releases

[WhyUseAhkCommandPickerPage]: docs/WhyUseAhkCommandPicker.md
[DocumentationPage]: docs/DocumentationHomePage.md
[AutomaticallyStartAtLogin]: docs/TipsAndTricks.md#have-ahk-command-picker-automatically-start-when-you-log-into-windows
[MigrateFromV1ToV2Page]: docs/MigrateFromV1ToV2.md

[AllCommandsImage]: docs/Images/AHKCommandPicker-AllCommands.png
[FilteredCommandsImage]: docs/Images/AHKCommandPicker-FilteredCommands.png
