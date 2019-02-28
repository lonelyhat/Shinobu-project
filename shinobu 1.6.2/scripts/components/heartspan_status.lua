local heartspan_status = Class(function(self, inst)
    self.inst = inst
    self.level = 0
	self.exp = 0 
	self.maxexp = 100
	self.damage = 60
	self.use = 200
end,
nil,
{
})

function heartspan_status:OnSave()
    local data = {
        level = self.level,
        exp = self.exp,
        damage = self.damage,
		use = self.use
    }
    return data
end

function heartspan_status:OnLoad(data)
    self.level = data.level or 0
    self.exp = data.exp or 0
	self.maxexp = data.exp or (100 + self.level*200)
	self.damage = data.damage or (60 + math.floor(self.level/2))
	self.use = data.use or 200
end

function heartspan_status:DoDeltaX(delta)
    self.exp = self.exp + delta
    self.inst:PushEvent("DoDeltaExpHEARTSPAN")
end


return heartspan_status