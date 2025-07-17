-- Services
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- HTTP request support
local request = http_request or request or nil

-- Webhook URL 
local webhookURL = ""

-- Global toggle
getgenv().logHatchEnabled = false

print("✨ Hatch Logger Aktif!")

-- Mapping nama pet ke nama egg
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

-- Kirim embed ke Discord
local function sendToDiscord(petName)
	if not getgenv().logHatchEnabled then return end

	local eggName = petToEggMap[petName] or "❓ Unknown Egg"

	local embed = {
		title = "🐣 Pet Hatched!",
		description = string.format("**Egg:** `%s`\n**Pet:** `%s`", eggName, petName),
		color = 0x7289DA, -- Discord blurple
		footer = {
			text = "Arcanist Webhook | Hatch Logger"
		},
		timestamp = DateTime.now():ToIsoDate()
	}

	local payload = {
		username = "Arcanist Webhook",
		embeds = { embed }
	}

	print("📤 Mengirim embed:", petName)

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
		warn("❌ Executor tidak support 'request()'")
	end
end

-- Hook FireServer untuk deteksi Hatch
local oldNamecall
oldNamecall = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
	local args = { ... }
	local method = getnamecallmethod()

	if method == "FireServer" then
		if tostring(self) == "PetEggService" and args[1] == "HatchPet" then
			print("🥚 HatchPet Terdeteksi")
		elseif tostring(self) == "ReplicationChannel" and args[1] == "PetAssets" then
			local petName = tostring(args[2])
			print("🎉 Pet didapat:", petName)
			sendToDiscord(petName)
		end
	end

	return oldNamecall(self, ...)
end))

-- GUI Toggle
pcall(function()
	local gui = Instance.new("ScreenGui")
	gui.Name = "HatchLoggerGUI"
	gui.ResetOnSpawn = false
	gui.Parent = LocalPlayer:WaitForChild("PlayerGui")

	local button = Instance.new("TextButton")
	button.Name = "ToggleButton"
	button.Parent = gui
	button.Size = UDim2.new(0, 150, 0, 40)
	button.Position = UDim2.new(0, 20, 0, 100)
	button.BackgroundColor3 = Color3.fromRGB(231, 76, 60)
	button.Font = Enum.Font.GothamBold
	button.TextColor3 = Color3.new(1, 1, 1)
	button.TextSize = 16
	button.Text = "[OFF] Hatch Logger"
	button.Draggable = true
	button.Active = true

	local function updateButton()
		if getgenv().logHatchEnabled then
			button.Text = "[ON] Hatch Logger"
			button.BackgroundColor3 = Color3.fromRGB(46, 204, 113)
			print("✅ Logger DIHIDUPKAN")
		else
			button.Text = "[OFF] Hatch Logger"
			button.BackgroundColor3 = Color3.fromRGB(231, 76, 60)
			print("🛑 Logger DIMATIKAN")
		end
	end

	button.MouseButton1Click:Connect(function()
		getgenv().logHatchEnabled = not getgenv().logHatchEnabled
		updateButton()
	end)
end)
