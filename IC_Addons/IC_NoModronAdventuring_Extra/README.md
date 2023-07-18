# No Modron Adventuring
## Description:
This is a slight modification of antilectual's [No Modron Adventuring](https://github.com/antilectual/IC_Addons/tree/main/IC_Addons/IC_NoModronAdventuring_Extra) addon.

Please see the original addon for instructions.

There are two additions:

## Wall Resetting

You should see a new checkbox called `Reset at Wall`. As the name implies - this will restart the adventure if you reach a wall. If this is off - it will not do that.

The script determines whether it's at a wall simply by how long you've remained on your highest zone. This time is determined by the edit box just below it (in milliseconds).

This does **NOT** supersede the original Reset Zone setting. If you reach the reset zone you've set then you will restart there instead of at your wall.

## Choose Specialisations

This checkbox will determine whether the script chooses specialisations or not. I found that once I had a modron with automation I didn't need it to do so any more - but I still needed the script to level champions because of a lack of familiars.