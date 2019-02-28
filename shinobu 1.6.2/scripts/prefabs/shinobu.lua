local MakePlayerCharacter = require "prefabs/player_common"
local easing = require("easing")
--local nightVision = false -- 1.1

local assets = {
		-- Don't forget to include your character's custom assets!
		Asset( "ANIM", "anim/player_basic.zip" ),
        Asset( "ANIM", "anim/player_idles_shiver.zip" ),
        Asset( "ANIM", "anim/player_actions.zip" ),
        Asset( "ANIM", "anim/player_actions_axe.zip" ),
        Asset( "ANIM", "anim/player_actions_pickaxe.zip" ),
        Asset( "ANIM", "anim/player_actions_shovel.zip" ),
        Asset( "ANIM", "anim/player_actions_blowdart.zip" ),
        Asset( "ANIM", "anim/player_actions_eat.zip" ),
        Asset( "ANIM", "anim/player_actions_item.zip" ),
        Asset( "ANIM", "anim/player_actions_uniqueitem.zip" ),
        Asset( "ANIM", "anim/player_actions_bugnet.zip" ),
        Asset( "ANIM", "anim/player_actions_fishing.zip" ),
        Asset( "ANIM", "anim/player_actions_boomerang.zip" ),
        Asset( "ANIM", "anim/player_bush_hat.zip" ),
        Asset( "ANIM", "anim/player_attacks.zip" ),
        Asset( "ANIM", "anim/player_idles.zip" ),
        Asset( "ANIM", "anim/player_rebirth.zip" ),
        Asset( "ANIM", "anim/player_jump.zip" ),
        Asset( "ANIM", "anim/player_amulet_resurrect.zip" ),
        Asset( "ANIM", "anim/player_teleport.zip" ),
        Asset( "ANIM", "anim/wilson_fx.zip" ),
        Asset( "ANIM", "anim/player_one_man_band.zip" ),
        Asset( "ANIM", "anim/shadow_hands.zip" ),
        Asset( "SOUND", "sound/sfx.fsb" ),
        Asset( "SOUND", "sound/wilson.fsb" ),
        Asset( "ANIM", "anim/beard.zip" ),
		
        Asset( "ANIM", "anim/shinobu.zip" ),
}
local prefabs = {
}

local start_inv = {
}


-- level up!
local function value(inst) --计算属性
	local lv = inst.components.shinobu_status.level

    --饥饿判定
	local hunger_percent = inst.components.hunger:GetPercent()
	inst.components.hunger.max = math.ceil(75 + lv * 225/100)
	inst.components.hunger:SetPercent(hunger_percent)

	--脑力判定
	local sanity_percent = inst.components.sanity:GetPercent()
	inst.components.sanity.max = math.ceil(100 + lv * 3)
	inst.components.sanity:SetPercent(sanity_percent)
	
	--血量判定
	local health_percent = inst.components.health:GetPercent()
	inst.components.health.maxhealth = math.ceil(75 + lv *225/100)
	inst.components.health:SetPercent(health_percent)

	--最高exp判定 1.4.1
	if TUNING.GOO == 5 then
		inst.components.shinobu_status.maxexp = lv * 500 + 100
	elseif TUNING.GOO == 3 then
		inst.components.shinobu_status.maxexp = lv * 300 + 100
	else
		inst.components.shinobu_status.maxexp = lv * 100 + 100
	end

	--速度计算
	inst.components.locomotor.walkspeed = inst.components.shinobu_status.speedwalk
	inst.components.locomotor.runspeed = inst.components.shinobu_status.speedrun
	
	--Special skill!
	--1.4.0
	if TUNING.GOO == 1 then
	if lv > 1 then
	inst.components.builder.science_bonus = 1
	end
	if lv >= 10 then  
		inst:AddTag("weak_vampire")
	end
	else
	if lv >= 1 then  
	inst:AddTag("weak_vampire")
	end
	end
	if lv >= 20 and TUNING.GOO ~= 5 then --1.6.2
		inst:AddTag("Chefx")
		inst.components.builder.science_bonus = 1
	end
	if lv > 40 and TUNING.GOO ~= 5 then 
		inst.components.builder.science_bonus = 2
	end
	if lv >= 50 and TUNING.GOO ~= 5 then
		inst:RemoveTag("weak_vampire")
		inst:AddTag("Vampire")
	end
	if lv > 60 and TUNING.GOO ~= 5 then 
		inst.components.builder.science_bonus = 3
		inst.components.builder.magic_bonus = 1
	end
	if lv > 80 and TUNING.GOO ~= 5 then 
		inst.components.builder.science_bonus = 3
		inst.components.builder.magic_bonus = 3
	end
	if lv >= 100 and TUNING.GOO ~= 5 then
		inst:AddTag("Omniscient")
	end
	if inst:HasTag("weak_vampire") then
		--Add:
		inst.components.health.absorb = -.25
		inst.components.health.fire_damage_scale = 3  --easy to be burned
		inst.components.temperature.hurtrate = 300 / TUNING.FREEZING_KILL_TIME  --很容易热死或冻死1.5.1
	end
	--print("level:"..inst.components.shinobu_status.level)
	--print(inst:HasTag("weak_vampire"))
	--print(inst:HasTag("Chefx"))
	--print(inst:HasTag("Vampire"))
	--print(inst:HasTag("monster"))
	--print(inst:HasTag("Omniscient"))
	--add
	--For test, shinobu is vulnerable when she is a child
	--1.6.1
	if inst:HasTag("Vampire") and TUNING.GOO ~= 5 then
		inst.components.eater.ignoresspoilage = true
		inst.components.eater.strongstomach = true --Can eat raw meat but don't like spoiled food.
		inst.components.temperature.mintemp = -25      --not easy to get cold
		inst.components.health.absorb = 0
		inst.components.health.fire_damage_scale = 2  --easy to be burned
		inst.components.moisture.maxDryingRate = 0.2
		inst.components.moisture.maxMoistureRate = 0.5
		inst.components.temperature.hurtrate = 100 / TUNING.FREEZING_KILL_TIME
	end
	--1.6.1
	if inst:HasTag("Omniscient") and TUNING.GOO ~= 5 then
		inst.components.health.absorb = 0.1 -- 1.3.0
		inst.components.builder.science_bonus = 3
		inst.components.builder.magic_bonus = 3
		inst.components.builder.ancient_bonus = 4
		if IsDLCEnabled(CAPY_DLC) then
			inst.components.builder.obsidian_bonus = 2
		end
		--[[inst:AddComponent("firebug")
		inst.components.firebug.prefab = "willowfire"]]---- 1.6.4自燃bug修复
		inst.components.health.fire_damage_scale = 0
		--1.3.0
		--[[
		if inst:HasTag("poisonable") then
			inst:RemoveTag("poisonable")
		end
		]]--
	end
end

--分段level up
--1.6.1
local function level_up(inst)
	if TUNING.GOO ~= 1 then
	if inst.components.shinobu_status.level < 100 then  --1.3.0
		inst.components.shinobu_status.level = inst.components.shinobu_status.level + 1
		value(inst)
		inst.components.talker:Say("Level UP!\nLv."..(inst.components.shinobu_status.level))
		inst.SoundEmitter:PlaySound("dontstarve/characters/wx78/levelup")
		inst.components.sanity:DoDelta(inst.components.sanity.max/10)
	end	
	else
		inst.components.shinobu_status.level = inst.components.shinobu_status.level + 1
		value(inst)
		inst.components.talker:Say("Level UP!\nLv."..(inst.components.shinobu_status.level))
		inst.SoundEmitter:PlaySound("dontstarve/characters/wx78/levelup")
		inst.components.sanity:DoDelta(inst.components.sanity.max/10)
	end
end


--杀怪奖励与经验1.3.3.5
local function onkilledother(inst, data)
	local victim = data.victim

	if (victim.components.freezable or victim:HasTag("monster")) and victim.components.health then
		local value = math.ceil(victim.components.health.maxhealth)
		inst.components.shinobu_status:DoDeltaExp(value*2)
		local rp = 0.05
		if rp > math.random() and victim.components.lootdropper then
			victim.components.lootdropper:SpawnLootPrefab("nightmarefuel")
		end
		if value > 500 then
			inst.components.shinobu_status:DoDeltaExp(value*1)
			if victim.components.lootdropper then
				victim.components.lootdropper:SpawnLootPrefab("nightmarefuel")
			end
		end
		if value > 1000 then 
			inst.components.shinobu_status:DoDeltaExp(value*1)
			if victim.components.lootdropper then
				--boss奖励
				victim.components.lootdropper:SpawnLootPrefab("nightmarefuel")
				victim.components.lootdropper:SpawnLootPrefab("nightmarefuel")
				victim.components.lootdropper:SpawnLootPrefab("nightmarefuel")
				victim.components.lootdropper:SpawnLootPrefab("nightmarefuel")
			end
		end
	end
	if victim.components.lootdropper then
		if victim.components.freezable or victim:HasTag("monster") then
		    if math.random(1, 100) <= inst.components.shinobu_status.level then
				victim.components.lootdropper:DropLoot()
	        end
		end
	end
	--根据幸运值打怪掉金币
	--1.4.0
	if (victim.components.freezable or victim:HasTag("monster"))and victim.components.lootdropper then
		local extra = 0.05 + victim.components.health.maxhealth/150 * inst.components.shinobu_status.level/200
		if extra > TUNING.IMLUCKY then
			extra = TUNING.IMLUCKY
		end
		if extra >= math.random() then
			if IsDLCEnabled(CAPY_DLC) and TUNING.SW_MODE ~= 3 then
				victim.components.lootdropper:SpawnLootPrefab("dubloon")
			else
				victim.components.lootdropper:SpawnLootPrefab("goldnugget")
			end
		end
		local valuex = math.ceil(victim.components.health.maxhealth)
		if valuex >= 500 then
		while valuex >= 100 and IsDLCEnabled(CAPY_DLC) and victim.components.lootdropper do
			victim.components.lootdropper:SpawnLootPrefab("dubloon")
			valuex = valuex - 100
		end
		end
	end
end


--需要详细修改！！！建议依照食物的参数
local function oneat(inst, food) 
	if food and food.components.edible then 
		--1.5.0
		if food.prefab == "doughnut" then
			inst.components.shinobu_status:DoDeltaExp(1000)
		end
		if food.prefab == "jellybean" then
			inst.components.shinobu_status:DoDeltaExp(3000)
		elseif food.prefab == "waffles" 
			or food.prefab == "royal_jelly"
			then 
			inst.components.shinobu_status:DoDeltaExp(2000)
			inst.components.sanity:DoDelta(50)
			inst.components.hunger:DoDelta(30)
		elseif food.prefab == "butter" then 
			inst.components.shinobu_status:DoDeltaExp(1000)
			inst.components.sanity:DoDelta(15)
		elseif food.prefab == "butterflymuffin" then
			inst.components.sanity:DoDelta(20)
		elseif food.prefab == "bandage" then
			inst.components.shinobu_status:DoDeltaExp(500)
			inst.components.health:DoDelta(10)
			inst.components.sanity:DoDelta(10)
		elseif food.prefab == "taffy" then
			inst.components.shinobu_status:DoDeltaExp(1000)
			inst.components.sanity:DoDelta(20)
			inst.components.health:DoDelta(10)
		elseif food.prefab == "mosquitosack" then
			inst.components.sanity:DoDelta(-15)
			inst.components.shinobu_status:DoDeltaExp(1000)
		elseif food.prefab == "fruitmedley" 
			or food.prefab == "pumpkincookie"
			or food.prefab == "icecream" 
			then
			inst.components.shinobu_status:DoDeltaExp(1000)
			inst.components.health:DoDelta(5)
			inst.components.sanity:DoDelta(10)
			inst.components.hunger:DoDelta(10)
		elseif food.prefab == "honey" 
			or food.prefab == "flowersalad"
			or food.prefab == "watermelonicle"
			or food.prefab == "jammypreserves"
			or food.prefab == "honeynuggets"
			or food.prefab == "guacamole"
			then
			inst.components.shinobu_status:DoDeltaExp(500)
			inst.components.sanity:DoDelta(5)
		elseif food.prefab == "honeyham" then 
			inst.components.shinobu_status:DoDeltaExp(1000)
			inst.components.sanity:DoDelta(15) 
			
		--For test only
		--elseif food.prefab == "berries" then 
		--inst.components.shinobu_status:DoDeltaExp(3000)
			
		elseif food.prefab == "smallmeat_dried"
			or food.prefab == "tallbirdegg_cooked"
			or food.prefab == "trunk_cooked"
			or food.prefab == "mandrake"
			or food.prefab == "cookedmandrake"
			or food.prefab == "frogglebunwich"
			or food.prefab == "kabobs"
			or food.prefab == "fishtacos"
			or food.prefab == "fishsticks"
			or food.prefab == "stuffedeggplant"
			or food.prefab == "meatballs"
			or food.prefab == "unagi"
			or food.prefab == "goatmilk"
			or food.prefab == "perogies"
			or food.prefab == "sweetpotatosouffle"
			or food.prefab == "sharkfinsoup"
			or food.prefab == "guacamole"
			or food.prefab == "californiaroll"
			or food.prefab == "bisque"
			then
			inst.components.sanity:DoDelta(5)
			inst.components.hunger:DoDelta(5)
			inst.components.health:DoDelta(5)
			inst.components.shinobu_status:DoDeltaExp(500)
			
		elseif food.prefab == "meat_dried"
			or food.prefab == "mandrakesoup"
			or food.prefab == "dragonpie"
			or food.prefab == "turkeydinner"
			or food.prefab == "baconeggs"
			or food.prefab == "bonestew"
			or food.prefab == "dragoonheart"
			or food.prefab == "minotaurhorn"
			or food.prefab == "surfnturf"
			or food.prefab == "freshfruitcrepes"
			or food.prefab == "lobsterdinner"
			or food.prefab == "seafoodgumbo"
			or food.prefab == "lobsterbisque"
			then 
			inst.components.sanity:DoDelta(5)
			inst.components.hunger:DoDelta(5)
			inst.components.health:DoDelta(5)
			inst.components.shinobu_status:DoDeltaExp(1000)
		else
			inst.components.sanity:DoDelta(2)
			inst.components.health:DoDelta(2)
			inst.components.shinobu_status:DoDeltaExp(100)
		end
	end
end

--处理经验
local function DoDeltaExpSHINOBU(inst)
	if inst.components.shinobu_status.exp >= inst.components.shinobu_status.maxexp then
		local expnew = inst.components.shinobu_status.exp - inst.components.shinobu_status.maxexp
		level_up(inst)
		inst.components.shinobu_status.exp = 0
		if expnew > 0 then
			inst.components.shinobu_status:DoDeltaExp(expnew)
		end
	end
end


--[[For test, since shinobu likes to sleep :)
local function sleep(inst)
	if inst.components.locomotor.inst:IsAsleep() then
		inst.components.shinobu_status:DoDeltaExp(500)
		inst.components.talker:Say("exp+500")
	end
end]]-- cannot work well.

--From nightmare mod.
--Special thanks to the author
--[[local function NightVision(inst)
	if not GetClock():IsDay() or GetWorld():HasTag("cave") then --should be "inst:HasTag("Vampire")"
		if inst:HasTag("Vampire") then 
			inst.Light:Enable(true)
			nightVision = true
		else
			inst.Light:Enable(false)
			nightVision = false
		end
    else
        inst.Light:Enable(false)
		nightVision = false
	end
	
	
	if inst:HasTag("weak_vampire") then
	--reverse generation of sanity
	inst.components.sanity.custom_rate_fn= function(inst)
	local dapperness = 0
	local day = GetClock():IsDay() and not GetWorld():HasTag("cave")
	if day then
		dapperness = TUNING.SANITY_NIGHT_DARK * 0.6
    else
		dapperness = TUNING.SANITY_NIGHT_DARK * 0.2
		dapperness = dapperness*inst.components.sanity.night_drain_mult
		dapperness= -2 * dapperness * ((GetClock():IsNight() and 1) or 0.5)
	end
	return dapperness
	end	 
	elseif inst:HasTag("Vampire") then 
	
	--reverse generation of sanity
	inst.components.sanity.custom_rate_fn= function(inst)
	local dapperness = 0
	local day = GetClock():IsDay() and not GetWorld():HasTag("cave")
	if day then
		dapperness = 0
    else
		dapperness = TUNING.SANITY_NIGHT_DARK * 0.2
		dapperness = dapperness*inst.components.sanity.night_drain_mult
		dapperness= -2 * dapperness * ((GetClock():IsNight() and 2) or 1.7)
	end
	return dapperness
	end	 
	else
		inst.components.sanity.custom_rate_fn = nil
	end
end]]-- 1.1




--1.3.1
local function reverse_generation(inst)
	if inst:HasTag("weak_vampire") or inst:HasTag("Vampire") then
	--reverse generation of sanity
	inst.components.sanity.custom_rate_fn = function(inst)
	local dapperness = 0
	local day = GetClock():IsDay() and not GetWorld():HasTag("cave")
	if day then
		--1.3.2
		dapperness = TUNING.SANITY_NIGHT_MID*1.4 + TUNING.SANITY_NIGHT_MID*0.6*inst.components.shinobu_status.level/100 + easing.inSine(inst.components.moisture:GetMoisture(), 0, TUNING.MOISTURE_SANITY_PENALTY_MAX, inst.components.moisture.moistureclamp.max) --与雨水有关
    else
		dapperness = TUNING.SANITY_NIGHT_MID 
		dapperness = dapperness*inst.components.sanity.night_drain_mult
		dapperness= -2 * dapperness * ((GetClock():IsNight() and 1) or 0.4) + easing.inSine(inst.components.moisture:GetMoisture(), 0, TUNING.MOISTURE_SANITY_PENALTY_MAX, inst.components.moisture.moistureclamp.max)
	end
	return dapperness
	end	 
	end
end

--[[1.2
local function reverse_generation(inst)
	if inst:HasTag("weak_vampire") then
	--reverse generation of sanity
	inst.components.sanity.custom_rate_fn= function(inst)
	local dapperness = 0
	local day = GetClock():IsDay() and not GetWorld():HasTag("cave")
	if day then
		dapperness = TUNING.SANITY_NIGHT_DARK * 0.6
    else
		dapperness = TUNING.SANITY_NIGHT_DARK * 0.2
		dapperness = dapperness*inst.components.sanity.night_drain_mult
		dapperness= -2 * dapperness * ((GetClock():IsNight() and 1) or 0.5)
	end
	return dapperness
	end	 
	elseif inst:HasTag("Vampire") then 
	--reverse generation of sanity
	inst.components.sanity.custom_rate_fn= function(inst)
	local dapperness = 0
	local day = GetClock():IsDay() and not GetWorld():HasTag("cave")
	if day then
		dapperness = 0
    else
		dapperness = TUNING.SANITY_NIGHT_DARK * 0.2
		dapperness = dapperness*inst.components.sanity.night_drain_mult
		dapperness= -2 * dapperness * ((GetClock():IsNight() and 2) or 1.7)
	end
	return dapperness
	end	 
	else
		inst.components.sanity.custom_rate_fn = nil
	end
end]]--


--The speed and attackperiod will change with the percent of hungry and sanity
local function onhungerchange(inst,data)
	--速度计算
	local rate = inst.components.hunger:GetPercent()
	if rate >= 0.75 then
			inst.components.locomotor.walkspeed = 7
			inst.components.locomotor.runspeed = 7
		elseif rate >= 0.5 and rate < 0.75 then
			inst.components.locomotor.walkspeed = 6
			inst.components.locomotor.runspeed = 6
		elseif rate >= 0.25 and rate < 0.5 then
			inst.components.locomotor.walkspeed = 5
			inst.components.locomotor.runspeed = 5
		elseif rate >= 0.1 and rate < 0.25 then
			inst.components.locomotor.walkspeed = 4
			inst.components.locomotor.runspeed = 4
		else
			inst.components.locomotor.walkspeed = 3  
			inst.components.locomotor.runspeed = 3 
	end
end 

local function onsanitychange(inst,data)
	--重新计算
	local percent = inst.components.sanity:GetPercent()
	if percent >= 0.75 then
			inst.components.combat.min_attack_period = 0.5--随san变化，越低越高
		elseif percent >= 0.5 and percent < 0.75 then
			inst.components.combat.min_attack_period = 0.4
		elseif percent >= 0.25 and percent < 0.5 then
			inst.components.combat.min_attack_period = 0.3 
		else 
			inst.components.combat.min_attack_period = 0.2
	end
	if IsDLCEnabled(CAPY_DLC) then
		if percent >= 0.75 then
			inst.components.combat.damagemultiplier = 0.75--随san变化，越低越高
		elseif percent >= 0.5 and percent < 0.75 then
			inst.components.combat.damagemultiplier = 1.25
		elseif percent >= 0.25 and percent < 0.5 then
			inst.components.combat.damagemultiplier = 1.5
		else 
			inst.components.combat.damagemultiplier = 2
		end
	end
end
local function onpreload(inst)
	local lv = inst.components.shinobu_status.level
	--Special skill!
	--1.4.0
	--1.4.0
	if TUNING.GOO == 1 then
	if lv > 1 then
	inst.components.builder.science_bonus = 1
	end
	if lv >= 10 then  --for test
		inst:AddTag("weak_vampire")
	end
	else
	if lv >= 1 then  --for test
	inst:AddTag("weak_vampire")
	end
	end
	if lv >= 20 and TUNING.GOO ~= 5 then
		inst:AddTag("Chefx")
		inst.components.builder.science_bonus = 1
	end
	if lv > 40 and TUNING.GOO ~= 5 then 
		inst.components.builder.science_bonus = 2
	end
	if lv >= 50 and TUNING.GOO ~= 5 then
		inst:RemoveTag("weak_vampire")
		inst:AddTag("Vampire")
	end
	if lv > 60 and TUNING.GOO ~= 5 then 
		inst.components.builder.science_bonus = 3
		inst.components.builder.magic_bonus = 1
	end
	if lv > 80 and TUNING.GOO ~= 5 then 
		inst.components.builder.science_bonus = 3
		inst.components.builder.magic_bonus = 3
	end
	if lv >= 100 and TUNING.GOO ~= 5 then
		inst:AddTag("Omniscient")
	end
	if inst:HasTag("weak_vampire") then
		--Add:
		inst.components.health.absorb = -.25
		inst.components.health.fire_damage_scale = 3  --easy to be burned
		inst.components.temperature.hurtrate = 300 / TUNING.FREEZING_KILL_TIME  --很容易热死或冻死1.5.1
	end
	--print("level:"..inst.components.shinobu_status.level)
	--print(inst:HasTag("weak_vampire"))
	--print(inst:HasTag("Chefx"))
	--print(inst:HasTag("Vampire"))
	--print(inst:HasTag("monster"))
	--print(inst:HasTag("Omniscient"))
	--add
	--For test, shinobu is vulnerable when she is a child
	--1.6.1
	if inst:HasTag("Vampire") and TUNING.GOO ~= 5 then
		inst.components.eater.ignoresspoilage = true
		inst.components.eater.strongstomach = true --Can eat raw meat but don't like spoiled food.
		inst.components.temperature.mintemp = -25      --not easy to get cold
		inst.components.health.absorb = 0
		inst.components.health.fire_damage_scale = 2  --easy to be burned
		inst.components.moisture.maxDryingRate = 0.2
		inst.components.moisture.maxMoistureRate = 0.5
		inst.components.temperature.hurtrate = 100 / TUNING.FREEZING_KILL_TIME
	end

	if inst:HasTag("Omniscient") and TUNING.GOO ~= 5 then
		inst.components.health.absorb = 0.1 -- 1.3.0
		inst.components.builder.science_bonus = 3
		inst.components.builder.magic_bonus = 3
		inst.components.builder.ancient_bonus = 4
		if IsDLCEnabled(CAPY_DLC) then
			inst.components.builder.obsidian_bonus = 2
		end
		--[[
		inst:AddComponent("firebug")
		inst.components.firebug.prefab = "willowfire"]]-- 1.6.4自燃bug修复
		inst.components.health.fire_damage_scale = 0
		--1.3.0
		--[[
		if inst:HasTag("poisonable") then
			inst:RemoveTag("poisonable")
		end
		]]--
	end
end



local fn = function(inst)
	--Add:light 
	local light = inst.entity:AddLight() --1.1
	
	inst:AddTag("shinobu")
	inst:AddComponent("shinobu_status")
	inst.components.eater:SetOnEatFn(oneat)
	-- choose which sounds this character will play
	inst.soundsname = "willow"
	-- a minimap icon must be specified
	inst.MiniMapEntity:SetIcon( "shinobu.tex" )
	-- todo: Add an example special power here.-- Stats	
	inst.components.health:SetMaxHealth(75)
	inst.components.hunger:SetMax(75)
	inst.components.sanity:SetMax(100)	
	--quicker attack period 
	inst.components.combat.min_attack_period = 0.5
	--speed rate
	inst.components.locomotor.walkspeed = 7
	inst.components.locomotor.runspeed = 7
	
	-- Hunger rate (optional)
	inst.components.hunger.hungerrate = 1 * TUNING.WILSON_HUNGER_RATE
	
	--Add test： 
	
	if IsDLCEnabled(CAPY_DLC) then
		inst.components.combat.damagemultiplier = 0.75
	end
	
	
	
	inst:ListenForEvent("DoDeltaExpSHINOBU", DoDeltaExpSHINOBU)
	--For test
	--inst:ListenForEvent("locomote", sleep)
	inst:ListenForEvent("killed", onkilledother)
	
	--test for nightversion
	inst:AddTag("shinobu")
	--reverse generation of sanity
	inst:ListenForEvent( "daytime", function() reverse_generation(inst) end , GetWorld())
	inst:ListenForEvent( "nighttime", function() reverse_generation(inst) end , GetWorld())
	if GetClock():IsDay() or GetWorld():HasTag("cave") then
		inst:DoTaskInTime(0, function() reverse_generation(inst) end , GetWorld())
	elseif not GetClock():IsDay() or not GetWorld():HasTag("cave") then
		inst:DoTaskInTime(0, function() reverse_generation(inst) end , GetWorld())		
	end
	
	
	
	--[[inst:ListenForEvent( "daytime", function() NightVision(inst) end , GetWorld())
	inst:ListenForEvent( "nighttime", function() NightVision(inst) end , GetWorld())
	if GetClock():IsNight() and nightVision == false or GetWorld():HasTag("cave") and 
	nightVision == false then
		inst:DoTaskInTime(0, function() NightVision(inst) end , GetWorld())
	elseif not GetClock():IsNight() and nightVision == true or not GetWorld():HasTag("cave") and nightVision == true then
		inst:DoTaskInTime(0, function() NightVision(inst) end , GetWorld())		
	end
	--eyesight at night 1.1
	--Add: copy from nightmare
	inst.entity:AddLight()
	inst.Light:Enable(false)
	inst.Light:SetRadius(15)
	inst.Light:SetFalloff(0.8)
	inst.Light:SetIntensity(0.5)
	inst.Light:SetColour(15/255,165/255,165/255)]]--
	
	--监听hungery和sanity
	inst:ListenForEvent("hungerdelta", onhungerchange)
	inst:ListenForEvent("sanitydelta", onsanitychange)
	
	----------刷新
	inst:DoTaskInTime(0, function()
		local lv = inst.components.shinobu_status.level
		value(inst)
		inst.components.hunger.current = inst.components.shinobu_status.chunger
		inst.components.sanity.current = inst.components.shinobu_status.csanity
		inst.components.health.currenthealth = inst.components.shinobu_status.chealth
		inst.components.hunger:DoDelta(0)
		inst.components.sanity:DoDelta(0)
		inst.components.health:DoDelta(0)
		inst.components.shinobu_status:onstatuschange()
		inst.components.hunger:DoDelta(0)
		inst.components.sanity:DoDelta(0)
		inst.components.health:DoDelta(0)	
	end)
	
	inst.OnPreLoad = onpreload
end
return MakePlayerCharacter("shinobu", prefabs, assets, fn, start_inv)