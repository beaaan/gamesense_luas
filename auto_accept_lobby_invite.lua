local js = panorama.open()
local PartyBrowserAPI, FriendsListAPI = js.PartyBrowserAPI, js.FriendsListAPI

local xuids = database.read("xuids") or {}

client.set_event_callback("console_input", function(cmd)
	if cmd:sub(1, 8) == "add_xuid" then
		if cmd:len() > 9 then
			local xuid = cmd:sub(10, -1)
			local source = "steamid64"

			-- basic "possibly a friend code" check
			if xuid:len() == 10 and xuid:sub(6, 6) == "-" then
				xuid = FriendsListAPI.GetXuidFromFriendCode(xuid)
				source = "friendcode"
            elseif xuid:find("^https://steamcommunity.com/profiles/") then
				xuid = xuid:gsub("https://steamcommunity.com/profiles/", "")
			end

			-- very basic check if its a valid steamid64
			if type(xuid) == "string" and xuid:len() == 17 and xuid:sub(1, 3) == "765" then
				table.insert(xuids, xuid)
                database.write("xuids", xuids)
			else
				client.error_log("Please enter a valid steam64 id or friendcode")
			end
		end

		return true
	elseif cmd:sub(1, 9) == "list_xuid" then
        for _,v in next, xuids do
            print(v)
        end
        return true
    elseif cmd:sub(1, 11) == "remove_xuid" then
        if cmd:len() > 12 then
            local xuid = cmd:sub(13, -1)
            if xuid == "all" then
                xuids = {}
                database.write("xuids", xuids)
            else
                for _,v in next, xuids do
                    if v == xuid then
                        table.remove(xuids, _)
                        database.write("xuids", xuids)
                    end
                end
            end
        end
    end
end)

local function joinByLeaderXuid(xuid)
    if PartyBrowserAPI.GetInvitesCount() == 0 then return end
    for i = 0, PartyBrowserAPI.GetInvitesCount() do
        local lobby_xuid = PartyBrowserAPI.GetInviteXuidByIndex(i)
        if tostring(PartyBrowserAPI.GetPartyMemberXuid(lobby_xuid, 0)) == xuid then
            PartyBrowserAPI.ActionJoinParty(lobby_xuid)
        end
    end
end

client.set_event_callback("paint_ui", function()
    if not entity.get_local_player() and not entity.get_game_rules() then
        for _,v in next, xuids do
            joinByLeaderXuid(v)
        end
    end
end)
