local katana_status = Class(function(self, inst)
    self.inst = inst
    self.level = 0--REMEMBER TO CHANGE BACK 
    self.use = 200
	self.maxlv = 25
end,
nil,
{
})

function katana_status:OnSave()
    local data = {
        level = self.level,
        use = self.use,
		
    }
    return data
end

function katana_status:OnLoad(data)
    self.level = data.level or 0
    self.use = data.use or 200
end

function katana_status:DoDeltaLevel(delta)
	if self.level < self.maxlv then
		self.level = self.level + delta
	end
end

return katana_status