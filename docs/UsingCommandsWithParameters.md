# Using Parameters With Your Commands

You may also configure your commands to take optional parameters.
To do this, simply define that your function takes in an optional string parameter.

For example, we could re-write the _ExploreCDrive_ Command and function to open any directory path that is passed in as a parameter like so:

```AutoHotkey
AddCommand("ExploreDirectory", "Opens the directory supplied in the parameters", "", "C:\")
ExploreDirectory(directoryToOpen = "")
{
    Run, explore "%directoryToOpen%"
}
```

Notice that after the `functionName` and `descriptionOfWhatFunctionDoes` parameters, we supply an empty string for the `parameterList` and "C:\" for the `defaultParameterValue`.
Technically both of these parameters are optional, but in this case we want to provide a default parameter value in case the user does not supply a parameter when selecting to run this Command; in this example if no parameters are supplied then "C:\" will be passed into the function and will be opened.

Because AHK Command Picker supports passing multiple parameters into a command, we would probably want to re-write our function to support opening each directory path that is passed in like so:

```AutoHotkey
AddCommand("ExploreDirectory", "Opens the directory supplied in the parameters", "", "C:\")
ExploreDirectory(directoriesToOpen = "")
{
    Loop, Parse, directoriesToOpen, CSV
    {
        directoryToOpen := A_LoopField
        Run, explore "%directoryToOpen%"
    }
}
```

Here we added a loop that will iterate over each directory path in the comma-separated value (CSV) list of directories that is passed in, and open each one up.

In addition to supporting multiple parameters, you may have preset parameters for your commands as well; this is what the `parameterList` parameter is used for, and allows preset parameters to show up in the AHK Command Picker GUI.
For example, to have "C:\" and "C:\MyDir" show up in the GUI when the user is entering parameter values, you could use:

```AutoHotkey
AddCommand("ExploreDirectory", "Opens the directory supplied in the parameters", "C:\,C:\MyDir", "C:\")
```

You can also give user-friendly names to the preset parameter values as well that will show up in the GUI instead of the actual value passed into the function; simply separate the `Name` from the `Value` with a pipe character (`|`).
For example, we could give user-friendly names to these preset parameters by using:

```AutoHotkey
AddCommand("ExploreDirectory", "Opens the directory supplied in the parameters", "C Drive|C:\,My Directory|C:\MyDir", "C:\")
```

If you want to have a long list of preset parameters, you may want to consider storing the list in a variable and passing that variable into the `AddCommand()` function, like so:

```AutoHotkey
directories = "C Drive|C:\,My Directory|C:\MyDir,Other Directory|C:\Other,C:\Some\Other\Directory,Program Files|C:\Program Files"
AddCommand("ExploreDirectory", "Opens the directory supplied in the parameters", directories, "C:\")
```

The `DefaultCommands\UtilityFunctions.ahk` file provided by AHK Command Picker (and included by default) provides a `AddParameterToString` function to help make building these long lists of parameters easier and more readable:

```AutoHotkey
// Add all of our preset parameters to the directories variable, which will actually be a comma-separated string list.
AddParameterToString(directories, "C Drive|C:\")
AddParameterToString(directories, "My Directory|C:\MyDir")
AddParameterToString(directories, "Other Directory|C:\Other")
AddParameterToString(directories, "C:\Some\Other\Directory")
AddParameterToString(directories, "Program Files|C:\Program Files")
AddCommand("ExploreDirectory", "Opens the directory supplied in the parameters", directories, "C:\")
```

Here is an example of what the GUI might look like if we had added many more directories:

![Using preset parameters][UsingPresetParametersImage]

## Passing Parameters Into The Selected Command From The GUI

When using the GUI to select a command to run, you can pass a parameter to the selected command to run by placing a comma (`,`) after the name of the command to run and then typing in the parameter value.
If any preset parameters have been defined for the command then they will show up in the GUI list.
You may pass multiple parameters into the command by using a comma-separated list; that is, every comma specifies that the following text is a new parameter value.

Going back to our _ExploreDirectory_ command we defined above, you could have it open the _C:\SomeDir_ directory by typing "ExploreDirectory, C:\SomeDir".
You could also have it open many directories by passing in a comma separated list, such as "ExploreDirectory, C:\SomeDirectory, C:\Some\Other\Directory", or if the command has a preset parameter with a user-friendly name, you can use that too.
From the example above, we could type, "ExploreDirectory, My Directory, C Drive, C:\Some\Other\Directory".

Note too that you do not have to type in the entire command and parameter name; only enough so that it gets selected in the list box.
So in the above example you might be able to simply type, "Ex, MyD, CD, C:\Some" to open all of those same directories.

## Next Steps

Proceed to the [Adding Multiple Commands At Once][AddingMultipleCommandsAtOncePage] page, or return to [the table of contents][DocumentationTableOfContents].

<!-- Links -->
[AddingMultipleCommandsAtOncePage]: AddingMultipleCommandsAtOnce.md
[DocumentationTableOfContents]: DocumentationHomePage.md
[UsingPresetParametersImage]: Images/UsingPresetParameters.png
