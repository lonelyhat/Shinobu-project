local GetPlayer = GLOBAL.GetPlayer
local TheInput = GLOBAL.TheInput
local GetClock = GLOBAL.GetClock
local GetWorld = GLOBAL.GetWorld
local LAN = GetModConfigData('Language')
TUNING.VAMPIRE = false
local KEY_K = GLOBAL.KEY_K
local K = function(player)
	if not player:HasTag("playerghost") and player.components.shinobu_status then
		local str = ""
		if player:HasTag("weak_vampire") then
			if LAN then
			str = str.."[虚弱的吸血鬼]"
			else
			str = str.."[Weak vampire] "
			end
		end
		if player:HasTag("Chefx") then
			if LAN then
			str = str.."[烹饪大师]"
			else
			str = str.."[Chef] "
			end
		end
		if player:HasTag("Vampire") then
			if LAN then
			str = str.."[最强の吸血鬼]"
			else
			str = str.."[Vampire] "
			end
		end
		if player:HasTag("Omniscient") then
			if LAN then
			str = str.."[全知全能]"
			else
			str = str.."[Omniscient]"
			end
		end
		if TUNING.VAMPIRE == true then
			str = str.."\nNightVision:on"
		else
			str = str.."\nNightVision:off"
		end
		if LAN then
		player.components.talker:Say("等级: "..(player.components.shinobu_status.level).."  ".."经验: "..(math.floor(player.components.shinobu_status.exp)).."/"..(player.components.shinobu_status.maxexp).."\n技能:\n"..str)
		else
		player.components.talker:Say("lv "..(player.components.shinobu_status.level).."  ".."exp "..(math.floor(player.components.shinobu_status.exp)).."/"..(player.components.shinobu_status.maxexp).."\nSKILL:\n"..str)
		end
	end
end

local KEY_L = GLOBAL.KEY_L
local L = function(player)
	if player.components.shinobu_status then
	if not player:HasTag("playerghost") and player.components.shinobu_status.level >= 1 and TUNING.VAMPIRE == false then
		if GetClock():IsNight() or GetWorld():HasTag("cave") then
			TUNING.VAMPIRE = true
			GetClock():SetNightVision(true)
			player.components.hunger.hungerrate = 2 * TUNING.WILSON_HUNGER_RATE
		else
			if LAN then
			player.components.talker:Say("在白天我不想浪费我的力量。")	
			else
			player.components.talker:Say("I don't want to waste my energy during day time.")	
			end
		end
	elseif not player:HasTag("playerghost") and player.components.shinobu_status.level >= 1 and TUNING.VAMPIRE == true then
		player.components.hunger.hungerrate = 1 * TUNING.WILSON_HUNGER_RATE
		TUNING.VAMPIRE = false
		GetClock():SetNightVision(false)
	end
	end
end

		
local shinobu_handlers = {}
AddPlayerPostInit(function(inst)
	inst:DoTaskInTime(0, function()
		if inst == GetPlayer() then
			if inst.prefab == "shinobu" then
				shinobu_handlers[0] = TheInput:AddKeyDownHandler(KEY_K, function()
					K(GetPlayer())
				end)
				shinobu_handlers[1] = TheInput:AddKeyDownHandler(KEY_L, function()
					L(GetPlayer())
				end)
			else
				shinobu_handlers[0] = nil
				shinobu_handlers[1] = nil
			end
		end
	end)
end)