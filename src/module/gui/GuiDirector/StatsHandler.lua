local TweenService = game:GetService("TweenService")
local tInfo  = TweenInfo.new(0.5)

return function(stats)
	local header = stats.Header
	local open = stats.Table.Visible

	header.InputBegan:Connect(function(input) 
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			open = not open
			TweenService:Create(header.Arrow, tInfo, {Rotation = open and 90 or 0}):Play()
			stats.Table.Visible = open
		end
	end)
	print("stat handled")
	return stats
end