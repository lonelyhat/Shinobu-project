-- This information tells other players more about the mod
name = "Shinobu Oshino"
description = "This mod adds character Shinobu Oshino to the game. She is trapped in this world accidentally and lost almost all her memory. Can you help her recall?"
author = "Nemo2000119"
version = "1.6.4 beta"
-- This is the URL name of the mod's thread on the forum; the part after the index.php? and before the first & in the URL
-- Example:
-- http://forums.kleientertainment.com/index.php?/files/file/202-sample-mods/
-- becomes
-- /files/file/202-sample-mods/
forumthread = ""

-- This lets other players know if your mod is out of date, update it to match the current version in the game
api_version = 6
priority = -1
dont_starve_compatible = true
reign_of_giants_compatible = true
shipwrecked_compatible = true


icon_atlas = "modicon.xml"
icon = "modicon.tex"

--1.4.0
configuration_options =
{
	{
        name = "Language",
        label = "Language",
        options =   {
                        {description = "English", data = false},
                        {description = "Chinese", data = true},
                    },
        default = false,
    },
    {
        name = "World",
        label = "DLC",
		hover = "Which DLC world will you born in?",
        options =   {
                        {description = "ROG", data = 1},
                        {description = "SW", data = 2},
						{description = "Hamlet!", data = 3},
                    },
        default = 1,
    },
	{
        name = "lucky",
        label = "Luck",
		hover = "The highest chance you may morepick.",
        options =   {
                        {description = "E", data = 0.1},
						{description = "B", data = 0.25},
                        {description = "A", data = 0.4},
                    },
        default = 0.25,
    },
	{
        name = "hard",
        label = "LEVEL",
		hover = "Do you want an easy game?",
        options =   {
                        {description = "Greenhand", data = 1},
						{description = "Normal", data = 3},
                        {description = "Expert", data = 5},
                    },
        default = 3,
    },
	--1.6.1
	{
        name = "hammer",
        label = "HAMMER",
		hover = "The heartspan is enabled to be used as the hammer.",
        options =   {
                        {description = "enable", data = true},
						{description = "disable", data = false},
                    },
        default = false,
    },
}


