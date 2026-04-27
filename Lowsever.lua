local ScreenGui = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local Title = Instance.new("TextLabel")
local JoinBtn = Instance.new("TextButton")

-- Xóa bản cũ
if game.CoreGui:FindFirstChild("LowServerGUI_Delta") then
    game.CoreGui["LowServerGUI_Delta"]:Destroy()
end

-- THIẾT LẬP GIAO DIỆN
ScreenGui.Name = "LowServerGUI_Delta"
ScreenGui.Parent = game.CoreGui
ScreenGui.ResetOnSpawn = false

MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MainFrame.Position = UDim2.new(0.5, -100, 0.5, -50)
MainFrame.Size = UDim2.new(0, 200, 0, 100)
MainFrame.Active = true
MainFrame.Draggable = true 

local MainCorner = Instance.new("UICorner", MainFrame)
MainCorner.CornerRadius = UDim.new(0, 10)

Title.Parent = MainFrame
Title.Size = UDim2.new(1, 0, 0.4, 0)
Title.Text = "SMART SERVER FINDER"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.BackgroundTransparency = 1
Title.Font = Enum.Font.GothamBold
Title.TextSize = 14

JoinBtn.Parent = MainFrame
JoinBtn.Name = "JoinButton"
JoinBtn.Position = UDim2.new(0.1, 0, 0.5, 0)
JoinBtn.Size = UDim2.new(0.8, 0, 0.35, 0)
JoinBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 127)
JoinBtn.Text = "Tìm Server Vắng"
JoinBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
JoinBtn.Font = Enum.Font.GothamBold
JoinBtn.TextSize = 14
Instance.new("UICorner", JoinBtn).CornerRadius = UDim.new(0, 8)

-- ANTI-AFK NGẦM
local VirtualUser = game:GetService("VirtualUser")
game:GetService("Players").LocalPlayer.Idled:Connect(function()
    VirtualUser:CaptureController()
    VirtualUser:ClickButton2(Vector2.new())
end)

-- LOGIC TÌM SERVER THÔNG MINH
JoinBtn.MouseButton1Click:Connect(function()
    local HttpService = game:GetService("HttpService")
    local TeleportService = game:GetService("TeleportService")
    local Players = game:GetService("Players")
    local PlaceId = game.PlaceId
    
    if JoinBtn.Active == false then return end
    JoinBtn.Active = false 
    JoinBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    
    task.spawn(function()
        local bestServer = nil
        local minPlayers = math.huge
        local cursor = ""
        local currentCount = #Players:GetPlayers() -- Số người hiện tại trong server bạn
        
        -- Bước 1: Quét sâu tìm server mục tiêu
        for i = 1, 3 do
            JoinBtn.Text = "Đang quét: " .. (i * 100)
            local url = "https://games.roblox.com/v1/games/" .. PlaceId .. "/servers/Public?sortOrder=Asc&limit=100&cursor=" .. cursor
            local success, result = pcall(function() return game:HttpGet(url) end)
            
            if success then
                local data = HttpService:JSONDecode(result)
                if data and data.data then
                    for _, s in ipairs(data.data) do
                        local pCount = tonumber(s.playing)
                        if s.id ~= game.JobId and pCount < s.maxPlayers then
                            if pCount < minPlayers then
                                minPlayers = pCount
                                bestServer = s
                            end
                        end
                    end
                    if not data.nextPageCursor then break end
                    cursor = data.nextPageCursor
                end
            end
            task.wait(0.05)
        end

        -- Bước 2: So sánh thông minh
        if bestServer then
            -- NẾU SERVER TÌM ĐƯỢC KHÔNG VẮNG HƠN SERVER HIỆN TẠI BAO NHIÊU
            -- Hoặc nếu server hiện tại đã dưới 5 người (mức rất ít)
            if currentCount <= minPlayers or currentCount <= 3 then
                JoinBtn.BackgroundColor3 = Color3.fromRGB(200, 0, 0) -- Màu đỏ cảnh báo
                JoinBtn.Text = "SERVER HIỆN TẠI ÍT"
                task.wait(3)
                JoinBtn.Text = "Tìm Server Vắng"
                JoinBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 127)
                JoinBtn.Active = true
            else
                -- Nếu server kia thực sự vắng hơn thì mới đi
                JoinBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 215)
                JoinBtn.Text = "Tìm thấy: " .. minPlayers .. " người"
                task.wait(1.5)

                for i = 3, 1, -1 do
                    JoinBtn.BackgroundColor3 = Color3.fromRGB(200, 150, 0)
                    JoinBtn.Text = "Xác minh: " .. i .. "s..."
                    task.wait(1)
                end
                
                JoinBtn.Text = "Đang vào..."
                TeleportService:TeleportToPlaceInstance(PlaceId, bestServer.id)
            end
        else
            JoinBtn.Text = "Không có server tốt hơn!"
            task.wait(2)
            JoinBtn.Text = "Tìm Server Vắng"
            JoinBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 127)
            JoinBtn.Active = true
        end
    end)
end)
