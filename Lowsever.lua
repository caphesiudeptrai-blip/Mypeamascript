local ScreenGui = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local Title = Instance.new("TextLabel")
local JoinBtn = Instance.new("TextButton")

-- Xóa bản cũ nếu người dùng chạy lại script
if game.CoreGui:FindFirstChild("LowServerGUI_Delta") then
    game.CoreGui["LowServerGUI_Delta"]:Destroy()
end

-- Thiết lập Giao diện chuẩn
ScreenGui.Name = "LowServerGUI_Delta"
ScreenGui.Parent = game.CoreGui

MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30) -- Màu tối chuyên nghiệp
MainFrame.Position = UDim2.new(0.5, -100, 0.5, -50)
MainFrame.Size = UDim2.new(0, 200, 0, 100)
MainFrame.Active = true
MainFrame.Draggable = true -- Có thể kéo di chuyển trên màn hình

local MainCorner = Instance.new("UICorner", MainFrame)
MainCorner.CornerRadius = UDim.new(0, 10)

Title.Parent = MainFrame
Title.Size = UDim2.new(1, 0, 0.4, 0)
Title.Text = "DEEP SERVER FINDER"
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
JoinBtn.Font = Enum.Font.Gotham
JoinBtn.TextSize = 14
Instance.new("UICorner", JoinBtn).CornerRadius = UDim.new(0, 8)

-- Logic tìm Server Hoàn Hảo
JoinBtn.MouseButton1Click:Connect(function()
    local HttpService = game:GetService("HttpService")
    local TeleportService = game:GetService("TeleportService")
    local PlaceId = game.PlaceId
    
    JoinBtn.Active = false -- Chống bấm liên tục
    JoinBtn.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
    
    task.spawn(function()
        local bestServer = nil
        local minPlayers = math.huge
        local cursor = ""
        
        -- BƯỚC 1: QUÉT SÂU (Quét 3 trang = 300 server để tìm mục tiêu tốt nhất)
        for i = 1, 3 do
            JoinBtn.Text = "Đang quét: " .. (i * 100) .. "+"
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
                    if data.nextPageCursor then cursor = data.nextPageCursor else break end
                end
            end
            task.wait(0.1)
        end

        -- BƯỚC 2: XÁC MINH (Đếm ngược để chắc chắn server ổn định)
        if bestServer then
            for i = 3, 1, -1 do
                JoinBtn.BackgroundColor3 = Color3.fromRGB(200, 150, 0) -- Màu cam xác minh
                JoinBtn.Text = "Xác minh: " .. i .. "s..."
                task.wait(1)
            end
            
            -- Kiểm tra lại lần cuối (Double Check)
            JoinBtn.Text = "OK! Đang vào..."
            JoinBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 215) -- Màu xanh dương khi bay
            task.wait(0.5)
            TeleportService:TeleportToPlaceInstance(PlaceId, bestServer.id)
        else
            JoinBtn.Text = "Không tìm thấy!"
            task.wait(2)
            JoinBtn.Text = "Tìm Server Vắng"
            JoinBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 127)
            JoinBtn.Active = true
        end
    end)
end)
