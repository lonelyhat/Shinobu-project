local _G = GLOBAL
local STRINGS = GLOBAL.STRINGS
local require = GLOBAL.require
local Ingredient = GLOBAL.Ingredient
local RECIPETABS = GLOBAL.RECIPETABS
local Recipe = GLOBAL.Recipe
local TECH = GLOBAL.TECH
local GetPlayer = GLOBAL.GetPlayer
local LAN = GetModConfigData('Language')
if LAN then
	require 'strings_shinobu_c'
	TUNING.shinobulan = true
else
	require 'strings_shinobu_e'
	TUNING.shinobulan = false
end
GLOBAL.TUNING.SHINOBU = {}
--1.3.1
TUNING.SW_MODE = GetModConfigData('World')
TUNING.IMLUCKY = GetModConfigData('lucky')
TUNING.GOO = GetModConfigData('hard')
TUNING.HEARTSPAN = GetModConfigData('hammer')

PrefabFiles = {
	"shinobu",
	"katana",
	"heartspan",
	"doughnut",
	"goggle",
}

Assets = {
	Asset("ANIM", "anim/shinobu.zip"),

	Asset( "IMAGE", "images/map_icons/shinobu.tex"),
	Asset( "ATLAS", "images/map_icons/shinobu.xml" ),
	
    Asset( "IMAGE", "images/saveslot_portraits/shinobu.tex" ),
    Asset( "ATLAS", "images/saveslot_portraits/shinobu.xml" ),

    Asset( "IMAGE", "images/selectscreen_portraits/shinobu.tex" ),
    Asset( "ATLAS", "images/selectscreen_portraits/shinobu.xml" ),

    Asset( "IMAGE", "images/selectscreen_portraits/shinobu_silho.tex" ),
    Asset( "ATLAS", "images/selectscreen_portraits/shinobu_silho.xml" ),

    Asset( "IMAGE", "bigportraits/shinobu.tex" ),
    Asset( "ATLAS", "bigportraits/shinobu.xml" ),
	
	
	Asset( "ATLAS", "images/inventoryimages/katana.xml"),
	Asset( "IMAGE", "images/inventoryimages/katana.tex" ),
	
	Asset( "ATLAS", "images/inventoryimages/heartspan.xml"),
	Asset( "IMAGE", "images/inventoryimages/heartspan.tex" ),
	
	Asset( "IMAGE", "images/inventoryimages/doughnut.tex" ),
    Asset( "ATLAS", "images/inventoryimages/doughnut.xml" ),
	
	Asset( "IMAGE", "images/inventoryimages/goggle.tex"),
	Asset( "ATLAS", "images/inventoryimages/goggle.xml" ),
}


--1.3.0
local function morepick(inst)
	inst.components.pickable.oldpick = inst.components.pickable.Pick
	function inst.components.pickable:Pick(picker)
		local oldnum = self.numtoharvest
		if picker and picker.components.shinobu_status then
			local value = math.random(1,math.ceil(picker.components.shinobu_status.level/40+0.01))
			local chance = picker.components.shinobu_status.level/100
			--1.3.1
			if chance > TUNING.IMLUCKY then 
				chance = TUNING.IMLUCKY
			end
			if chance ~= 0 then
				if math.random() <= chance then
					value = value + 1
				end
			end
			self.numtoharvest = self.numtoharvest*value
		end
		inst.components.pickable:oldpick(picker)
	    self.numtoharvest = oldnum
	end
end

local list = {
	"grass",
	"sapling",
	"reeds",
	"flower",
	"carrot_planted",
	"flower_evil",
	"berrybush",
	"berrybush2",
	"cactus",
	"red_mushroom",
	"green_mushroom",
	"blue_mushroom",
	"cave_fern",
	"cave_banana_tree",
	"lichen",
	"marsh_bush",
	"flower_cave",
	"flower_cave_double",
	"flower_cave_triple",
	"limpetrock",
	"seaweed_planted",
	"mussel_farm",
	"grass_water",
	"seashell_beached",
	"sweet_potato_planted",
	"coffeebush",
}
for i=1, #list do
	AddPrefabPostInit(list[i], function(inst)
		morepick(inst)
	end)
end




local function shinobu_tab(inst)
	--1.3.1
	if TUNING.SW_MODE == 3 then
		local shinobu_tab = { str = "shinobu_tab", sort = 999, icon = "tab_book.tex" }
		inst.components.builder:AddRecipeTab(shinobu_tab)
		--1.6.1
		local goggle = Recipe("goggle",{Ingredient("alloy",TUNING.GOO)},shinobu_tab,{SCIENCE = 2})
		goggle.atlas = "images/inventoryimages/goggle.xml"
		STRINGS.RECIPE_DESC.GOGGLE= "It looks cool!"
		--1.5.0
		local doughnut = Recipe("doughnut",{Ingredient("honey",TUNING.GOO + 2)},shinobu_tab,{SCIENCE = 0})
		doughnut.atlas = "images/inventoryimages/doughnut.xml"
		STRINGS.RECIPE_DESC.DOUGHNUT= "My favourite!"
		local katana = Recipe("katana", {Ingredient("walkingstick", 1),Ingredient("goldnugget", TUNING.GOO)}, shinobu_tab, {SCIENCE=2})
		katana.atlas = "images/inventoryimages/katana.xml"
		local heartspan = Recipe("heartspan", {Ingredient("katana", 1,"images/inventoryimages/katana.xml"),Ingredient("nightmarefuel",TUNING.GOO*2),Ingredient("purplegem",TUNING.GOO)}, shinobu_tab, {MAGIC = 2} ) --1.3.1
		heartspan.atlas = "images/inventoryimages/heartspan.xml"
		STRINGS.RECIPE_DESC.HEARTSPAN= "My old friend..."
		Recipe( "marble", { Ingredient("cutstone", TUNING.GOO) , Ingredient("flint", TUNING.GOO)}, RECIPETABS.REFINE, {SCIENCE = 2})
		STRINGS.RECIPE_DESC.MARBLE = "Now that is a strong rock!"
		Recipe("silk", {Ingredient("twigs",TUNING.GOO), Ingredient("cutgrass",TUNING.GOO)}, RECIPETABS.REFINE, {SCIENCE = 2})
		STRINGS.RECIPE_DESC.SILK = "From the creepy spidery things."
	
		Recipe("rocks", {Ingredient("flint", TUNING.GOO)}, RECIPETABS.REFINE,  TECH.SCIENCE_ONE)
	
		Recipe("flint", {Ingredient("rocks", TUNING.GOO)}, RECIPETABS.REFINE,  TECH.SCIENCE_ONE)	
		
		
		if TUNING.GOO == 1 then
			Recipe("silk", {Ingredient("twigs",TUNING.GOO), Ingredient("cutgrass",TUNING.GOO)}, RECIPETABS.REFINE, {SCIENCE = 2})
			STRINGS.RECIPE_DESC.SILK = "From the creepy spidery things."
			Recipe("rocks", {Ingredient("flint", TUNING.GOO)}, RECIPETABS.REFINE,  TECH.SCIENCE_ONE)
			Recipe("flint", {Ingredient("rocks", TUNING.GOO)}, RECIPETABS.REFINE,  TECH.SCIENCE_ONE)
			--1.3.2
		end
		
	else --1.3.1
	inst:AddComponent("reader")
	local shinobu_tab = { str = "shinobu_tab", sort = 999, icon = "tab_book.tex" }
    inst.components.builder:AddRecipeTab(shinobu_tab)
	--1.3.1
	local katana = Recipe("katana", {Ingredient("flint",3),Ingredient("cane",1)}, shinobu_tab, {SCIENCE=2} )
	katana.atlas = "images/inventoryimages/katana.xml"
	--1.5.0
	local doughnut = Recipe("doughnut",{Ingredient("honey",TUNING.GOO),Ingredient("tallbirdegg",1)},shinobu_tab,{SCIENCE = 0})
	doughnut.atlas = "images/inventoryimages/doughnut.xml"
	STRINGS.RECIPE_DESC.DOUGHNUT= "My favourite!"
	--1.6.1
	local goggle = Recipe("goggle",{Ingredient("bluegem",TUNING.GOO),Ingredient("marble",TUNING.GOO),Ingredient("flint",TUNING.GOO*2)},shinobu_tab,{SCIENCE = 2})
	goggle.atlas = "images/inventoryimages/goggle.xml"
	STRINGS.RECIPE_DESC.GOGGLE= "It looks cool!"
	
	if TUNING.SW_MODE == 1 then
		local heartspan = Recipe("heartspan", {Ingredient("katana", 1,"images/inventoryimages/katana.xml"),Ingredient("nightmarefuel",TUNING.GOO*2),Ingredient("slurper_pelt",TUNING.GOO),Ingredient("livinglog",TUNING.GOO),Ingredient("purplegem",2)}, shinobu_tab, {MAGIC = 2} ) --1.3.0
		heartspan.atlas = "images/inventoryimages/heartspan.xml"
		STRINGS.RECIPE_DESC.HEARTSPAN= "My old friend..." --1.6.1
	elseif GLOBAL.IsDLCEnabled(GLOBAL.CAPY_DLC) and TUNING.SW_MODE == 2 then
		local heartspan = Recipe("heartspan", {Ingredient("katana", 1,"images/inventoryimages/katana.xml"),Ingredient("nightmarefuel",TUNING.GOO*2),Ingredient("obsidian",TUNING.GOO),Ingredient("livinglog",TUNING.GOO),Ingredient("purplegem",2)}, shinobu_tab, {MAGIC = 2} ) --1.3.1
		heartspan.atlas = "images/inventoryimages/heartspan.xml"
		STRINGS.RECIPE_DESC.HEARTSPAN= "My old friend..." --1.6.1
	end
	
	if GLOBAL.IsDLCEnabled(GLOBAL.CAPY_DLC) then
		Recipe("goldnugget", {Ingredient("dubloon", TUNING.GOO)}, shinobu_tab,  TECH.SCIENCE_TWO) --1.3.1
		Recipe("dubloon",{ Ingredient("goldnugget",1)},shinobu_tab,{SCIENCE = 2}) --鼓励多以击杀怪物的方式获得金币
	end
	
	Recipe("book_birds", { Ingredient("papyrus", 2), Ingredient("bird_egg", 2) }, shinobu_tab, { SCIENCE = 2, MAGIC = 0, ANCIENT = 0 })
    Recipe("book_gardening", { Ingredient("papyrus", 2), Ingredient("seeds", 1), Ingredient("poop", 1) }, shinobu_tab, { MAGIC = 2 })
    Recipe("book_sleep", { Ingredient("papyrus", 2), Ingredient("nightmarefuel", 2) }, shinobu_tab, { MAGIC = 1 })
    Recipe("book_brimstone", { Ingredient("papyrus", 2), Ingredient("redgem", 1) }, shinobu_tab, { MAGIC = 1 })
    if GLOBAL.IsDLCEnabled(GLOBAL.CAPY_DLC) then
        Recipe("book_meteor", { Ingredient("papyrus", 2), Ingredient("obsidian", 2) }, shinobu_tab, { MAGIC = 1 })
    else
        Recipe("book_tentacles", { Ingredient("papyrus", 2), Ingredient("tentaclespots", 1) }, shinobu_tab, { MAGIC = 1 })
    end
	--精炼栏新增
	Recipe( "marble", { Ingredient("cutstone", TUNING.GOO) , Ingredient("flint", TUNING.GOO)}, RECIPETABS.REFINE, {SCIENCE = 2})
	STRINGS.RECIPE_DESC.MARBLE = "Now that is a strong rock!"
	Recipe("silk", {Ingredient("twigs",TUNING.GOO), Ingredient("cutgrass",TUNING.GOO)}, RECIPETABS.REFINE, {SCIENCE = 2})
	STRINGS.RECIPE_DESC.SILK = "From the creepy spidery things."
	
	Recipe("rocks", {Ingredient("flint", TUNING.GOO)}, RECIPETABS.REFINE,  TECH.SCIENCE_ONE)
	
	Recipe("flint", {Ingredient("rocks", TUNING.GOO)}, RECIPETABS.REFINE,  TECH.SCIENCE_ONE)
	
	if TUNING.GOO == 1 then 
	Recipe("petals_evil", { Ingredient("petals", 4) }, shinobu_tab, { MAGIC = 1 })
	Recipe("livinglog", { Ingredient("log", 2), Ingredient("petals_evil", 2) }, shinobu_tab, { MAGIC = 1 })
	Recipe("gears", { Ingredient("flint", 3), Ingredient("cutstone", 1), Ingredient("goldnugget", 3) }, shinobu_stab, { SCIENCE = 1 })
	Recipe("walrus_tusk", { Ingredient("houndstooth", 10),Ingredient("horn", 1) }, shinobu_tab, { MAGIC = 1 })
	end

	
	
	
	--本来准备写进蓝图的，但太麻烦了
	if TUNING.SW_MODE ~= 3 and TUNING.GOO == 1 then
	Recipe("butter",{Ingredient("tallbirdegg",1),Ingredient("butterflywings",5)},shinobu_tab,{SCIENCE = 1})
	
	Recipe("glommerwings", { Ingredient("glommerfuel",10),Ingredient("butterflywings",1)}, shinobu_tab, {MAGIC = 1})
	Recipe("glommerflower", {Ingredient("glommerfuel",10),Ingredient("petals",10),Ingredient("purplegem",1)}, shinobu_tab,{MAGIC = 1})
	Recipe("armorsnurtleshell",{Ingredient("slurtle_shellpieces",20)},shinobu_tab, {SCIENCE = 1})
	
	if GLOBAL.IsDLCEnabled(GLOBAL.CAPY_DLC) then
		Recipe("venomgland", { Ingredient("spidergland", 2) }, shinobu_tab, { SCIENCE = 2 })
		Recipe("obsidian", { Ingredient("thulecite",1) }, shinobu_stab, { SCIENCE = 2 })
	end
	end --1.4.0
	end --1.3.1
end

-----
if GLOBAL.IsDLCEnabled(GLOBAL.CAPY_DLC) then
	local books = {'book_birds','book_gardening','book_sleep','book_brimstone','book_tentacles',"book_meteor"}
	for k,v in pairs(books) do
	AddPrefabPostInit(v,function(inst)
			if inst.components.characterspecific and GetPlayer() and GetPlayer().prefab == 'shinobu' then
			inst.components.characterspecific:SetOwner("shinobu")
			end
	end)
	end
else
	local books = {'book_birds','book_gardening','book_sleep','book_brimstone','book_tentacles'}
	for k,v in pairs(books) do
	AddPrefabPostInit(v,function(inst)
			if inst.components.characterspecific and GetPlayer() and GetPlayer().prefab == 'shinobu' then
			inst.components.characterspecific:SetOwner("shinobu")
			end
	end)
	end
	
end

AddPrefabPostInit("nightmarefuel", function(inst) if inst.components.tradable == nil then inst:AddComponent("tradable") end end) --1.6.3 感谢@ZeroZWT帮忙解决妖刀无法添加燃料bug
	
	
--1.4.0
STRINGS.CHARACTERS.shinobu = require "speech_shinobu_player"

table.insert(GLOBAL.CHARACTER_GENDERS.FEMALE, "shinobu")

AddMinimapAtlas("images/map_icons/shinobu.xml")
AddModCharacter("shinobu")
AddPrefabPostInit("shinobu", shinobu_tab)
modimport("shinobu_util/shinobu_util.lua")