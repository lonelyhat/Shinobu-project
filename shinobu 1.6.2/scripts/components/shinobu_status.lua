local shinobu_status = Class(function(self, inst)
    self.inst = inst
    self.level = 0--change!
    self.exp = 0
    self.expold = 0
    self.maxexp = 0
    self.speedwalk = 7
    self.speedrun = 7
    self.chunger = 75
    self.csanity = 100
    self.chealth = 75
end,
nil,
{
})

function shinobu_status:OnSave()
    local data = {
		level = self.level,
        exp = self.exp,
        chunger = self.chunger,
        csanity = self.csanity,
        chealth = self.chealth,
    }
    return data
end

function shinobu_status:OnLoad(data)
    self.level = data.level or 0
    self.exp = data.exp or 0
    self.chunger = data.chunger or math.ceil(75 + self.level*225/100)
    self.csanity = data.csanity or math.ceil(100 + self.level*3)
    self.chealth = data.chealth or math.ceil(75 + self.level*225/100)
	
end

function shinobu_status:DoDeltaExp(delta)
	self.expold = self.exp
    self.exp = self.exp + delta
	--print("dodelta")
    self.inst:PushEvent("DoDeltaExpSHINOBU")
end


function shinobu_status:onstatuschange()
    self.inst:ListenForEvent("hungerdelta", function()
        self.chunger = self.inst.components.hunger.current
    end)
    self.inst:ListenForEvent("sanitydelta", function()
        self.csanity = self.inst.components.sanity.current
    end)
    self.inst:ListenForEvent("healthdelta", function()
        self.chealth = self.inst.components.health.currenthealth
    end)
end

return shinobu_status