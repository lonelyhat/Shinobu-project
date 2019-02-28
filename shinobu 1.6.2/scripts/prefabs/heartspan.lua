local nightlight = false

local assets= 
{
	Asset("ANIM", "anim/heartspan.zip"),
	Asset("ANIM", "anim/swap_heartspan.zip"),
	Asset("ATLAS", "images/inventoryimages/heartspan.xml"),
}

local prefabs = {
}

local function valuecheck(inst)
	--升级机制
    local lv = inst.components.heartspan_status.level
	--print("checked!")
	inst.components.heartspan_status.maxexp = lv * 200 + 100
	inst.components.heartspan_status.damage = math.floor(lv/2) + 60
    inst.components.weapon:SetDamage(inst.components.heartspan_status.damage)
	--砍树砍竹子速率
    local m = math.ceil(11-lv/100*11)
    if m <= 1 then m = 1 end
    inst.components.tool:SetAction(ACTIONS.CHOP, 4+11/m)
	if IsDLCEnabled(CAPY_DLC) then
		inst.components.tool:SetAction(ACTIONS.HACK, 4+11/m)
	end
	if TUNING.HEARTSPAN == true then
	inst.components.tool:SetAction(ACTIONS.HAMMER, 4+11/m)
	end
end

local function onkill(inst, data)
	local victim = data.victim
	if victim.components.freezable or victim:HasTag("monster") and victim.components.health then
		local value = math.ceil(victim.components.health.maxhealth * 2) --记得改回两倍
		inst.components.heartspan_status:DoDeltaX(value) 
	end
end


local function onequip(inst, owner)
	owner.AnimState:OverrideSymbol("swap_object","swap_heartspan", "swap_heartspan")
	owner.AnimState:Show("ARM_carry")
	owner.AnimState:Hide("ARM_normal")
end

local function onunequip(inst, owner)
	owner.AnimState:Hide("ARM_carry")
	owner.AnimState:Show("ARM_normal")
end

--1.4.0
local function onattack(inst, attacker, target) --Not sure why need to write "skipsanity", just follow otehrs 
	if attacker.components.sanity:GetPercent()>= 0.2 or TUNING.GOO < 3 then
	local chance = 25 
	local lv = inst.components.heartspan_status.level
	if math.random(1,100) <= chance then
		target.components.combat:GetAttacked(attacker, inst.components.heartspan_status.damage)
		local snap = SpawnPrefab("impact")
		snap.Transform:SetScale(3,3,3)
		snap.Transform:SetPosition(target.Transform:GetWorldPosition())
		if target.SoundEmitter ~= nil then
            target.SoundEmitter:PlaySound("dontstarve/common/blackpowder_explo")
        end
    end
	if inst.components.finiteuses then
    	inst.components.heartspan_status.use = inst.components.finiteuses.current
    end
	if attacker.components.health and attacker.components.health:GetPercent() < 1 and not target:HasTag("wall") then
        attacker.components.health:DoDelta(10,false,"heartspan") -- 随等级升高
		if TUNING.GOO >= 3 then
        attacker.components.sanity:DoDelta(-5) 
		end
	else
		if TUNING.GOO >= 3 then
		attacker.components.sanity:DoDelta(-5) 
		end
    end
	--The power of Thor!
	if target and target.components.health and not target.components.health:IsDead() and lv >= 30 and math.random(1,100)<20 then
		local pos = target:GetPosition()
		SpawnPrefab("lightning").Transform:SetPosition(pos.x,pos.y,pos.z)
		target.components.health:DoDelta(-30)
	end
	elseif attacker.components.sanity:GetPercent()< 0.15 and TUNING.GOO >= 3 then
		if attacker.components.health then
			attacker.components.sanity:DoDelta(-5) 
			attacker.components.health:DoDelta(-10,false,"heartspan")
		end
	end
end

--1.4.0
local function repair(inst)
    local repair = inst.components.finiteuses.current/inst.components.finiteuses.total + .2
    if repair >= 1 then repair = 1 end
    inst.components.finiteuses:SetUses(math.floor(repair*inst.components.finiteuses.total))
    inst.components.heartspan_status.use = inst.components.finiteuses.current
end

local function level_up(inst)
	inst.components.heartspan_status.level = inst.components.heartspan_status.level +1
	inst.SoundEmitter:PlaySound("dontstarve/characters/wx78/levelup")
	valuecheck(inst)
end

local function DoDeltaExpHEARTSPAN(inst)
	if inst.components.heartspan_status.exp < inst.components.heartspan_status.maxexp then
	end
	if inst.components.heartspan_status.exp >= inst.components.heartspan_status.maxexp then
		level_up(inst)
		local expnew = inst.components.heartspan_status.exp - inst.components.heartspan_status.maxexp
		inst.components.heartspan_status.exp = 0
		if expnew > 0 then
			inst.components.heartspan_status:DoDeltaX(expnew)
		end
	end
end



local function ItemTradeTest(inst, item)
    if item == nil then
        return false
    elseif item.prefab == "nightmarefuel" then
        return true
    end
    return false
end


local function OnGemGiven(inst, giver, item)
	inst.components.heartspan_status:DoDeltaX(1000)
    inst.SoundEmitter:PlaySound("dontstarve/common/telebase_gemplace")
	if TUNING.GOO == 5 then
        repair(inst)
    end
    valuecheck(inst)
end

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
end


local function fn()
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()
    MakeInventoryPhysics(inst)
    inst.entity:AddSoundEmitter()
	if IsDLCEnabled(CAPY_DLC) then
		MakeInventoryFloatable(inst, "idle_water", "idle")
	end
	
    anim:SetBank("heartspan")
    anim:SetBuild("heartspan")
    anim:PlayAnimation("idle")

    inst:AddTag("heartspan")
	inst:AddTag("sharp")

    inst:AddComponent("heartspan_status")
	
	inst:AddComponent("tool")
    inst.components.tool:SetAction(ACTIONS.CHOP, 4)
	
	if  IsDLCEnabled(CAPY_DLC) then 
		inst.components.tool:SetAction(ACTIONS.HACK, 4)
	end
	if TUNING.SW_MODE == 3 then  --1.3.3.1 
		inst.components.tool:SetAction(ACTIONS.SHEAR) 
	end
	
	inst:AddComponent("weapon")
    inst.components.weapon:SetDamage(60)
    inst.components.weapon:SetOnAttack(onattack)
    
    inst:AddComponent("inspectable")
    
    inst:AddComponent("inventoryitem")
	inst.components.inventoryitem.atlasname = "images/inventoryimages/heartspan.xml"

	inst:AddComponent("equippable")
    inst.components.equippable:SetOnEquip( onequip )
    inst.components.equippable:SetOnUnequip( onunequip )
	inst.components.equippable.walkspeedmult = 1.5 * TUNING.CANE_SPEED_MULT

	--1.4.0
	if TUNING.GOO == 5 then
	inst:AddComponent("finiteuses")
    inst.components.finiteuses:SetMaxUses(200)
    inst.components.finiteuses:SetUses(inst.components.heartspan_status.use)
	if TUNING.GOO == 5 then
		inst.components.finiteuses:SetOnFinished(function() inst:Remove()end)
	end
	end
	
	inst:AddComponent("trader")
    inst.components.trader:SetAcceptTest(ItemTradeTest)
    inst.components.trader.onaccept = OnGemGiven
	
    inst:DoTaskInTime(0, function() valuecheck(inst) end)
	if TUNING.GOO >= 3 then
		inst.components.equippable.dapperness = TUNING.CRAZINESS_MED /2.5 
	end
	inst:ListenForEvent("DoDeltaExpHEARTSPAN", DoDeltaExpHEARTSPAN)
	
	inst:ListenForEvent( "daytime", function() Nightlight(inst) end , GetWorld())
	inst:ListenForEvent( "nighttime", function() Nightlight(inst) end , GetWorld())
	
	if GetClock():IsNight() and nightlight == false or GetWorld():HasTag("cave") and 
	nightlight == false then
		inst:DoTaskInTime(0, function() Nightlight(inst) end , GetWorld())
	elseif not GetClock():IsNight() and nightlight == true or not GetWorld():HasTag("cave") and nightlight== true then
		inst:DoTaskInTime(0, function() Nightlight(inst) end , GetWorld())		
	end
	
	--自带特效
	local light = inst.entity:AddLight() 
	light:SetIntensity(.7) 
	light:SetRadius(4) 
	inst.Light:SetFalloff(0.6)
	light:SetColour(246/255,0/255,133/255) --酒红色
	light:Enable(false)              
	inst.AnimState:SetBloomEffectHandle( "shaders/anim.ksh" )
    return inst
end

STRINGS.NAMES.HEARTSPAN = "Heartspan"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.HEARTSPAN = "Heartspan"

return Prefab( "common/inventory/heartspan", fn, assets) 




