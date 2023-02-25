# Getting Started With AHK Command Picker

## How To Launch AHK Command Picker

To launch AHK Command Picker run the `AHKCommandPicker.ahk` script.

Once the AHKCommandPicker.ahk script is running, press the `Caps Lock` key to bring up the AHK Command Picker GUI.
From there just type the name of the command that you want to run, and hit enter to run it.

If you want to turn Caps Lock on, use `Shift` + `Caps Lock` to toggle it on and off.

## Adding New Commands

Open the `UserCommands\MyCommands.ahk` file for editing; this can be done quickly by using `Caps Lock` to open the AHK Command Picker and running the `EditMyCommands` command.
From here you can either write your custom commands directly in `MyCommands.ahk`, or create a new ahk file and `#Include` its path in `MyCommands.ahk`, or a mix of the two approaches.

A `Command` is simply a function pointer (i.e. delegate) and collection of parameters.
So when you run a command it simply calls a function that you've defined, and optionally passes parameters to that function.

There are 2 different (but similar) functions that may be used to add a command to the AHK Command Picker: `AddCommand()` and `AddNamedCommand()`.
Both of these functions have optional parameters.
Here are the function prototypes, and descriptions of each parameter:

```AutoHotkey
AddCommand(functionName, descriptionOfWhatFunctionDoes = "", parameterList = "", defaultParameterValue = "")

AddNamedCommand(commandName, functionName, descriptionOfWhatFunctionDoes = "", parameterList = "", defaultParameterValue = "")
```

- `commandName`: The name of the command to appear in the Command Picker.
- `functionName`: The function to call when this command is selected to run.
  Unless the `AddNamedCommand()` function is used, this will also be the name of the command that appears in the Command Picker.
- `descriptionOfWhatFunctionDoes`: A user-friendly message that will appear in the Command Picker telling what the command does.
- `parameterList`: A pre-set list of parameters to choose from in the Command Picker when this command is selected.
  Parameter values should be separated by a comma, and if you would like your parameter to show a different name in the GUI, separate the name from the value with a pipe character (`|`) (e.g. "Name1|Value1, Value2, Name3|Value3").
- `defaultParameterValue`: The parameter value that will be passed to the function when no other parameter is given.

For example, to create a command to explore the C drive, you could use:

```AutoHotkey
AddCommand("ExploreCDrive", "Explore C:\")
ExploreCDrive()
{
    Run, explore C:\
}
```

Here you can see the command specifies that the _ExploreCDrive_ function should be called when this command runs, and that the command's user-friendly description is "Explore C:\\".
Next it actually defines the _ExploreCDrive_ function and what it should do.

If we wanted to leave the function name as _ExploreCDrive_, but have it show up in the Command Picker as _Open C_, we would use the `AddNamedCommand()` function as follows:

```AutoHotkey
AddNamedCommand("Open C", "ExploreCDrive", "Explore C:\")
ExploreCDrive()
{
    Run, explore C:\
}
```

## Where To Create Hotkeys and Hotstrings

Both `hotkeys` (e.g. _^j::_) and `hotstrings` (e.g. _::btw::by the way_) should be added to (or referenced from) the `UserCommands\MyHotkeys.ahk` file.
The `MyHotkeys.ahk` file can be opened for editing by using `Caps Lock` to open the AHK Command Picker and running the `EditMyHotkeys` command.
From here you can either write your custom hotkeys and hotstrings directly in `MyHotkeys.ahk`, or create a new ahk file in the `UserCommands` directory and `#Include` it's path in `MyHotkeys.ahk`, or a mix of the two approaches.

This is an example of the code you would add to the `UserCommands\MyHotkeys.ahk` file to include the `UserCommands\WorkRelatedHotkeys.ahk` file:

```AutoHotkey
#Include %A_ScriptDir%\UserCommands\WorkRelatedHotkeys.ahk
```

**Any commands defined after a hotkey or hotstring will not show up in the AHK Command Picker**.
So if you add a hotkey or hotstring to the `MyCommands.ahk` file, then none of your custom commands will show up in the AHK Command Picker.
This is why it is vital that hotkeys and hotstrings are defined or `#Include`d in the `UserCommands\MyHotkeys.ahk` file, since `MyCommands.ahk` is included before `MyHotkeys.ahk`.

## How To Convert An Existing Hotkey Into a Command

Typically existing AHK scripts are bound to a hotkey so that you can quickly launch them using a keyboard shortcut.
For example, you might have the following hotkey to open up _C:\SomeFolder_ whenever the _Windows Key_ + _Z_ is pressed:

```AutoHotkey
#z::
    Run, explore C:\SomeFolder
return
```

To convert this into a command that will show up in the AHK Command Picker, you would change the code to something like:

```AutoHotkey
AddCommand("OpenSomeFolder", "Opens C:\SomeFolder in Windows Explorer")
OpenSomeFolder()
{
    Run, explore C:\SomeFolder
}
```

If you still wanted to have the hotkey, be sure you define it in the `UserCommands\MyHotkeys.ahk` file.
You could leave the code as-is, but it would be better practice to have it call the new function to avoid duplicate code.
So you could change it to:

```AutoHotkey
#z::
    OpenSomeFolder()
return
```

Typically your AHK scripts/hotkeys are probably more than one line long, but this shows the general concept.

## Additional Info

All of the out-of-the-box commands and hotkeys are provided in the `DefaultCommands\DefaultCommands.ahk` and `DefaultCommands\DefualtHotkeys.ahk` files respectively; feel free to look at them for examples, but do not edit them as they may be updated in future versions.

## Next Steps

Proceed to the [Using Commands With Parameters][UsingCommandsWithParametersPage] page.

<!-- Links -->
[UsingCommandsWithParametersPage]: UsingCommandsWithParameters.md
