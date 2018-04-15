concommand.Add("UD_ToChatBox", function(ply, command, args)
	local strNewChat = string.gsub(args[1], "_", " ") .. ":"
	args[1] = ""
	chat.AddText(clrPurple, strNewChat .. table.concat(args, " "))
end)

function GM:OnPlayerChat(plySpeaker, strText, boolTeamOnly, boolPlayerIsDead)
	local tblText = string.ToTable(strText)
	local clrPlayerName = clrWhite
	local clrChat = clrWhite
	local boolDisplayName = true
	if plySpeaker == LocalPlayer() then clrPlayerName = clrGray end
	if tblText[1] == "*" and tblText[#tblText] == "*" and #tblText > 2 then clrChat = clrGreen end
	if tblText[#tblText] == "!" and #tblText > 1 then clrChat = clrOrange end
	if tblText[#tblText] == "@" and #tblText > 1 then clrChat = clrCream end
	if boolDisplayName then
		chat.AddText(clrPlayerName, plySpeaker:Nick(), ": ", clrChat,  strText)
	else
		chat.AddText(clrChat, strText)
	end
	return true
end
