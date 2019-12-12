------------------------------------------------------
Fizzwidget Hunter's Helper
by Gazmik Fizzwidget
http://fizzwidget.com/huntershelper
gazmik@fizzwidget.com
------------------------------------------------------

Really, I'm not one to gallivant about the wilderness trying to make friends with beasts... at my size, it's a good way to get eaten! Besides, keeping a full stock of bits & bibbles for your critter can be terrible for your cash flow. But a Hunter friend of mine managed to convince me there'd be good money in outfitting such outdoorsy types, and before I knew it my workbench was cluttered with all sorts of animal-seeking, food-measuring, and pet-minding contraptions.

This gadget couldn't be any simpler to use: point it at a beast you see in the wild, and its zootropic neurowave scanner will analyze the critter's noggin and tell you what, if any, new tricks it can teach you.* Know what you're looking for, but not sure where to look? It'll help with that, too -- I've pre-programmed it with an extensive database on creature behavior (straight from [Petopia][], the best zoological resource on Azeroth), easily indexed by skill.

* Not recommended for use by elderly gnolls.

[Petopia]: http://petopia.brashendeavors.net
------------------------------------------------------

INSTALLATION: Put this folder and the accompanying GFW_HuntersHelperUI folder into your World Of Warcraft/Interface/AddOns folder and launch WoW.

USAGE: 
	- When you mouse over a beast in the world, the tooltip will show which abilities a Hunter could learn after taming it. (Or no additional info if the beast doesn't have any known abilities.)
	- If you're currently playing a hunter, the abilities will be colored according to whether you've already learned them: green for abilities you have yet to learn, and gray for those you already know. Hunter's Helper will notice when you learn new abilities and will automatically refresh its index whenever you open the Beast Training window. (If you already know a few abilities, you should open you Beast Training window the first time you play after installing Hunter's Helper.)
	- Need to know where to find new abilities for your pet? 
		- Type `/huntershelper` (or `/hh`) to show the Hunter's Helper UI and browse its database by ability or by zone. Various filters and a search feature are available, so it's quick to find a pet that has what you're looking for.
		- Visit the Hunter's Helper pane in the Interface Options window (or type `/hh button`) to enable the HH minimap button, which shows when you're in a zone that contains beasts you can tame to learn new abilities. (Mouse over it for details on them.)
		- Type `/hh find <ability> <rank>` for a quick search with results in the chat window.[/list]
	- The Hunter's Helper UI also serves as an improved replacement for the Beast Training window; its compact layout and flexible filters make finding an ability and rank much quicker... and it shows accurate training point costs for upgrading an ability to a higher rank. (Tip: this means you can also show the HH UI by "casting" Beast Training from your spellbook, action bar, or macro.)
	- Hunter's Helper also notifies you in chat if you tame (or cast Beast Lore on) a beast whose skillset isn't what was expected. HH's database of pet abilities comes from http://petopia.brashendeavors.net -- visit there to submit a correction.

CHAT COMMANDS:
	/huntershelper (or /hh) <command>
where <command> can be any of the following:
	help - Print this list.
	status - Check current settings.
	on|off|onlyhunter - enable/disable display of pet abilities in beast tooltips. (Or enable only for Hunter characters.)
	button | minimap - toggle display of the minimap button.
	find <ability> <rank> - Lists in the chat window which beasts have an ability and where they can be found. 

------------------------------------------------------
VERSION HISTORY

v. 2.4.3 - 2008/06/20
- Availability (color) of abilities in the top part of the HH window should now follow more sensibly from that of individual ranks.
- Uses a new, locale-independent way to keep track of spell names and icons -- should result in proper behavior and fewer errors on WoW locales other than English. (Localizers need no longer provide translated spell names. Pet family names are still required for providing fully correct functionality, though.)
- Thanks in part to the above, fixed an issue where Avoidance wouldn't show the proper icon.
- The menu of pet families is now alphabetically sorted for all languages.
- Includes minimal localization (enough for proper functionality, no translated UI) for European and Latin American Spanish.
- Includes new French localization by oXid FoX.
- Fixed layering of the minimap button relative to other frames.
- Compatible with Awbee's BeastTraining addon; if it's installed, it replaces the Beast Training window, and HH can be used for finding abilities but not for training them to your pet.
- Rebuilt pet skills database from http://petopia.brashendeavors.net as of 2008/06/20.

v. 2.4.2 - 2008/05/05
- Fixed an issue where the Filter (availability) menu wouldn't always work as expected.
- Fixed an issue where the pet family menu would sometimes fail to actually show the selected family.
- Fixed an issue where the HH UI could conflict with the Enchanting window, preventing it from being shown.
- Fixed an issue where a beast with multiple learnable abilities would be listed multiple times in the minimap button tooltip.
- Fixed some issues with positioning the minimap button.
- Fixed some issues related to HH's cache of known abilities becoming outdated.
- Fixed an error that would occur when using the `/hh reset` command. All saved data is cleared and options reset to default when the command is used.
- Dash now correctly shows as learnable by Raptors.
- Updated German localization by Ghanur of EU-Alexstrasza.
- Rebuilt pet skills database from http://petopia.brashendeavors.net as of 2008/05/05.
- KNOWN ISSUE: Classification of abilities by availability doesn't work as expected in some cases where availability of individual ranks is mixed (e.g. Growl 1 is tameable, Growl 2 is known by the hunter but not the pet, and Growl 3-8 are all well above the hunter's level).

v. 2.4 - 2008/03/25
- Hunter's Helper now has a GUI, bringing many new features:
	- You can now easily browse pet abilities and find out where to learn them. Choose an ability (and rank, if applicable) in the list and you'll see which beasts you can tame to learn it, sorted according to where they can be found (with the zones closest to your current location listed first).
	- You can also browse/search by zone to see all the beasts with learnable abilities in a given area. (Zones are sorted based on proximity to your current location; i.e. how many other zones you must pass through to reach them.) Choose a beast and you'll see which abilities can be learned by taming it.
	- In both modes, beasts and abilities show additional useful info when available: level, normal/rare/elite status, and diet for the former; required level, description, and training point cost for the latter.
	- Both modes also offer several ways to search or filter their data: by typing part of a zone, beast, or ability name; by beast family (e.g. Cat, Boar, Sporebat, etc.); or based on which abilities you already know (or can't yet learn).
	- Show the new Hunter's Helper panel by typing `/huntershelper` or `/hh`.
- The new Hunter's Helper UI also serves as an improved replacement for the Beast Training window:
	- Open it while you have a pet summoned and it'll automatically filter to show only those abilities learnable by that pet type.
	- The list can be futher filtered based on which abilities your pet already has, which it can be trained with, and which it's can't learn yet.
	- Choose an ability and the highest rank trainable to your pet will be automatically selected (and unlike the standard Beast Training window, choosing a different rank or ability doesn't require scrolling an extra-long list).
	- Displayed training point costs take into account the points refunded when training a higher rank of an ability your pet already knows, so it's easier to see which abilities/ranks you can afford.
	- Since the new UI replaces the Beast Training window, you can also show it by "casting" Beast Training from your spellbook or action bar.
- The new UI is separate from the main Hunter's Helper addon and is only loaded when it needs to be shown. (Don't like the new UI? Disable or delete the Hunter's Helper UI addon and HH will keep working as it did before.)
- There's also a new minimap button (off by default; type `/hh button` to show/hide it):
	- Click it to show the full pet/ability browsing UI.
	- If you're in a zone with beasts you can tame to learn new abilities, the button shows how many such beasts there are; mouse over it to see details in the tooltip.
- Configuration controls are moved into a pane in the new Interface Options panel provided by the default UI.
- Fixed an issue where taming or casting Beast Lore on a creature with learnable abilities would report that Hunter's Helper didn't know about them even if it did.
- Updated German localization by "Zara".
- Slash command feedback text is now localizable. (Translators should look at the top of localization.lua for new keys.)
- Rebuilt pet skills database from http://petopia.brashendeavors.net as of 2008/03/24.

v. 2.3.1 - 2007/12/01
- Fixed an issue (introduced in version 2.3) where an `/hh find` search returning results in more than three zones would fail to print the results.
- Rebuilt pet skills database from http://petopia.brashendeavors.net as of 2007/12/01.

v. 2.3 - 2007/11/13
- Updated TOC to indicate compatibility with WoW Patch 2.3.
- Rebuilt our pet skills database from the one at http://petopia.brashendeavors.net as of 2007/11/12.

v. 2.2 - 2007/09/25
- Updated TOC to indicate compatibility with WoW Patch 2.2.
- Lookup of beasts in nearby zones now accounts for Tempest Keep.
- Updated beast ability data based on a few corrections sent by users. Thanks!

v. 2.1.1 - 2007/07/20
- Fixed issues related to the new pet skills introduced in WoW Patch 2.1. (Including an error message upon opening the Beast Training window after learning Cobra Reflexes.)
- Added Traditional Chinese localization.
- Added support for the Ace [AddonLoader][] -- when that addon is present, Hunter's Helper will only load automatically for Hunter characters by default. (If you like seeing beasts' abilities in their tooltips when playing your other characters, you can change AddonLoader's setting to make Hunter's Helper load for non-hunters.)
[AddonLoader]: http://www.wowace.com/wiki/AddonLoader

v. 2.1 - 2007/05/22
- Updated TOC for WoW Patch 2.1.
- Fixed a bug with parsing of abilities shown in the Beast Lore tooltip. (This led to messages erroneously reporting unknown abilities, with descriptions like "expected Bite 6, found Bite (Rank 6)".)
- Added several new pets found in Blade's Edge Mountains.
- Updated French localization.

v. 2.0.2 - 2007/01/15
- Updated TOC to indicate compatibility with WoW Patch 2.0.5 and the Burning Crusade release.
- Added info on the new Gore skill (for Boars, Spiders and Ravagers) from patch 2.0.3.
- Added more info on Burning Crusade content (thanks to petopia.brashendeavors.net), including new ranks of existing pet skills that can be found on beasts in Outland.

v. 2.0.1 - 2006/12/20
- Added preliminary info on Burning Crusade content (from the closed beta, thanks to petopia.brashendeavors.net):
	- The new abilities for some of the new pet types: Dragonhawks (Fire Breath) and Warp Stalkers (Warp).
	- Data on which of the new pet types can learn which existing abilities.
	- Our zone database (used by`/hh find` command can now search for beasts closest to your current location) covers all of the new 5-man instances and most of the new raid zones.
- Also added info on new beasts and newly tameable beasts from WoW Patch 2.0.1:
	- The Serpent family is now tameable, and many serpents come with the Poison Spit ability.
	- Lightning Breath (Rank 1) finally exists in the game, thanks to the addition of a low-level Wind Serpent type outside the Wailing Caverns.
- Corrected a few existing listings.

v. 2.0 - 2006/12/05
- Updated for compatibility with WoW 2.0 (and the Burning Crusade Closed Beta).
- NOTE: Hunter's Helper works on the BC beta, but does not yet provide info on expansion content -- as such content is still very much subject to change.
	- No data on expansion beasts or new skills (yet). But running Hunter's Helper as you explore and tame new beasts will help us gather such data!
	- The ability of `/hh find` to search for beasts closest to your location should work for outdoor zones, but does not yet have a full list of expansion instances. Searching while in a new dungeon will search for beasts closest to your home city.

See http://www.fizzwidget.com/notes/huntershelper for older release notes.
