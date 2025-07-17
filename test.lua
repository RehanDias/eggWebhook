-- Services
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- HTTP support
local request = http_request or request or nil
local webhookURL = ""

-- Global toggle
getgenv().logHatchEnabled = false
print("✨ Hatch Logger Siap!")

-- Map Pet ke Egg
local petToEggMap = {
	["Dog"] = "Common Egg", ["Golden Lab"] = "Common Egg", ["Bunny"] = "Common Egg",
	["Black Bunny"] = "Uncommon Egg", ["Chicken"] = "Uncommon Egg", ["Cat"] = "Uncommon Egg", ["Deer"] = "Uncommon Egg",
	["Orange Tabby"] = "Rare Egg", ["Spotted Deer"] = "Rare Egg", ["Pig"] = "Rare Egg", ["Rooster"] = "Rare Egg", ["Monkey"] = "Rare Egg",
	["Cow"] = "Legendary Egg", ["Silver Monkey"] = "Legendary Egg", ["Sea Otter"] = "Legendary Egg", ["Turtle"] = "Legendary Egg", ["Polar Bear"] = "Legendary Egg",
	["Grey Mouse"] = "Mythical Egg", ["Brown Mouse"] = "Mythical Egg", ["Squirrel"] = "Mythical Egg", ["Red Giant Ant"] = "Mythical Egg", ["Red Fox"] = "Mythical Egg",
	["Snail"] = "Bug Egg", ["Giant Ant"] = "Bug Egg", ["Caterpillar"] = "Bug Egg", ["Praying Mantis"] = "Bug Egg", ["Dragonfly"] = "Bug Egg",
	["Bee"] = "Bee Egg", ["Honey Bee"] = "Bee Egg", ["Bear Bee"] = "Bee Egg", ["Petal Bee"] = "Bee Egg", ["Queen Bee (Pet)"] = "Bee Egg",
	["Hedgehog"] = "Night Egg", ["Mole"] = "Night Egg", ["Frog"] = "Night Egg", ["Echo Frog"] = "Night Egg", ["Night Owl"] = "Night Egg", ["Raccoon"] = "Night Egg"
}

-- Kirim ke Discord
local function sendToDiscord(petName)
	if not getgenv().logHatchEnabled then return end
	local eggName = petToEggMap[petName] or "❓ Unknown Egg"

	local embed = {
		title = "🐣 Pet Hatched!",
		description = string.format("**Egg:** `%s`\n**Pet:** `%s`", eggName, petName),
		color = tonumber("0x7289DA"),
		footer = { text = "Arcanist Webhook | Hatch Logger" },
		timestamp = DateTime.now():ToIsoDate()
	}

	local payload = {
		username = "Arcanist Webhook",
		embeds = { embed }
	}

	print("📤 Kirim:", petName)

	if request then
		pcall(function()
			request({
				Url = webhookURL,
				Method = "POST",
				Headers = { ["Content-Type"] = "application/json" },
				Body = HttpService:JSONEncode(payload)
			})
		end)
	else
		warn("❌ Executor tidak mendukung 'request()'")
	end
end

-- Hook FireServer
local oldNamecall
oldNamecall = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
	local args = { ... }
	local method = getnamecallmethod()

	if method == "FireServer" then
		local selfName = tostring(self)
		if selfName == "PetEggService" and args[1] == "HatchPet" then
			print("🥚 HatchPet Terdeteksi")
		elseif selfName == "ReplicationChannel" and args[1] == "PetAssets" then
			local petName = tostring(args[2])
			print("🎉 Pet didapat:", petName)
			sendToDiscord(petName)
		end
	end

	return oldNamecall(self, ...)
end))

-- GUI Toggle (Hitam & Ringan)
pcall(function()
	local gui = Instance.new("ScreenGui")
	gui.Name = "HatchLoggerGUI"
	gui.ResetOnSpawn = false
	gui.Parent = LocalPlayer:WaitForChild("PlayerGui")

	local toggleFrame = Instance.new("Frame")
	toggleFrame.Name = "ToggleFrame"
	toggleFrame.Parent = gui
	toggleFrame.Size = UDim2.new(0, 120, 0, 28)
	toggleFrame.Position = UDim2.new(0, 20, 0, 100)
	toggleFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
	toggleFrame.BorderSizePixel = 1
	toggleFrame.Active = true
	toggleFrame.Draggable = true

	local label = Instance.new("TextLabel")
	label.Name = "ToggleLabel"
	label.Parent = toggleFrame
	label.Size = UDim2.new(1, 0, 1, 0)
	label.BackgroundTransparency = 1
	label.Font = Enum.Font.SourceSans
	label.TextColor3 = Color3.new(1, 1, 1)
	label.TextSize = 14
	label.Text = "[OFF] Hatch Logger"

	toggleFrame.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			getgenv().logHatchEnabled = not getgenv().logHatchEnabled
			label.Text = getgenv().logHatchEnabled and "[ON] Hatch Logger" or "[OFF] Hatch Logger"
			print(getgenv().logHatchEnabled and "✅ Logger AKTIF" or "🛑 Logger NONAKTIF")
		end
	end)
end)
