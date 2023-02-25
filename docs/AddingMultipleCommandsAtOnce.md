# Add Multiple Commands At The Same Time

This is an alternative to [Using Preset Parameters][UsingCommandsWithParametersPage]

So even though you can have your commands show a preset list of parameters, you may instead want each command-parameter combination show up as its own command.
So essentially instead of getting this with using preset parameters:

![Using Preset Parameters][UsingPresetParametersImage]

You would prefer to have this instead:

![Using Many Commands][UsingManyCommandsImage]

Where each command-parameter combination shows up in the base list of commands; that is, the user does not have to type in some other command plus a comma to see the list of that command's preset parameters.

Maybe you don't like having to press the comma (`,`) key after typing the command name, or maybe you just prefer to see ALL of your options without hiding any of them as parameters.
Of course we could accomplish this by adding a command for each command-parameter combination one by one, like so:

```AutoHotkey
AddCommand("ExploreCDrive", "Explore C:\")
ExploreCDrive()
{
    Run, explore C:\
}

; ... Add a bunch more commands to open up other folders here ...

AddCommand("ExploreProgramFiles", "Explore Program Files")
ExploreProgramFiles()
{
    Run, explore "C:\Program Files"
}
```

But as you can see, even on this very basic and simple operation, there is a lot of very similar code and code duplication happening, and it would take a while to write all of it out.

To help alleviate this tedious repetition you can use the `AddCommands()` or `AddCommandsWithPrePostfix()` functions.
Here are their prototypes:

```AutoHotkey
AddCommands(functionName, descriptionOfWhatFunctionDoes = "", commandList = "")

AddCommandsWithPrePostfix(functionName, descriptionOfWhatFunctionDoes = "", commandList = "", prefix = "", postfix = "")
```

These both call the `AddNamedCommand()` function for each command in the commandList.
Each command in the list will call the given functionName, supplying the command's specific value as a parameter to the function.

- `commandList`: The commands to show up in the picker that will call the function, separated with a comma.
  Separate the command name that appears in the picker and the value to pass to the function with a pipe character (`|`).
  If no pipe character is provided, the given value will be both shown in the picker and passed to the function.
- `prefix`: The prefix to add to the beginning of all the command names in the commandList.
- `postfix`: The postfix to add to the end of all the command names in the commandList.

So to use the `AddCommands()` function to get the same type of look that you would get from manually adding each command individually you could do:

```AutoHotkey
; Add all of our preset parameters to the directories variable, which will actually be a comma-separated string list.
AddParameterToString(directories, "C Drive|C:\")
AddParameterToString(directories, "My Directory|C:\MyDir")
AddParameterToString(directories, "Other Directory|C:\Other")
AddParameterToString(directories, "C:\Some\Other\Directory")
AddParameterToString(directories, "Program Files|C:\Program Files")
AddCommands("ExploreDirectory", "Open directory", directories)
ExploreDirectory(directoriesToOpen = "")
{
    Loop, Parse, directoriesToOpen, CSV
    {
        directoryToOpen := A_LoopField
        Run, explore "%directoryToOpen%"
    }
}
```

Here we used the same technique as in the [Preset Parameters][UsingCommandsWithParametersPage] documentation to build a comma-separated list of directories to add.
We also used the exact same _ExploreDirectory()_ function.
The only thing different here is that we used the `AddCommands()` function, which will essentially loop through each command in the commandList (i.e. the _directories_ variable above) and call `AddCommand()` for you, passing in "ExploreDirectory" as the function to call and "Open directory" as the user-friendly description.

One more time, this is what the result might look like if we added many more directories and had some other commands defined:

![Using Many Commands][UsingManyCommandsImage]

Notice that you no longer need to type "ExploreDirectory," to see the list of directories to explore; they are listed along-side all of the other commands.
For example, you could now just type "C Drive" to open _C:\\_.

## Prepend Command Names

So that's nice, but what if you want to group all of these related commands that essentially do the same operation.
That's what the `AddCommandsWithPrePostfix()` function is for.
To prepend all of our "ExploreDirectory" commands with the letter "e", we could have used:

```AutoHotkey
AddCommandsWithPrePostfix("ExploreDirectory", "Open directory", directories, "e")
```

Here we specified that all of these commands should have a prefix of "e" (and we omitted the postfix parameter, which is essentially the same as saying don't add a postfix).
So in the GUI, this is what our list might now look like:

![Using many commands with prefix][UsingManyCommandsWithPrefixImage]

Note the "e" at the beginning of our commands that call _ExploreDirectory()_.

## Next Steps

Proceed to the [Tips and Tricks][TipsAndTricksPage] page, or return to [the table of contents][DocumentationTableOfContents].

<!-- Links -->
[DocumentationTableOfContents]: DocumentationHomePage.md
[TipsAndTricksPage]: TipsAndTricks.md
[UsingCommandsWithParametersPage]: UsingCommandsWithParameters.md
[UsingPresetParametersImage]: Images/UsingPresetParameters.png
[UsingManyCommandsImage]: Images/UsingManyCommands.png
[UsingManyCommandsWithPrefixImage]: Images/UsingManyCommandsWithPrefix.png
