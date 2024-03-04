# Potion Sustain Addon

This is an AddOn for Script Hub that will try to sustain your potions as best it can. It does this through two separate methods.

___


## Sustain Smalls

The first section of the AddOn will attempt to sustain Small Potions of Speed by occasionally buying Silver chests.

It defaults to always buying Gold chests until your small potion count falls below the Small Potion Threshold Minimum - at which point it will start buying Silver chests to restock. It will then continue buying Silvers until your small potion count goes back above the Small Potion Threshold Maximum - at which point it will go back to buying Golds.

To do this - the AddOn completely ignores the four Buy and Open settings in the `Briv Gem Farm` addon. It acts like they are all on. It will - however - continue to follow the `Maintain this many gems when buying chests.` setting.

___

## Automate Modron Potions

The second section gives the option to have the AddOn change the potions in your modron - allowing you to alternate between potion types automatically.

It runs on a similar process that Sustaining Smalls does. When a potion type falls below the minimum threshold it can no longer be used and the addon will switch to a different combination. When that same potion type goes back above the maximum threshold it will be available for use again.

The interface will tell you which Alternating combination it's currently using.

*Please be aware that it can only change the potions in the modron during offline stacking - so this will not work at all for purely online runs.*

### Sustain Brackets

The addon determines which combinations of potions to use based on your current modron `Reset Zone`.

For the time being it's extremely simplistic - and might not be good for everyone - but it's the best I can do for now. I may try more complicated alternatives at a later date.

*Note: Speeds below include the Modron node as well as Hew Maan's feat and the Potent Potions blessing.*

#### Mediums + Others.

z1175 (or z885 with Gem Hunter) can permanently sustain medium potions - if the script can buy Silvers occasionally to sustain smalls. (Which is why Sustain Smalls is not optional.)

| Alternatives | Uptime | Speed<br>No Shandie | Speed<br>Shandie |
|---|--:|--:|--:|
| Medium + Large | 40.09%+ | x10 | x10 |
| Medium + Huge | 5.02%+ | x10 | x10 |
| Medium + Small | 100% | 5.64x | x8.46 |

#### Smalls + Others.

z655 (or z475 with Gem Hunter) can permanently sustain small potions.

| Alternatives | Uptime | Speed<br>No Shandie | Speed<br>Shandie |
|---|--:|--:|--:|
| Small + Large | 23.27%+ | x7.25 | x10 |
| Small + Huge | 0.82%+ | x8.86 | x10 |
| Small + Medium | 58.17%+ | 5.64x | x8.46 |
| Small only | 100% | x2.58 | x3.87 |

#### Anything available.

Below z655 (or z475 with Gem Hunter) you can't permanently sustain any potion. Because of this it will use 1 potion at a time and alternate all 4 types.

| Alternatives | Uptime | Speed<br>No Shandie | Speed<br>Shandie |
|---|--:|--:|--:|
| Large | 0%+ | x4.64 | x6.96 |
| Huge | 0%+ | x5.67 | x8.51 |
| Medium | 0%+ | 3.61x | x5.41 |
| Small | 0%+ | x2.58 | x3.87 |

*All of this is of course assuming there aren't any bugs. Spoiler alert - there will be bugs.*