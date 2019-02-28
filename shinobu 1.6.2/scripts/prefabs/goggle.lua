local assets=
{
	Asset("ANIM", "anim/goggle.zip"),
	Asset("ATLAS", "images/inventoryimages/goggle.xml"),
}
local prefabs =
{
}

local function onequip(inst, owner) 
    owner.AnimState:OverrideSymbol("swap_hat", "goggle", "swap_hat")
    owner.AnimState:Show("HAT")
    owner.AnimState:Show("HAIR_HAT")
    owner.AnimState:Hide("HAIR_NOHAT")
    owner.AnimState:Hide("HAIR")
	owner:AddTag("venting")
	owner:AddTag("has_gasmask")--cannot work
end

local function onunequip(inst, owner) 
    owner.AnimState:ClearOverrideSymbol("swap_hat","goggle","swap_hat")
    owner.AnimState:Hide("HAT")
    owner.AnimState:Hide("HAIR_HAT")
    owner.AnimState:Show("HAIR_NOHAT")
    owner.AnimState:Show("HAIR")
	owner:RemoveTag("venting")
	owner:RemoveTag("has_gasmask")
end

local function fn(Sim)
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()
    MakeInventoryPhysics(inst)
    inst.entity:AddSoundEmitter()

	--[[
    if IsDLCEnabled(CAPY_DLC) then
        MakeInventoryFloatable(inst, "idle_water", "idle")
    end
	]]--
    
    inst:AddTag("hat")
	
    anim:SetBank("goggle")
    anim:SetBuild("goggle")
    anim:PlayAnimation("anim")    
        
    inst:AddComponent("inspectable")
    
    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.atlasname = "images/inventoryimages/goggle.xml"
    
    inst:AddComponent("equippable")
    inst.components.equippable.equipslot = EQUIPSLOTS.HEAD
    inst.components.equippable.dapperness = TUNING.DAPPERNESS_MED
    inst.components.equippable:SetOnEquip( onequip )
    inst.components.equippable:SetOnUnequip( onunequip )
	
	--ROG
	inst:AddComponent("heater")
	inst.components.heater.iscooler = true
	inst.components.heater.equippedheat = TUNING.WATERMELON_COOLER
	--ROG
    inst:AddComponent("insulator")
	inst.components.insulator:SetInsulation(TUNING.INSULATION_MED)
	inst.components.insulator:SetSummer()
	
    inst.components.insulator:SetInsulation(TUNING.INSULATION_MED)
	inst.components.equippable.walkspeedmult = 1 * TUNING.CANE_SPEED_MULT
	
	--1.6.1
	inst:AddComponent("armor")
	inst.components.armor:InitCondition(TUNING.ARMOR_FOOTBALLHAT*2, TUNING.ARMOR_FOOTBALLHAT_ABSORPTION)
	--special function only for hamlet
	if IsDLCEnabled(CAPY_DLC) or TUNING.SW_MODE == 3 then
	inst.components.equippable.poisonblocker = true
	end
	inst:AddTag("fogproof")
	inst:AddTag("gasmask")
	inst:AddComponent("waterproofer")
	inst.components.waterproofer:SetEffectiveness(TUNING.WATERPROOFNESS_MED)
	if TUNING.SW_MODE == 3 then
	inst.components.equippable.poisongasblocker = true
	end
    return inst
end
STRINGS.NAMES.GOGGLE = "Goggle"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.GOGGLE = "Goggle"
return Prefab( "common/inventory/goggle", fn, assets) 
