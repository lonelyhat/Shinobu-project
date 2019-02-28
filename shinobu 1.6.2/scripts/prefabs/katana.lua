--local nightlight = false --1.3.3

local assets= 
{
	Asset("ANIM", "anim/katana.zip"),
	Asset("ANIM", "anim/swap_katana.zip"),
	Asset("ATLAS", "images/inventoryimages/katana.xml"),
}

--item broken
local function onfinished(inst)
    inst:Remove()
end
local prefabs = {
}

--for inspection
local function setString(inst)
    STRINGS.CHARACTERS.GENERIC.DESCRIBE.KATANA = "Lv. "..inst.components.katana_status.level
end


local function onequip(inst, owner)
	owner.AnimState:OverrideSymbol("swap_object","swap_katana", "swap_katana")
	owner.AnimState:Show("ARM_carry")
	owner.AnimState:Hide("ARM_normal")
	setString(inst)
end

--顺风
local function onunequip(inst, owner)
	owner.AnimState:Hide("ARM_carry")
	owner.AnimState:Show("ARM_normal")
end


--打架
local function onattack(inst, attacker, target,skipsanity)
	local chance = 10
	local damage = inst.components.weapon.damage
	if math.random(1,100) <= chance then
		target.components.combat:GetAttacked(attacker, damage)
		local snap = SpawnPrefab("impact")
		snap.Transform:SetScale(3,3,3)
		snap.Transform:SetPosition(target.Transform:GetWorldPosition())
		if target.SoundEmitter ~= nil then
            target.SoundEmitter:PlaySound("dontstarve/common/blackpowder_explo")
        end
    end
	inst.components.katana_status.use = inst.components.finiteuses.current --1.3.0
end


--修复
local function repair(inst)
    local repair = inst.components.finiteuses.current/inst.components.finiteuses.total + .1
	if repair >= 1 then repair = 1 end
    inst.components.finiteuses:SetUses(math.floor(repair*inst.components.finiteuses.total))
    inst.components.katana_status.use = inst.components.finiteuses.current
end

--升级机制
local function valuecheck(inst)
    local level = inst.components.katana_status.level
    local amount = math.floor(level) --for test, should divided by 5
    inst.components.weapon:SetDamage(25+amount)
    inst.components.finiteuses:SetMaxUses(200+level*5)
    inst.components.finiteuses:SetUses(inst.components.katana_status.use)
	--砍树砍竹子速率
    local m = math.ceil(5-level/5)
    if m <= 1 then m = 1 end
    inst.components.tool:SetAction(ACTIONS.CHOP, 5/m)
	if  IsDLCEnabled(CAPY_DLC) then
		inst.components.tool:SetAction(ACTIONS.HACK, 5/m)
	end
end

--物品确认
local function ItemTradeTest(inst, item)
    if item == nil then
        return false
    elseif item.prefab ~= "goldnugget" and item ~= "dubloon" then
        return false
    end
    return true
end

--给物品
local function OnGemGiven(inst, giver, item)
	if inst.components.katana_status.level <= 20 then 
		inst.components.katana_status:DoDeltaLevel(1)
		inst.SoundEmitter:PlaySound("dontstarve/common/telebase_gemplace")
	end
	--1.3.3.1
	valuecheck(inst)
	repair(inst)
	setString(inst)
end

--[[1.3.3
local function Nightlight(inst)
	if not GetClock():IsDay() or GetWorld():HasTag("cave") then
		inst.Light:Enable(true)
		nightlight = true
		inst.components.inventoryitem:SetOnDroppedFn(function() inst.Light:Enable(true) end)
		inst.components.inventoryitem:SetOnPutInInventoryFn(function() inst.Light:Enable(true) end)
    else
        inst.Light:Enable(false)
		nightlight = false
		inst.components.inventoryitem:SetOnDroppedFn(function() inst.Light:Enable(true) end)
		inst.components.inventoryitem:SetOnPutInInventoryFn(function() inst.Light:Enable(false) end)
	end
end]]--



local function fn()
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()
    MakeInventoryPhysics(inst)
    inst.entity:AddSoundEmitter()
	
	if IsDLCEnabled(CAPY_DLC) then
		MakeInventoryFloatable(inst, "idle_water", "idle")
	end
	
	
    anim:SetBank("katana")
    anim:SetBuild("katana")
    anim:PlayAnimation("idle")

    inst:AddTag("katana")
    inst:AddComponent("katana_status")
	
	inst:AddComponent("tool")
    inst.components.tool:SetAction(ACTIONS.CHOP, 1)
	if  IsDLCEnabled(CAPY_DLC) or TUNING.SW_MODE == 3 then 
		inst.components.tool:SetAction(ACTIONS.HACK, 1)
	end
	
	inst:AddComponent("weapon")
    inst.components.weapon:SetDamage(25)
    inst.components.weapon:SetOnAttack(onattack)
    
    inst:AddComponent("inspectable")
    
    inst:AddComponent("inventoryitem")
	inst.components.inventoryitem.atlasname = "images/inventoryimages/katana.xml"

	inst:AddComponent("equippable")
    inst.components.equippable:SetOnEquip(onequip)
    inst.components.equippable:SetOnUnequip(onunequip)
	inst.components.equippable.walkspeedmult = 1 * TUNING.CANE_SPEED_MULT

    inst:AddComponent("finiteuses")
    inst.components.finiteuses:SetMaxUses(200+inst.components.katana_status.level*5)
    inst.components.finiteuses:SetUses(inst.components.katana_status.use)
	inst.components.finiteuses:SetOnFinished(onfinished)

	inst:AddComponent("trader")
    inst.components.trader:SetAcceptTest(ItemTradeTest)
    inst.components.trader.onaccept=OnGemGiven
	
	inst.components.equippable.dapperness = -1*TUNING.CRAZINESS_MED /10 --1.3.1
	
    inst:DoTaskInTime(0, function() valuecheck(inst) end)
	
	
	
	--[[inst:ListenForEvent( "daytime", function() Nightlight(inst) end , GetWorld())
	inst:ListenForEvent( "nighttime", function() Nightlight(inst) end , GetWorld())
	
	if GetClock():IsNight() and nightlight == false or GetWorld():HasTag("cave") and 
	nightlight == false then
		inst:DoTaskInTime(0, function() Nightlight(inst) end , GetWorld())
	elseif not GetClock():IsNight() and nightlight == true or not GetWorld():HasTag("cave") and nightlight== true then
		inst:DoTaskInTime(0, function() Nightlight(inst) end , GetWorld())		
	end]]-- 1.3.3
	
	local light = inst.entity:AddLight() 
	light:SetIntensity(.3) 
	light:SetRadius(4) 
	inst.Light:SetFalloff(0.8)
	light:SetColour(180/255,195/255,150/255)
	light:Enable(false)              
	inst.AnimState:SetBloomEffectHandle( "shaders/anim.ksh" )
	inst.components.inventoryitem:SetOnDroppedFn(function() inst.Light:Enable(true) end)
	
    
    return inst
end
STRINGS.NAMES.KATANA = "katana"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.KATANA = "katana"
return Prefab( "common/inventory/katana", fn, assets) 




