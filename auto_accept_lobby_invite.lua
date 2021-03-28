-- credits: sapphyrus (https://www.unknowncheats.me/forum/2794104-post11.html)

local js = panorama.open()
local PartyBrowserAPI = js.PartyBrowserAPI 

local xuids = {
    "765611xxxxxxxxxxx", -- example
}

local function joinByLeaderXuid(xuid)
    if PartyBrowserAPI.GetInvitesCount() == 0 then return end
    for i = 0, PartyBrowserAPI.GetInvitesCount() do
        local lobby_xuid = PartyBrowserAPI.GetInviteXuidByIndex(i)
        if tostring(PartyBrowserAPI.GetPartyMemberXuid(lobby_xuid, 0)) == xuid then
            PartyBrowserAPI.ActionJoinParty(lobby_xuid)
            print("Joined lobby of " + lobby_xuid)
        end
    end
end

client.set_event_callback("paint_ui", function() -- 
    for _,v in next, xuids do
        joinByLeaderXuid(v)
    end
end)
