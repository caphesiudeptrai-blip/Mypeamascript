local ScreenGui = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local Title = Instance.new("TextLabel")
local JoinBtn = Instance.new("TextButton")

-- Tự động xóa bản cũ nếu bạn chạy script nhiều lần
if game.CoreGui:FindFirstChild("LowServerGUI_Delta") then
    game.CoreGui["LowServerGUI_Delta"]:Destroy()
end

-- Thiết lập Giao diện (Giữ nguyên style của bạn)
ScreenGui.Name = "LowServerGUI_Delta"
ScreenGui.Parent = game.CoreGui

MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
MainFrame.Position = UDim2.new(0.5, -100, 0.5, -50)
MainFrame.Size = UDim2.new(0, 200, 0, 100)
MainFrame.Active = true
MainFrame.Draggable = true -- Hỗ trợ di chuyển trên Delta

local MainCorner = Instance.new("UICorner", MainFrame)
MainCorner.CornerRadius = UDim.new(0, 10)

Title.Parent = MainFrame
Title.Size = UDim2.new(1, 0, 0.4, 0)
Title.Text = "Low Server Finder"
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

local BtnCorner = Instance.new("UICorner", JoinBtn)
BtnCorner.CornerRadius = UDim.new(0, 8)

-- Logic tìm Server tối ưu
JoinBtn.MouseButton1Click:Connect(function()
    local HttpService = game:GetService("HttpService")
    local TeleportService = game:GetService("TeleportService")
    local PlaceId = game.PlaceId
    
    JoinBtn.Text = "Đang quét..."
    JoinBtn.BackgroundColor3 = Color3.fromRGB(100, 100, 100)

    -- Hàm xử lý quét server
    local function findServer()
        -- Sử dụng Cursor để quét sâu hơn nếu server đầu tiên không vắng
        local url = "https://games.roblox.com/v1/games/" .. PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"
        
        local success, result = pcall(function()
            return game:HttpGet(url)
        end)
        
        if success then
            local data = HttpService:JSONDecode(result)
            if data and data.data then
                local targetServer = nil
                
                for _, server in ipairs(data.data) do
                    -- Điều kiện: Không phải server đang chơi và còn chỗ
                    if server.id ~= game.JobId and tonumber(server.playing) < tonumber(server.maxPlayers) then
                        targetServer = server
                        break -- Lấy ngay server ít người nhất đứng đầu danh sách
                    end
                end
                
                if targetServer then
                    JoinBtn.Text = "Đang vào (" .. targetServer.playing .. " người)"
                    JoinBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 215)
                    TeleportService:TeleportToPlaceInstance(PlaceId, targetServer.id)
                else
                    JoinBtn.Text = "Không tìm thấy!"
                end
            end
        else
            JoinBtn.Text = "Lỗi API!"
        end
        
        -- Reset nút sau 3 giây nếu không teleport được
        task.wait(3)
        JoinBtn.Text = "Tìm Server Vắng"
        JoinBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 127)
    end
    
    findServer()
end)
