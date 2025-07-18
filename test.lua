--🔧 Services
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

--🔗 Webhook Config
local request = http_request or request or nil
local webhookURL = "" 
getgenv().logHatchEnabled = false
print("✅ Hatch Logger siap digunakan!")

--📦 Pet → Egg Mapping
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

--📨 Kirim Embed ke Discord
local function sendToDiscord(petName)
	if not getgenv().logHatchEnabled then return end

	local eggName = petToEggMap[petName] or "❓ Unknown Egg"
	print("📤 Mengirim data:", petName)

	local embed = {
		title = "🎉 Pet Telah Ditetaskan!",
		description = string.format("🐣 **Egg:** `%s`\n✨ **Pet:** `%s`", eggName, petName),
		color = tonumber("0x00FFFF"),
		footer = { text = "Arcanist Webhook | Hatch Logger" },
		timestamp = DateTime.now():ToIsoDate()
	}

	local payload = {
		username = "Arcanist Webhook",
		embeds = { embed }
	}

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
		warn("❌ Tidak ada fungsi request() pada executor.")
	end
end

--🧠 Hook __namecall untuk deteksi
local oldNamecall
oldNamecall = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
	local args = { ... }
	local method = getnamecallmethod()

	if method == "FireServer" then
		local remote = tostring(self)
		if remote == "PetEggService" and args[1] == "HatchPet" then
			print("🥚 Deteksi hatch pet!")
		elseif remote == "ReplicationChannel" and args[1] == "PetAssets" then
			local petName = tostring(args[2])
			print("✅ Pet berhasil didapat:", petName)
			sendToDiscord(petName)
		end
	end

	return oldNamecall(self, ...)
end))

--🖥️ GUI Toggle
--🖥️ GUI Toggle (Diperbaiki)
pcall(function()
	local gui = Instance.new("ScreenGui")
	gui.Name = "HatchLoggerGUI"
	gui.ResetOnSpawn = false
	gui.Parent = LocalPlayer:WaitForChild("PlayerGui")

	local frame = Instance.new("Frame")
	frame.Size = UDim2.new(0, 160, 0, 40)
	frame.Position = UDim2.new(0, 20, 0, 100)
	frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
	frame.BorderSizePixel = 0
	frame.Active = true
	frame.Draggable = true
	frame.Parent = gui

	local button = Instance.new("TextButton")
	button.Size = UDim2.new(1, 0, 1, 0)
	button.BackgroundTransparency = 1
	button.Font = Enum.Font.GothamBold
	button.TextColor3 = Color3.new(1, 1, 1)
	button.TextSize = 14
	button.Text = "[OFF] Hatch Logger"
	button.AutoButtonColor = false
	button.Parent = frame

	local function updateState()
		local state = getgenv().logHatchEnabled
		button.Text = state and "[ON] Hatch Logger" or "[OFF] Hatch Logger"
		print(state and "🟢 Logger Aktif" or "🔴 Logger Nonaktif")
	end

	button.MouseButton1Click:Connect(function()
		getgenv().logHatchEnabled = not getgenv().logHatchEnabled
		updateState()
	end)

	updateState()
end)
