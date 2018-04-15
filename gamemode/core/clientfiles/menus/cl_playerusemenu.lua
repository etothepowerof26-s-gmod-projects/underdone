concommand.Add("UD_PlayerUseMenu", function(ply, command, args)
	if not args then return end
	if not args[1] then return end
	gui.EnableScreenClicker(true)
	local OtherPlayer = ents.GetByIndex(args[1])
	if IsValid(OtherPlayer) then
		local MenuOptions = DermaMenu()
		if LocalPlayer().IsFollowingPlayer then
			 MenuOptions:AddOption("Stop Following", function()
				gui.EnableScreenClicker(false)
				ply:ConCommand("UD_StopFollowingPlayer")
			end )
		else
			 MenuOptions:AddOption("Follow", function()
				gui.EnableScreenClicker(false)
				ply:ConCommand("UD_FollowPlayer " .. OtherPlayer:EntIndex())
			end )
		end
		MenuOptions:Open()
	end
end)
