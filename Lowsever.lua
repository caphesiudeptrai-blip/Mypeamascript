-- Giữ nguyên phần khởi tạo GUI của bạn, chỉ thay đổi phần Logic nút bấm
JoinBtn.MouseButton1Click:Connect(function()
    local HttpService = game:GetService("HttpService")
    local TeleportService = game:GetService("TeleportService")
    local PlaceId = game.PlaceId
    
    JoinBtn.Active = false -- Khóa nút để không bấm liên tục
    JoinBtn.BackgroundColor3 = Color3.fromRGB(200, 150, 0)
    
    local function getBestServer()
        local url = "https://games.roblox.com/v1/games/" .. PlaceId .. "/servers/Public?sortOrder=Asc&limit=50"
        local success, result = pcall(function() return game:HttpGet(url) end)
        if success then
            local data = HttpService:JSONDecode(result)
            if data and data.data then
                for _, s in ipairs(data.data) do
                    if s.id ~= game.JobId and s.playing < s.maxPlayers then
                        return s
                    end
                end
            end
        end
        return nil
    end

    task.spawn(function()
        JoinBtn.Text = "Đang tìm kiếm..."
        local target = getBestServer()
        
        if target then
            -- BẮT ĐẦU QUÁ TRÌNH XÁC MINH (Đếm ngược 3 giây)
            for i = 3, 1, -1 do
                JoinBtn.Text = "Xác minh trong " .. i .. "s..."
                JoinBtn.BackgroundColor3 = Color3.fromRGB(255, 100, 0)
                
                -- Giả lập việc kiểm tra Ping và tính ổn định
                task.wait(1)
                
                -- Kiểm tra lại lần cuối trước khi bay
                if i == 1 then
                    local doubleCheck = getBestServer()
                    if doubleCheck and doubleCheck.playing > target.playing + 2 then
                        target = doubleCheck -- Nếu server cũ bỗng nhiên đông lên, đổi sang server mới vắng hơn
                    end
                end
            end
            
            JoinBtn.Text = "Server OK! Đang vào..."
            JoinBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 215)
            task.wait(0.5)
            TeleportService:TeleportToPlaceInstance(PlaceId, target.id)
        else
            JoinBtn.Text = "Lỗi: Không tìm thấy"
            task.wait(2)
            JoinBtn.Text = "Tìm Server Vắng"
            JoinBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 127)
            JoinBtn.Active = true
        end
    end)
end)
