# Potion Sustain

## Description:

An add on that will try to sustain small potions by buying silvers when it needs to.

It does this by buying Silver chests when your Small Potion of Speed count is less than a threshold. Otherwise it will buy golds.

### Important Note

This addon completely **IGNORES** both the `Buy silver chests?` and `Buy gold chests?` settings in the `Briv Gem Farm` addon. It treats them as if they were both on regardless.

It will - however - continue recognising both of the `Open type chests?` settings as well as the `Maintain this many gems when buying chests.` setting.

### Also Important Note

This addon has been utterly Frankenstein'd together and I am not a professional coder by any stretch of the imagination. This *will* have bugs.

___

## GUI Elements

### Save Settings

This saves the value of the `Small Potion Threshold` box to a file so that the script will remember it next time it loads.

### Status

This will tell you how the script is doing. If it says `Running.` - that's good. Anything else is not - and should be self explanatory.

### Small Potion Theshold

This is the amount of Small Potions of Speed that the script will try to maintain. If your current amount is *less than* this threshold - it will buy Silvers next time it offline stacks. If your current amount is *greater than or equal to* the threshold - it will buy Golds instead.

### Small Potion Count

This is the amount of Small Potions of Speed that you currently have. I hope.