-- Created by Validark
-- Place functions inside table `Functions` and watch the magic happen!
-- Run this with identical functions a couple times so you can see how much noise you can expect in a test like this
-- Will error if it doesn't have at least one function inside `Functions`
-- Each function will run in turn until one has run for over TIME_THRESHOLD total
-- This means that your code may take (TIME_THRESHOLD seconds * #Functions)

local TIME_THRESHOLD = 1
local TITLE_TEXT = "tick vs os.time"

local Functions = {}

Functions["tick"] = function()
	return tick()
end

Functions["os.time"] = function()
	return os.time()
end

local localtick = tick
Functions["local tick"] = function()
	return localtick()
end

local localos_time = os.time
Functions["local os.time"] = function()
	return localos_time()
end

do
	local tick = tick
	local TimesArray = setmetatable({}, {__index = table})
	local NumFunctions = 0

	for Name, Function in next, Functions do
		NumFunctions = NumFunctions + 1
		TimesArray:insert{Time = 0; Name = Name; Function = Function}
	end

	repeat
		local Time
		for i = 1, NumFunctions do
			local Data = TimesArray[i]
			local Function = Data.Function
			local OldTime = Data.Time

			local StartTime = tick()
			Function()
			Time = tick() - StartTime + OldTime
			Data.Time = Time
		end
	until Time > TIME_THRESHOLD

	local LongestNameLength = 0

	local FONT_SIZE = 20
	local FONT = Enum.Font.SourceSansBold
	local TextService = game:GetService("TextService")

	for _, Data in next, TimesArray do
		local NameLength = TextService:GetTextSize((" "):rep(10) .. Data.Name, FONT_SIZE, FONT, Vector2.new(FONT_SIZE * 10, FONT_SIZE + 16)).X
		if NameLength > LongestNameLength then
			LongestNameLength = NameLength
		end
	end

	TimesArray:sort(function(a, b)
		return a.Time < b.Time
	end)

	print(TimesArray[1].Name, "is", ("%.2f%%"):format(100 - (100 * (TimesArray[1].Time / TimesArray[#TimesArray].Time))), "faster than", TimesArray[#TimesArray].Name)

	local function GetFirstChild(Parent, Name, Class, Value)
		if Parent then
			local Guess = Parent:FindFirstChild(Name)
			if Guess then
				if Guess.ClassName == Class then
					if Value ~= nil then
						Guess.Value = Value
					end
					return Guess
				else -- GetFirstChildWithNameOfClass with Value
					local Objects = Parent:GetChildren()
					for a = 1, #Objects do
						local Object = Objects[a]
						if Object.Name == Name and Object.ClassName == Class then
							if Value ~= nil then
								Object.Value = Value
							end
							return Object
						end
					end
				end
			end
		end

		local Child = Instance.new(Class)
		Child.Name = Name
		if Value ~= nil then
			Child.Value = Value
		end
		Child.Parent = Parent
		return Child, true
	end

	local Screen = GetFirstChild(game:GetService("StarterGui"), "SpeedTestScreen", "ScreenGui")
	Screen.DisplayOrder = 2 ^ 31 - 1

	local Backdrop = GetFirstChild(Screen, "Backdrop", "Frame")
	Backdrop.Size = UDim2.new(1, 0, 1, 0)
	Backdrop.BackgroundColor3 = Color3.fromRGB(255, 255, 255)

	Backdrop:ClearAllChildren()

	for Order, Data in next, TimesArray do
		local Name = Data.Name
		local Time = Data.Time

		local Label = Instance.new("TextLabel")
		Label.BackgroundTransparency = 1
		Label.Size = UDim2.new(0, LongestNameLength, 0, FONT_SIZE)
		Label.Font = FONT
		Label.Text = (" "):rep(10) .. Name
		Label.TextSize = FONT_SIZE
		Label.TextXAlignment = Enum.TextXAlignment.Left
		Label.Name = Order
		Label.Parent = Backdrop

		local Bar = Instance.new("Frame")
		Bar.BackgroundColor3 = Color3.fromRGB(51, 153, 204)
		Bar.BorderSizePixel = 0
		Bar.Position = UDim2.new(1, 8, 0, 1)
		Bar.Size = UDim2.new(0, Time*500, 0, 18)
		Bar.Parent = Label

		local TimeLabel = Instance.new("TextLabel")
		TimeLabel.Font = FONT
		TimeLabel.TextSize = FONT_SIZE - 4
		TimeLabel.Size = UDim2.new(0, TextService:GetTextSize(tostring(Time), TimeLabel.TextSize, FONT, Vector2.new()).X, 0, TimeLabel.TextSize)
		TimeLabel.Position = UDim2.new(1, -TimeLabel.Size.X.Offset - 4, 0, 1)
		TimeLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
		TimeLabel.BackgroundTransparency = 1
		TimeLabel.Text = tostring(Time)
		TimeLabel.Parent = Bar
	end

	local Title = Instance.new("TextLabel")
	Title.BackgroundTransparency = 1
	Title.Name = "0"
	Title.TextColor3 = Color3.fromRGB(51, 153, 207)
	Title.Text = (" "):rep(4) .. TITLE_TEXT
	Title.TextSize = FONT_SIZE + 2
	Title.Size = UDim2.new(1, 0, 0, 36)
	Title.Font = Enum.Font.SourceSans
	Title.TextXAlignment = Enum.TextXAlignment.Left
	Title.Parent = Backdrop

	local ListLayout = Instance.new("UIListLayout")
	ListLayout.VerticalAlignment = Enum.VerticalAlignment.Center
	ListLayout.Padding = UDim.new(0, 2)
	ListLayout.SortOrder = Enum.SortOrder.Name
	ListLayout.Parent = Backdrop
end
