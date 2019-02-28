--doughnut
assets =
{
	Asset("ANIM", "anim/doughnut.zip"),
	Asset("IMAGE", "images/inventoryimages/doughnut.tex"),
	Asset("ATLAS", "images/inventoryimages/doughnut.xml"),
}
local prefabs = 
	{
	"spoiled_food"
	}


local function fn()
	local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    MakeInventoryPhysics(inst)
	
    inst.AnimState:SetBank("doughnut")
    inst.AnimState:SetBuild("doughnut")
    inst.AnimState:PlayAnimation("idle")

	if IsDLCEnabled(CAPY_DLC) then 
    MakeBlowInHurricane(inst, TUNING.WINDBLOWN_SCALE_MIN.MEDIUM, TUNING.WINDBLOWN_SCALE_MAX.MEDIUM)
    end
	
	inst:AddComponent("inspectable")

    inst:AddComponent("stackable")
    inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM
	
	inst:AddComponent("inventoryitem")
	inst.components.inventoryitem.atlasname = "images/inventoryimages/doughnut.xml"
	
	inst:AddComponent("tradable")
	
	inst:AddComponent("edible")
	inst.components.edible.hungervalue = 20
	inst.components.edible.sanityvalue = 50
	inst.components.edible.foodtype = "VEGGIE"
	
	inst:AddComponent("perishable")
	inst.components.perishable:SetPerishTime(TUNING.PERISH_PRESERVED*4)
	inst.components.perishable:StartPerishing()
	inst.components.perishable.onperishreplacement = "spoiled_food"
	
	return inst
end
STRINGS.NAMES.DOUGHNUT = "Mister Donut"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.DOUGHNUT = "Mister Donut"
return Prefab( "common/inventory/doughnut", fn, assets, prefabs)