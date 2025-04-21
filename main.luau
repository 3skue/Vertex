-- init
local tweenService = game:GetService("TweenService")
local userInputService = game:GetService("UserInputService")
local runService = game:GetService("RunService")
local players = game:GetService("Players")

local localPlayer = players.LocalPlayer
local mouse = localPlayer:GetMouse()

local camera = workspace.CurrentCamera
repeat
	task.wait()
until camera.ViewportSize.X > 2

local viewportSize = camera.ViewportSize
local mainTweenInfo = TweenInfo.new(2 / 3, Enum.EasingStyle.Quart, Enum.EasingDirection.InOut)

-- constants
local DEBUGGING = runService:IsRunning()

-- gui
local UiBearer

if DEBUGGING then
	UiBearer = localPlayer:WaitForChild("PlayerGui")
else
	UiBearer = (gethui and gethui()) or game:GetService("CoreGui")
	
	if cloneref then
		UiBearer = cloneref(UiBearer)
	end
end

local function random()
	local prefixes = {
		"ui"; "server"; "local"; "global"; "net"; "networking"; "spring"; "game";
		"inventory"; "map"; "fx"; "sfx", "sound"; "core"; "stamina"; "hunger";
		"health"; "regen"; "movement"; "physics"; "particles"; "camera"; "audio"; "hud";
	}
	
	local suffixes = {
		"handler"; "service"; "module"; "utils"; "controller"; "utility"; "manager"; "system"; "driver";
	}

	local prefix = prefixes[math.random(1, #prefixes)]
	local suffix = suffixes[math.random(1, #suffixes)]
	local result = ""

	local function title(str: string)
		return str:sub(1, 1):upper()..str:sub(2)
	end

	local namingCase = math.random(0, 2)
	if namingCase == 0 then -- snake_case
		result = prefix.."_"..suffix
	elseif namingCase == 1 then -- camelCase
		result = prefix..title(suffix)
	elseif namingCase == 2 then -- PascalCase
		result = title(prefix)..title(suffix)
	end

	return result
end

local function create(properties: {
	[string]: any;
	className: string;
	children: {
		Instance
	}
}): Instance
	--/ init
	local className = properties.className
	local children = properties.children
	
	properties.className, properties.children = nil
	
	--/ instance creation
	local object = Instance.new(className or "Part")
	local childrenDictionary = {}
	
	if children then
		for i, child in children do
			child.instance.Parent = object
			childrenDictionary[i] = child
		end
	end
	
	--/ obfuscation
	if not properties.Name then
		object.Name = random()
	end

	if protect_gui then
		protect_gui(object)
	end
	
	--/ properties
	for name, value in properties do
		object[name] = value
	end
	
	return {
		instance = object;
		children = childrenDictionary;
	}
end

-- main class
local vertex = {}
vertex.__index = vertex

function vertex.newWindow()
	local window = setmetatable({
		minimized = false;
		size = UDim2.fromOffset(300, 500);
		
		children = {};
		ui = create {
			className = "ScreenGui";
			Parent = UiBearer;
			IgnoreGuiInset = true;
			
			children = {
				globalPadding = create {
					className = "UIPadding";
					PaddingBottom = UDim.new(0, 7);
					PaddingLeft = UDim.new(0, 7);
					PaddingRight = UDim.new(0, 7);
					PaddingTop = UDim.new(0, 7);
				};
				notificationBearer = create {
					className = "Frame";
					BackgroundTransparency = 1;
					AnchorPoint = Vector2.new(1, 0);
					Position = UDim2.fromScale(1, 0);
					Size = UDim2.new(0, 350, 1, 0);
					
					children = {
						layout = create {
							className = "UIListLayout";
							Padding = UDim.new(0, 0);
							SortOrder = Enum.SortOrder.LayoutOrder;
							VerticalAlignment = Enum.VerticalAlignment.Bottom;
							HorizontalAlignment = Enum.HorizontalAlignment.Right;
						};
					}
				};
				background = create {
					className = "Frame";
					AnchorPoint = Vector2.new(0.5, 0.5);
					BackgroundColor3 = Color3.fromRGB(17, 17, 25);
					Position = UDim2.fromOffset(viewportSize.X / 2, viewportSize.Y / 2);
					Size = UDim2.fromOffset(300, 500);
					BackgroundTransparency = 0.1;
					BorderSizePixel = 0;
					
					children = {
						dragbar = create {
							className = "Frame";
							BackgroundColor3 = Color3.fromRGB(25, 25, 37);
							BackgroundTransparency = 1;
							Size = UDim2.new(1, 0, 0, 30);
							BorderSizePixel = 0;
							
							children = {
								title = create {
									className = "TextLabel";
									BackgroundTransparency = 1;
									TextColor3 = Color3.new(1, 1, 1);
									
									Size = UDim2.fromScale(1, 1);
									Position = UDim2.fromOffset(7, 0);
									
									FontFace = Font.new("rbxassetid://16658246179", Enum.FontWeight.Medium, Enum.FontStyle.Italic);
									TextXAlignment = Enum.TextXAlignment.Left;
									TextSize = 14;
									
									BorderSizePixel = 0;
								};
								
								minimize = create {
									className = "TextButton";
									BackgroundTransparency = 1;
									--BackgroundColor3 = Color3.new(1 / 3, 1 / 3, 1 / 3);
									TextColor3 = Color3.new(1, 1, 1);

									Size = UDim2.fromScale(0.0675, 1);
									Position = UDim2.new(1, -25, 0, 0);
									AnchorPoint = Vector2.new(1, 0);

									FontFace = Font.new("rbxasset://fonts/families/Guru.json", Enum.FontWeight.Bold);
									TextSize = 14;
									
									Text = "–";

									BorderSizePixel = 0;
								};
								
								close = create {
									className = "TextButton";
									BackgroundTransparency = 1;
									--BackgroundColor3 = Color3.new(1 / 3, 1 / 3, 1 / 3);
									TextColor3 = Color3.new(1, 1, 1);

									Size = UDim2.fromScale(0.0675, 1);
									Position = UDim2.new(1, -8, 0, 0);
									AnchorPoint = Vector2.new(1, 0);

									FontFace = Font.new("rbxasset://fonts/families/Guru.json", Enum.FontWeight.Bold);
									TextSize = 14;
									Text = "✕";

									BorderSizePixel = 0;
								};
								
								stroke = create {
									className = "UIStroke";
									ApplyStrokeMode = Enum.ApplyStrokeMode.Border;
									Color = Color3.new(1, 1, 1);
									Transparency = 0.9;
								};
								
								corner = create {
									className = "UICorner";
									CornerRadius = UDim.new(0, 7);
								};
							}
						};
						
						status = create {
							className = "TextLabel";
							BackgroundTransparency = 1;
							TextColor3 = Color3.new(1 / 3, 1 / 3, 1 / 3);

							Size = UDim2.fromScale(1, 0.04);
							Position = UDim2.fromScale(0, 1);
							AnchorPoint = Vector2.new(0, 1);
							
							FontFace = Font.new("rbxassetid://16658246179", Enum.FontWeight.Medium, Enum.FontStyle.Italic);
							TextSize = 14;
							Text = "Status";
							
							TextXAlignment = Enum.TextXAlignment.Right;
							BorderSizePixel = 0;
						};
						
						content = create {
							className = "ScrollingFrame";
							BackgroundTransparency = 1;
							
							Position = UDim2.new(0.025, 0, 0, 35);
							Size = UDim2.new(0.95, 0, 0.93, -10);
							
							AutomaticCanvasSize = Enum.AutomaticSize.Y;
							CanvasSize = UDim2.new();
							
							TopImage = "";
							BottomImage = "";
							ScrollBarThickness = 3;
							
							children = {
								layout = create {
									className = "UIListLayout";
									SortOrder = Enum.SortOrder.LayoutOrder;
									HorizontalAlignment = Enum.HorizontalAlignment.Center;
									Padding = UDim.new(0, 7);
								};
								padding = create {
									className = "UIPadding";
									PaddingBottom = UDim.new(0, 7);
									PaddingLeft = UDim.new(0, 7);
									PaddingRight = UDim.new(0, 7);
									PaddingTop = UDim.new(0, 7);
								}
							}
						};
						
						corner = create {
							className = "UICorner";
							CornerRadius = UDim.new(0, 7);
						};
						
						padding = create {
							className = "UIPadding";
							PaddingBottom = UDim.new(0, 7);
							PaddingLeft = UDim.new(0, 7);
							PaddingRight = UDim.new(0, 7);
							PaddingTop = UDim.new(0, 7);
						};
						
						stroke = create {
							className = "UIStroke";
							ApplyStrokeMode = Enum.ApplyStrokeMode.Border;
							Color = Color3.new(1, 1, 1);
							Transparency = 0.9;
						};
					}
				}
			}
		}
	}, vertex)
	
	local background = window:_getInstance("background")
	
	-- dragbar
	local dragbar: Frame = window:_getInstance("background/dragbar").instance
	local dragging = false

	local dragStart: Vector2
	local startPos: UDim2

	window._dragConnection = dragbar.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true
			
			dragStart = Vector2.new(input.Position.X, input.Position.Y)
			startPos = background.instance.Position
		end
	end)
	
	window._stopDragConnection = userInputService.InputEnded:Connect(function()
		dragging = false
	end)
	
	window._renderUpdate = runService.RenderStepped:Connect(function()
		if dragging then
			local delta = Vector2.new(mouse.X, mouse.Y) - dragStart
			local target = startPos + UDim2.fromOffset(delta.X, delta.Y)
			local absoluteSize = background.instance.AbsoluteSize
			
			local clamped = UDim2.fromOffset(
				math.clamp(target.X.Offset, absoluteSize.X / 2, viewportSize.X - absoluteSize.X / 2 - 14),
				math.clamp(target.Y.Offset, absoluteSize.Y / 2, viewportSize.Y - absoluteSize.Y / 2 - 14)
			)
			
			background.instance.Position = clamped
		end
	end)
	
	-- buttons
	window._minimizeConnection = window:_getInstance("background/dragbar/minimize").instance.Activated:Connect(function()
		window:minimize()
	end)
	
	window._closeConnection = window:_getInstance("background/dragbar/close").instance.Activated:Once(function()
		window:destroy()
	end)
	
	return window
end

function vertex._getInstance(self, path: string, current: any?): any
	local current = current or self.ui
	
	for _, subpath in path:split("/") do
		current = current.children[subpath]
	end
	
	return current
end

function vertex.destroy(self)
	--/ clean up children
	for i, child in self.children do
		child:destroy()
	end
	
	--/ disconnect window connections
	self._minimizeConnection:Disconnect()
	self._closeConnection:Disconnect()
	self._renderUpdate:Disconnect()
	self._dragConnection:Disconnect()
	self._stopDragConnection:Disconnect()
	
	--/ destroy UI
	self.ui.instance:Destroy()
	
	--/ deep clean up
	--deepClean(self)
	self = nil
end

function vertex.minimize(self)
	local status = self:_getInstance("background/status").instance
	local content_container = self:_getInstance("background/content").instance
	local background = self:_getInstance("background")
	
	if self.minimized then
		status.Parent = background.instance
		content_container.Parent = background.instance

		background.instance.Size = self.size
		background.instance.Position += UDim2.new(
			0, 0, 0, self.size.Y.Offset / 2 - 22.5
		)
	else
		background.instance.Size = UDim2.new(
			self.size.X.Scale, self.size.X.Offset,
			0, 45
		)

		background.instance.Position -= UDim2.new(
			0, 0, 0, self.size.Y.Offset / 2 - 22.5
		)

		status.Parent, content_container.Parent = nil
	end

	self.minimized = not self.minimized
end

-- size
function vertex.setSize(self, newValue: UDim2)
	self.size = newValue
	self:_getInstance("background").instance.Size = newValue
	
	return self
end

function vertex.getSize(self): UDim2
	return self.size
end

-- position
function vertex.setPosition(self, newValue: UDim2)
	self:_getInstance("background").instance.Position = newValue
	
	return self
end

function vertex.getPosition(self): UDim2
	return self:_getInstance("background").instance.Position
end

-- status
function vertex.getStatus(self): string
	return self:_getInstance("background/status").instance.Text
end

function vertex.setStatus(self, newValue: string)
	self:_getInstance("background/status").instance.Text = newValue
	
	return self
end

-- title
function vertex.getTitle(self): string
	return self:_getInstance("background/dragbar/title").instance.Text
end

function vertex.setTitle(self, newValue: string)
	self:_getInstance("background/dragbar/title").instance.Text = newValue
	
	return self
end

-- widgets
local function cleanUp(self)
	local object = self.object
	if object then
		if object.instance then
			object.instance:Destroy()
		end

		table.clear(object)
		object = nil
	end
	
	local i = table.find(self.window.children, self)
	if i then
		table.remove(self.window.children, i)
	end
	
	table.clear(self)
	self = nil
end

-- / label
do
	local labelClass = {}
	labelClass.__index = labelClass
	
	function labelClass:destroy()
		cleanUp(self)
		
		self = nil
	end
	
	function labelClass:setRichText(enabled: boolean)
		self.object.instance.RichText = enabled
		
		return self
	end
	
	function labelClass:getRichText(): boolean
		return self.object.instance.RichText
	end
	
	function labelClass:setText(text: string)
		self.object.instance.Text = text
		
		return self
	end
	
	function vertex:label()
		local label = setmetatable({
			object = create {
				className = "TextLabel";
				Text = "Hello, world!";
				Parent = self:_getInstance("background/content").instance;
				
				TextColor3 = Color3.new(1, 1, 1);
				BackgroundTransparency = 1;
				
				Position = UDim2.fromOffset(7, 0);
				Size = UDim2.new(1, 0, 0, 20);
				
				TextWrapped = true;
				AutomaticSize = Enum.AutomaticSize.Y;
				
				FontFace = Font.new("rbxassetid://16658246179", Enum.FontWeight.Medium);
				TextXAlignment = Enum.TextXAlignment.Left;
				TextSize = 12;

				BorderSizePixel = 0;
				LayoutOrder = #self.children;
			};
			window = self;
		}, labelClass)
		
		table.insert(self.children, label)
		
		return label
	end
end

--/ button
do
	local buttonClass = {}
	buttonClass.__index = buttonClass
	
	function buttonClass:destroy()
		if self._pressColorConnection then
			self._pressColorConnection:Disconnect()
		end
		
		if self._releaseColorConnection then
			self._releaseColorConnection:Disconnect()
		end
		
		if self.callbackConnection then
			self.callbackConnection:Disconnect()
		end
		
		cleanUp(self)
	end
	
	function buttonClass:setRichText(enabled: boolean)
		self.object.instance.RichText = enabled
		
		return self
	end
	
	function buttonClass:getRichText()
		return self.object.instance.RichText
	end
	
	function buttonClass:setCallback(callback: (input: InputObject) -> ())
		self.callback = callback
		
		return self
	end
	
	function buttonClass:setName(newName: string)
		self.object.instance.Text = newName
		
		return self
	end
	
	function vertex:button()
		local button = setmetatable({
			object = create {
				className = "TextButton";
				Text = "Button";
				Parent = self:_getInstance("background/content").instance;
				AutoButtonColor = false;

				TextColor3 = Color3.new(1, 1, 1);
				BackgroundColor3 = Color3.fromRGB(17, 17, 25);
				BackgroundTransparency = 0.3;

				Position = UDim2.fromOffset(7, 0);
				Size = UDim2.new(1, 0, 0, 25);
				
				AutomaticSize = Enum.AutomaticSize.Y;
				TextWrapped = true;

				FontFace = Font.new("rbxassetid://16658246179", Enum.FontWeight.Medium);
				TextSize = 12;

				BorderSizePixel = 0;
				
				LayoutOrder = #self.children;
				children = {
					corner = create {
						className = "UICorner";
						CornerRadius = UDim.new(0, 7);
					};
					
					stroke = create {
						className = "UIStroke";
						ApplyStrokeMode = Enum.ApplyStrokeMode.Border;
						Color = Color3.new(1, 1, 1);
						Transparency = 0.9;
					};
				}
			};
			window = self;
		}, buttonClass)
		
		table.insert(self.children, button)
		
		local buttonInstance: TextButton = button.object.instance
		
		button._callbackConnection = buttonInstance.Activated:Connect(function()
			if button.callback then
				button.callback()
			end
		end)
		
		button._pressColorConnection = buttonInstance.InputBegan:Connect(function(input)
			if input.UserInputType ~= Enum.UserInputType.MouseMovement then
				buttonInstance.BackgroundColor3 = Color3.fromRGB(12, 12, 17)
			end
		end)
		
		button._releaseColorConnection = buttonInstance.InputEnded:Connect(function(input)
			if input.UserInputType ~= Enum.UserInputType.MouseMovement then
				buttonInstance.BackgroundColor3 = Color3.fromRGB(17, 17, 25)
			end
		end)
		
		return button
	end
	
	--/ / toggle
	local toggleClass = {}
	toggleClass.__index = toggleClass
	setmetatable(toggleClass, buttonClass)
	
	function toggleClass:destroy()
		if self._stateChangeConnection then
			self._stateChangeConnection:Disconnect()
		end
		
		if self.window then
			buttonClass.destroy(self)
		end
	end
	
	function toggleClass:setState(newValue: boolean)
		self.state = newValue
		
		local icon = self.icon.instance
		if newValue == true then
			icon.Image = "rbxassetid://7072706620"
			icon.ImageColor3 = Color3.new(0, 1, 0)
		else
			icon.Image = "rbxassetid://7072725342"
			icon.ImageColor3 = Color3.new(1, 0, 0)
		end
		
		if self.callback then
			self.callback(newValue)
		end
		
		return self
	end
	
	function toggleClass:setCallback(callback: (input: InputObject) -> ())
		self.callback = callback
		
		return self
	end

	function vertex:toggle(defaultState: boolean)
		local toggle = self:button()
		setmetatable(toggle, toggleClass)
		
		toggle.window = self
		toggle.state = defaultState
		toggle.icon = create {
			className = "ImageLabel";
			
			AnchorPoint = Vector2.new(0, 0.5);
			Position = UDim2.new(0, 7, 0.5, 0);
			Size = UDim2.new(0, 15, 0, 15);
			
			BackgroundTransparency = 1;
			ImageColor3 = Color3.new(1, 0, 0);
			
			Parent = toggle.object.instance;
		}
		
		table.insert(self.children, toggle)
		
		toggle._callbackConnection:Disconnect()
		toggle._callbackConnection = nil
		
		toggle:setState(defaultState)
		toggle._stateChangeConnection = toggle.object.instance.Activated:Connect(function()
			toggle:setState(not toggle.state)
		end)

		return toggle
	end
	
	--/ / keybind
	local keybindClass = {}
	keybindClass.__index = keybindClass
	
	setmetatable(keybindClass, buttonClass)
	
	function keybindClass:setKey(key: EnumItem | Enum.KeyCode | Enum.UserInputType)
		local keyString
		if key.EnumType == Enum.KeyCode then
			if key.Name == "Unknown" then
				keyString = "?"
			else
				keyString = userInputService:GetStringForKeyCode(key)
			end
		else
			keyString = "MB"..key.Name:sub(#"MouseButton" + 1)
		end
		
		self.icon.children.label.instance.Text = keyString
		self.key = key
		
		return self
	end
	
	function vertex:keybind(defaultKey: Enum.KeyCode? | Enum.UserInputType?)
		local keybind = self:button()
		setmetatable(keybind, keybindClass)
		
		defaultKey = defaultKey or Enum.KeyCode.Unknown
		
		keybind.icon = create {
			className = "ImageLabel";

			AnchorPoint = Vector2.new(0, 0.5);
			Position = UDim2.new(0, 7, 0.5, 0);
			Size = UDim2.new(0, 15, 0, 15);
			Image = "rbxasset://textures/ui/Controls/key_single.png";
			
			BackgroundTransparency = 1;
			ImageColor3 = Color3.new(1, 1, 1);

			Parent = keybind.object.instance;
			
			children = {
				label = create {
					className = "TextLabel";
					
					Size = UDim2.fromScale(1, 1);
					BackgroundTransparency = 1;
					FontFace = Font.new("rbxassetid://16658246179", Enum.FontWeight.Medium);
					TextColor3 = Color3.new(1, 1, 1);
					TextSize = 12;
					
					Text = (defaultKey == "Unknown" and "?") or userInputService:GetStringForKeyCode(defaultKey);
				}
			}
		}
		
		keybind:setKey(defaultKey)
		
		local keybindInstance = keybind.object.instance
		keybindInstance.Text = "Press to bind"
		
		keybind._callbackConnection:Disconnect()
		keybind._callbackConnection = userInputService.InputBegan:Connect(function(input)
			if keybind.callback and (keybind.key == input.KeyCode or keybind.key == input.UserInputType) and keybind.key ~= Enum.KeyCode.Unknown then
				keybind.callback()
			end
		end)
		
		local keyBindCooldown = false
		keybind._keyBindConnection = keybindInstance.Activated:Connect(function()
			if keyBindCooldown then return end
			keyBindCooldown = true
			
			keybindInstance.Text = "..."
			
			userInputService.InputBegan:Once(function(key)
				if key.KeyCode == Enum.KeyCode.Escape then
					keybind:setKey(Enum.KeyCode.Unknown)
				elseif key.UserInputType == Enum.UserInputType.Keyboard then
					keybind:setKey(key.KeyCode)
				elseif key.UserInputType.Name:find("MouseButton") then
					keybind:setKey(key.UserInputType)
				end

				keybindInstance.Text = "Press to bind"
				
				task.delay(0.25, function()
					keyBindCooldown = false
				end)
			end)
		end)
		
		return keybind
	end
end

--/ slider
do
	local sliderClass = {}
	sliderClass.__index = sliderClass
	
	function sliderClass:destroy()
		if self._inputConnection then
			self._inputConnection:Disconnect()
		end
		
		if self._renderConnection then
			self._renderConnection:Disconnect()
		end
		
		cleanUp(self)
	end
	
	function sliderClass:setCallback(callback)
		self.callback = callback
		
		return self
	end
	
	function sliderClass:setMax(newValue: number)
		self.max = newValue
		
		return self
	end
	
	function sliderClass:setMin(newValue: number)
		self.min = newValue
		self:setValue(self.value)
		
		return self
	end
	
	function sliderClass:setIncrement(newValue: number)
		self.increment = newValue
		
		return self
	end
	
	function sliderClass:setValue(newValue: number)
		local window = self.window
		local object = self.object
		local min = self.min
		local max = self.max
		
		local a = ((newValue - min) / (max - min))
		
		window:_getInstance("info", object).instance.Text = `{math.round(newValue)} / {max}`
		window:_getInstance("sliderBearer/button", object).instance.Position = UDim2.fromScale(a)
		window:_getInstance("sliderBearer/selection", object).instance.Size = UDim2.new(a, 0, 0.5, 0)
		
		self.value = newValue
		if self.callback then
			self.callback(newValue)
		end
		
		return self
	end
	
	function sliderClass:setText(newValue: string)
		self.window:_getInstance("title", self.object).instance.Text = newValue
		
		return self
	end
	
	function sliderClass:setRichtext(newValue: string)
		self.window:_getInstance("title", self.object).instance.RichText = newValue

		return self
	end
	
	function sliderClass:getRichtext(newValue: string)
		return self.window:_getInstance("title", self.object).instance.RichText
	end
	
	function vertex:slider(defaultValue: string)
		local slider = setmetatable({
			increment = 1;
			min = 0;
			max = 100;
			value = 50;
			
			object = create {
				className = "Frame";
				Parent = self:_getInstance("background/content").instance;
				
				BackgroundTransparency = 0.3;
				BackgroundColor3 = Color3.fromRGB(17, 17, 25);
				BorderSizePixel = 0;
				
				Size = UDim2.new(1, 0, 0, 50);
				AutomaticSize = Enum.AutomaticSize.Y;
				
				LayoutOrder = #self.children;
				
				children = {
					padding = create {
						className = "UIPadding";
						PaddingBottom = UDim.new(0, 7);
						PaddingLeft = UDim.new(0, 7);
						PaddingRight = UDim.new(0, 7);
						PaddingTop = UDim.new(0, 7);
					};
					
					corner = create {
						className = "UICorner";
						CornerRadius = UDim.new(0, 7);
					};
					
					stroke = create {
						className = "UIStroke";
						Color = Color3.new(1, 1, 1);
						Transparency = 0.9;
					};
					
					sliderBearer = create {
						className = "Frame";
						BackgroundTransparency = 0.9;
						Position = UDim2.fromScale(0, 0.55);
						Size = UDim2.new(1, 0, 0, 4);
						
						children = {
							corner = create {
								className = "UICorner";
								CornerRadius = UDim.new(0, 7);
							};
							
							button = create {
								className = "ImageButton";
								AnchorPoint = Vector2.new(0.5, 1);
								AutoButtonColor = false;
								BackgroundTransparency = 1;
								Position = UDim2.fromScale(0.5, 0.5);
								Size = UDim2.fromOffset(12.5, 12.5);
								Image = "rbxassetid://7072706663";
								
								children = {
									corner = create {
										className = "UICorner";
										CornerRadius = UDim.new(0, 7);
									};
								}
							};
							
							selection = create {
								className = "Frame";
								BackgroundColor3 = Color3.new(1, 1, 1);
								Position = UDim2.fromScale(0, 0, 0.7, 0);
								Size = UDim2.new(0.5, 0, 0, 2);
								AnchorPoint = Vector2.new(0, 0.5);
								
								children = {
									corner = create {
										className = "UICorner";
										CornerRadius = UDim.new(0, 7);
									}
								}
							}
						}
					};
					
					title = create {
						className = "TextLabel";
						AnchorPoint = Vector2.new(1, 0);
						AutomaticSize = Enum.AutomaticSize.Y;
						BackgroundTransparency = 1;
						Position = UDim2.fromScale(1, 0);
						Size = UDim2.fromScale(1, 0);
						FontFace = Font.new("rbxassetid://16658246179", Enum.FontWeight.Medium);
						TextSize = 12;
						TextWrapped = true;
						TextColor3 = Color3.new(1, 1, 1);
					};
					
					info = create {
						className = "TextLabel";
						BackgroundTransparency = 1;
						AnchorPoint = Vector2.new(0, 1);
						Position = UDim2.fromScale(0, 1);
						Size = UDim2.fromScale(1, 0);
						AutomaticSize = Enum.AutomaticSize.Y;
						TextColor3 = Color3.fromRGB(85, 85, 85);
						FontFace = Font.new("rbxassetid://16658246179", Enum.FontWeight.Medium);
						Text = "50";
						TextSize = 10;
						TextWrapped = true;
						TextXAlignment = Enum.TextXAlignment.Left;
					}
				}
			};
			
			window = self;
		}, sliderClass)
		
		table.insert(self.children, slider)
		
		local sliderBearer: Frame = self:_getInstance("sliderBearer", slider.object).instance
		local sliderButton: ImageButton = self:_getInstance("sliderBearer/button", slider.object).instance
		local status: TextLabel = self:_getInstance("info", slider.object).instance
		local selection: Frame = self:_getInstance("sliderBearer/selection", slider.object).instance
		
		local absoluteSize = sliderBearer.AbsoluteSize.X
		
		local dragging = false
		local dragStart = 0
		local origin = 0.5
		
		slider._inputConnection = sliderButton.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				dragging = true
				dragStart = input.Position.X
				origin = sliderButton.Position.X.Scale
				
				input.Changed:Once(function()
					if input.UserInputState == Enum.UserInputState.End then
						dragging = false
					end
				end)
				
				while runService.PreRender:Wait() and dragging do
					local visualValue = ((mouse.X - dragStart) / absoluteSize) + origin
					sliderButton.Position = UDim2.new(math.clamp(visualValue, 0, 1), 0, 0.5, 0)

					local realValue = ((slider.max - slider.min) * sliderButton.Position.X.Scale) + slider.min
					local roundedValue = math.round(realValue / slider.increment) * slider.increment

					slider.value = roundedValue
					status.Text = `{roundedValue} / {slider.max}`
					selection.Size = UDim2.new(sliderButton.Position.X.Scale, 0, 0, 2)
					
					if slider.callback then
						slider.callback(roundedValue)
					end
				end
			end
		end)
		
		slider._stopDragConnection = userInputService.InputEnded:Connect(function()
			dragging = false
		end)
		
		if defaultValue then
			slider:setValue(defaultValue)
		end
		
		return slider
	end
	
	--/ range slider
	local rangeSliderClass = {}
	rangeSliderClass.__index = rangeSliderClass
	setmetatable(rangeSliderClass, sliderClass)
	
	function rangeSliderClass:destroy()
		self._stopDragConnection:Disconnect()
		
		sliderClass.destroy(self)
	end
	
	function rangeSliderClass:setMin(newValue: number)
		self.min = newValue
		self.window:_getInstance("info", self.object).instance.Text = `{self.valueStart} | {self.valueEnd}`
		
		return self
	end
	
	function rangeSliderClass:setValue(startValue: number, endValue: number)
		local window = self.window
		local object = self.object
		
		local sliderButtonStart: ImageButton = window:_getInstance("sliderBearer/button", object).instance
		local selection: Frame = window:_getInstance("sliderBearer/selection", object).instance
		local sliderButtonEnd: ImageButton = self.sliderButtonEnd
		
		self.valueStart = startValue or self.valueStart
		self.valueEnd = endValue or self.valueEnd
		
		self.window:_getInstance("info", object).instance.Text = `{self.valueStart} | {self.valueEnd}`
		
		local min, max = self.min, self.max
		local f1, f2 = (startValue - min) / (max - min), (endValue - min) / (max - min)
		
		sliderButtonStart.Position = UDim2.new(f1, 0, 0.5, 0)
		sliderButtonEnd.Position = UDim2.new(f2, 0, 0.5, 0)
		selection.Position = UDim2.new(sliderButtonStart.Position.X.Scale, 0, 0.5, 0)
		selection.Size = UDim2.new(f2 - f1, 0, 0, 2)
		
		if self.callback then
			self.callback(startValue, endValue)
		end
		
		return self
	end
	
	function rangeSliderClass:update(draggingStart, draggingEnd, dragStart, origin)
		local window = self.window
		local object = self.object
		
		local sliderBearer: Frame = window:_getInstance("sliderBearer", object).instance
		local sliderButtonStart: ImageButton = window:_getInstance("sliderBearer/button", object).instance
		local sliderButtonEnd: ImageButton = self.sliderButtonEnd
		local status: TextLabel = window:_getInstance("info", object).instance
		local selection: Frame = window:_getInstance("sliderBearer/selection", object).instance
		
		local absoluteSize = sliderBearer.AbsoluteSize.X
		
		local max, min = self.max, self.min
		local increment = self.increment
		local mouseX = mouse.X
		
		if draggingStart then
			local visualValue = (mouseX - dragStart) / absoluteSize
			sliderButtonStart.Position = UDim2.new(math.clamp(visualValue + origin, 0, sliderButtonEnd.Position.X.Scale - 0.02), 0, 0.5, 0)

			local realValue = ((max - min) * sliderButtonStart.Position.X.Scale) + min
			local roundedValue = math.round(math.round(realValue / increment * 1.01) * increment / 1.01)

			self.valueStart = roundedValue
		elseif draggingEnd then
			local visualValue = (mouseX - dragStart) / absoluteSize
			sliderButtonEnd.Position = UDim2.new(math.clamp(visualValue + origin, sliderButtonStart.Position.X.Scale + 0.02, 1), 0, 0.5, 0)

			local realValue = ((max - min) * sliderButtonEnd.Position.X.Scale) + min
			local roundedValue = math.round(math.round(realValue / increment * 1.01) * increment / 1.01)

			self.valueEnd = roundedValue
		end
		
		if self.callback then
			self.callback(self.valueStart, self.valueEnd)
		end
		
		status.Text = `{self.valueStart} | {self.valueEnd}`

		selection.Position = UDim2.new(sliderButtonStart.Position.X.Scale, 0, 0.5, 0)
		selection.Size = UDim2.new(sliderButtonEnd.Position.X.Scale - sliderButtonStart.Position.X.Scale, 0, 0, 2)
		
		return self
	end
	
	function vertex:rangeSlider(defaultStartValue: number?, defaultEndValue: number?)
		local rangeSlider = self:slider()
		setmetatable(rangeSlider, rangeSliderClass)
		
		rangeSlider.value = nil
		rangeSlider.valueStart = 33
		rangeSlider.valueEnd = 66
		
		local sliderBearer: Frame = self:_getInstance("sliderBearer", rangeSlider.object).instance
		local sliderButtonStart: ImageButton = self:_getInstance("sliderBearer/button", rangeSlider.object).instance
		local status: TextLabel = self:_getInstance("info", rangeSlider.object).instance
		local selection: Frame = self:_getInstance("sliderBearer/selection", rangeSlider.object).instance
		
		selection.Position = UDim2.new(1 / 3, 0, 0.5, 0)
		selection.Size = UDim2.new(1 / 3, 0, 0, 2)
		selection.AnchorPoint = Vector2.new(0, 0.5)
		
		--/ / add second button
		local sliderButtonEnd = sliderButtonStart:Clone()
		sliderButtonEnd.Parent = sliderBearer
		
		sliderButtonStart.Position = UDim2.fromScale(1 / 3, 0)
		sliderButtonEnd.Position = UDim2.fromScale(2 / 3, 0)
		
		sliderButtonStart.Size = UDim2.fromOffset(12.5, 12.5)
		sliderButtonEnd.Size = UDim2.fromOffset(12.5, 12.5)
		
		sliderButtonStart.Image = "rbxassetid://7072706663"
		sliderButtonEnd.Image = "rbxassetid://7072706663"
		
		rangeSlider.sliderButtonEnd = sliderButtonEnd
		
		--/ / reset object
		rangeSlider._inputConnection:Disconnect()
		rangeSlider._inputConnection = nil
		
		--/ / reconfigure
		local draggingStart, draggingEnd = false, false
		local dragStart = 0
		local origin = 0.5
		
		local absoluteSize = sliderBearer.AbsoluteSize.X
		
		rangeSlider._inputStartConnection = sliderButtonStart.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 and not draggingEnd then
				draggingStart = true
				dragStart = input.Position.X
				origin = sliderButtonStart.Position.X.Scale
	
				input.Changed:Once(function()
					if input.UserInputState == Enum.UserInputState.End then
						draggingStart = false
					end
				end)
				
				while runService.PreRender:Wait() and draggingStart do
					rangeSlider:update(draggingStart, draggingEnd, dragStart, origin)
				end
			end
		end)
		
		rangeSlider._inputEndConnection = sliderButtonEnd.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 and not draggingStart then
				draggingEnd = true
				dragStart = input.Position.X
				origin = sliderButtonEnd.Position.X.Scale
				
				while runService.PreRender:Wait() and draggingEnd do
					rangeSlider:update(draggingStart, draggingEnd, dragStart, origin)
				end
			end
		end)
		
		rangeSlider._stopDragConnection:Disconnect()
		rangeSlider._stopDragConnection = userInputService.InputEnded:Connect(function()
			draggingEnd, draggingStart = false, false
		end)
		
		if defaultStartValue and defaultEndValue then
			rangeSlider:setValue(defaultStartValue, defaultEndValue)
		end
		
		return rangeSlider
	end
end

--/ textbox
do
	local textboxClass = {}
	textboxClass.__index = textboxClass
	
	function textboxClass:destroy()
		self._callbackConnection:Disconnect()
		cleanUp(self)
	end
	
	function textboxClass:setText(newValue: string)
		self.window:_getInstance("input", self.object).instance.Text = newValue
		
		return self
	end
	
	function textboxClass:setPlaceholder(newValue: string)
		self.window:_getInstance("input", self.object).instance.PlaceholderText = newValue
		
		return self
	end
	
	function textboxClass:getText()
		return self.window:_getInstance("input", self.object).instance.Text
	end
	
	function textboxClass:setCallback(callback: (string) -> ())
		self.callback = callback
		
		return self
	end
	
	function vertex:textbox(placeholder: string?)
		local textbox = setmetatable({
			object = create {
				className = "Frame";
				Parent = self:_getInstance("background/content").instance;

				BackgroundColor3 = Color3.fromRGB(17, 17, 25);
				BorderSizePixel = 0;

				Size = UDim2.new(1, 0, 0, 25);
				AutomaticSize = Enum.AutomaticSize.Y;

				LayoutOrder = #self.children;
				
				children = {
					corner = create {
						className = "UICorner";
						CornerRadius = UDim.new(0, 7);
					};
					
					stroke = create {
						className = "UIStroke";
						Color = Color3.new(1, 1, 1);
						Transparency = 0.9;
					};
					
					input = create {
						className = "TextBox";
						AutomaticSize = Enum.AutomaticSize.Y;
						BackgroundTransparency = 1;
						Position = UDim2.new(0, 30, 0, 0);
						Size = UDim2.new(1, -25, 1, 0);
						FontFace = Font.new("rbxassetid://16658246179", Enum.FontWeight.Medium);
						TextColor3 = Color3.new(1, 1, 1);
						TextXAlignment = Enum.TextXAlignment.Left;
						TextSize = 12;
						TextWrapped = true;
						Text = "";
						PlaceholderText = placeholder or "Textbox";
					};
					
					image = create {
						className = "ImageButton";
						AnchorPoint = Vector2.new(0, 0.5);
						BackgroundTransparency = 1;
						Position = UDim2.new(0, 7, 0.5, 0);
						Size = UDim2.fromOffset(15, 15);
						Image = "rbxassetid://7072715877";
					}
				}
			};
			
			window = self;
		}, textboxClass)
		
		table.insert(self.children, textbox)
		
		local object: TextBox = self:_getInstance("input", textbox.object).instance
		textbox._callbackConnection = object.FocusLost:Connect(function(property)
			if textbox.callback then
				textbox.callback(object.Text)
			end
		end)
		
		return textbox
	end
end

--/ color picker
do
	local colorPickerClass = {}
	colorPickerClass.__index = colorPickerClass
	
	function colorPickerClass:destroy()
		for _, connection in self._sliderConnections do
			connection:Disconnect()
		end
		
		self._rainbowToggle:Disconnect()
		self._endDragging:Disconnect()
		
		cleanUp(self)
	end
	
	function colorPickerClass:setText(newValue: string)
		self.window:_getInstance("label", self.object).instance.Text = newValue.."<br />"
		
		return self
	end
	
	function colorPickerClass:setRichText(newValue: boolean)
		self.window:_getInstance("label", self.object).instance.RichText = newValue
		
		return self
	end
	
	function colorPickerClass:setCallback(callback: (Color3) -> ())
		self.callback = callback
		
		return self
	end
	
	function colorPickerClass:setColor(newValue: Color3)
		local window, object = self.window, self.object
		
		local h, s, v = newValue:ToHSV()
		window:_getInstance("hueSlider/button", object).instance.Position = UDim2.fromScale(h, 0.5)
		window:_getInstance("saturationSlider/button", object).instance.Position = UDim2.fromScale(s, 0.5)
		window:_getInstance("valueSlider/button", object).instance.Position = UDim2.fromScale(v, 0.5)
		
		self:update()
		
		return self
	end
	
	function colorPickerClass:update()
		local window, object = self.window, self.object
		
		local color = Color3.fromHSV(
			window:_getInstance("hueSlider/button", object).instance.Position.X.Scale,
			window:_getInstance("saturationSlider/button", object).instance.Position.X.Scale,
			window:_getInstance("valueSlider/button", object).instance.Position.X.Scale
		)
		
		window:_getInstance("image", object).instance.ImageColor3 = color
		
		self.value = color
		if self.callback then
			self.callback(color)
		end
		
		return self
	end
	
	function vertex:colorPicker(defaultColor: Color3?)
		local colorPicker = setmetatable({
			object = create {
				className = "Frame";
				Parent = self:_getInstance("background/content").instance;
				AutomaticSize = Enum.AutomaticSize.Y;
				
				BackgroundColor3 = Color3.fromRGB(17, 17, 25);
				BackgroundTransparency = 0.3;
				Size = UDim2.new(1, 0, 0, 40);
				
				LayoutOrder = #self.children;
				
				children = {
					corner = create {
						className = "UICorner";
						CornerRadius = UDim.new(0, 7);
					};
					stroke = create {
						className = "UIStroke";
						Color = Color3.new(1, 1, 1);
						Transparency = 0.9;
					};
					padding = create {
						className = "UIPadding";
						PaddingBottom = UDim.new(0, 7);
						PaddingLeft = UDim.new(0, 7);
						PaddingRight = UDim.new(0, 7);
						PaddingTop = UDim.new(0, 7);
					};
					
					image = create {
						className = "ImageButton";
						AnchorPoint = Vector2.new(0, 0.5);
						BackgroundTransparency = 1;
						Position = UDim2.new(0, 4, 0.5, 0);
						Size = UDim2.fromOffset(15, 15);
						Image = "rbxassetid://16898730641";
						ImageColor3 = Color3.new(1, 1, 1);
						ImageRectOffset = Vector2.new(514, 514);
						ImageRectSize = Vector2.new(256, 256);
					};

					hueSlider = create {
						className = "Frame";
						AnchorPoint = Vector2.new(0, 1);
						BackgroundColor3 = Color3.new(1, 1, 1);
						Position = UDim2.new(0, 30, 1, 0);
						Size = UDim2.new(0.25, 0, 0, 5);

						children = {
							corner = create {
								className = "UICorner";
								CornerRadius = UDim.new(1, 0);
							};
							stroke = create {
								className = "UIStroke";
								Color = Color3.new(1, 1, 1);
								Transparency = 0.9;
							};
							gradient = create {
								className = "UIGradient";
								Color = ColorSequence.new {
									ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0));
									ColorSequenceKeypoint.new(0.167, Color3.fromRGB(255, 255, 0));
									ColorSequenceKeypoint.new(0.333, Color3.fromRGB(0, 255, 0));
									ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 255));
									ColorSequenceKeypoint.new(0.667, Color3.fromRGB(0, 0, 255));
									ColorSequenceKeypoint.new(0.833, Color3.fromRGB(255, 0, 255));
									ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0));
								};
							};
							button = create {
								className = "TextButton";
								AutoButtonColor = false;
								AnchorPoint = Vector2.new(0.5, 0.5);
								BackgroundColor3 = Color3.new(1, 1, 1);
								BackgroundTransparency = 0.9;
								Position = UDim2.new(0, 0, 0.5, 0);
								Size = UDim2.new(0, 5, 2, 0);
								BorderSizePixel = 0;
								Text = "";
								
								children = {
									corner = create {
										className = "UICorner";
										CornerRadius = UDim.new(1, 0);
									};
									stroke = create {
										className = "UIStroke";
										Color = Color3.new(1, 1, 1);
										ApplyStrokeMode = Enum.ApplyStrokeMode.Border;
									};
								};
							}
						}
					};
					
					saturationSlider = create {
						className = "Frame";
						AnchorPoint = Vector2.new(0, 1);
						BackgroundColor3 = Color3.new(1, 1, 1);
						Position = UDim2.new(0.405, 0, 1, 0);
						Size = UDim2.new(0.25, 0, 0, 5);

						children = {
							corner = create {
								className = "UICorner";
								CornerRadius = UDim.new(1, 0);
							};
							stroke = create {
								className = "UIStroke";
								Color = Color3.new(1, 1, 1);
								Transparency = 0.9;
							};
							gradient = create {
								className = "UIGradient";
								Color = ColorSequence.new {
									ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255));
									ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0));
								}
							};
							button = create {
								className = "TextButton";
								AutoButtonColor = false;
								AnchorPoint = Vector2.new(0.5, 0.5);
								BackgroundColor3 = Color3.new(1, 1, 1);
								BackgroundTransparency = 0.9;
								Position = UDim2.new(1, 0, 0.5, 0);
								Size = UDim2.new(0, 5, 2, 0);
								BorderSizePixel = 0;
								Text = "";
								
								children = {
									corner = create {
										className = "UICorner";
										CornerRadius = UDim.new(1, 0);
									};
									stroke = create {
										className = "UIStroke";
										Color = Color3.new(1, 1, 1);
										ApplyStrokeMode = Enum.ApplyStrokeMode.Border;
									};
								};
							}
						}
					};
					
					valueSlider = create {
						className = "Frame";
						AnchorPoint = Vector2.new(0, 1);
						BackgroundColor3 = Color3.new(1, 1, 1);
						Position = UDim2.new(0.7, 0, 1, 0);
						Size = UDim2.new(0.25, 0, 0, 5);

						children = {
							corner = create {
								className = "UICorner";
								CornerRadius = UDim.new(1, 0);
							};
							stroke = create {
								className = "UIStroke";
								Color = Color3.new(1, 1, 1);
								Transparency = 0.9;
							};
							gradient = create {
								className = "UIGradient";
								Color = ColorSequence.new {
									ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 0, 0));
									ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255));
								}
							};
							button = create {
								className = "TextButton";
								AutoButtonColor = false;
								AnchorPoint = Vector2.new(0.5, 0.5);
								BackgroundColor3 = Color3.new(1, 1, 1);
								BackgroundTransparency = 0.9;
								Position = UDim2.new(1, 0, 0.5, 0);
								Size = UDim2.new(0, 5, 2, 0);
								BorderSizePixel = 0;
								Text = "";
								
								children = {
									corner = create {
										className = "UICorner";
										CornerRadius = UDim.new(1, 0);
									};
									stroke = create {
										className = "UIStroke";
										Color = Color3.new(1, 1, 1);
										ApplyStrokeMode = Enum.ApplyStrokeMode.Border;
									};
								};
							}
						}
					};
					
					label = create {
						className = "TextLabel";
						AutomaticSize = Enum.AutomaticSize.Y;
						BackgroundTransparency = 1;
						BorderSizePixel = 0;
						Position = UDim2.fromScale(0.125, 0);
						Size = UDim2.fromScale(0.85, 0);
						FontFace = Font.new("rbxassetid://16658246179", Enum.FontWeight.Medium);
						TextColor3 = Color3.new(1, 1, 1);
						TextXAlignment = Enum.TextXAlignment.Left;
						TextSize = 12;
						TextWrapped = true;
						RichText = true;
						Text = "Color picker<br />";
					}
				}
			};
			window = self;
			_sliderConnections = {};
		}, colorPickerClass)
		
		table.insert(self.children, colorPicker)
		
		local children = colorPicker.object.children
		local hue = children.hueSlider
		local saturation = children.saturationSlider
		local value = children.valueSlider
		
		local image: ImageButton = children.image.instance
		
		local dragging = false
		local manualConfigEnabled = true
		
		local function handleSlider(slider)
			local button: TextButton = slider.children.button.instance
			local absoluteSize = slider.instance.AbsoluteSize
			
			table.insert(colorPicker._sliderConnections, button.InputBegan:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 and manualConfigEnabled then
					local dragStart = mouse.X
					local origin = button.Position.X.Scale
					dragging = true
					
					while runService.PreRender:Wait() and dragging do
						local currentPosition = mouse.X
						local visualValue = (currentPosition - dragStart) / absoluteSize.X
						button.Position = UDim2.new(math.clamp(visualValue + origin, 0, 1), 0, 0.5, 0)
						
						colorPicker:update()
					end
				end
			end))
		end
		
		colorPicker._endDragging = userInputService.InputEnded:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				dragging = false
			end
		end)
		
		colorPicker._rainbowToggle = image.Activated:Connect(function()
			manualConfigEnabled = not manualConfigEnabled
			
			local hue = 0
			while runService.PreRender:Wait() and manualConfigEnabled do
				hue = (os.clock() * 0.25) % 1
				
				local value = Color3.fromHSV(hue, 1, 1)
				colorPicker:setColor(value)
			end
		end)
		
		handleSlider(hue)
		handleSlider(saturation)
		handleSlider(value)
		
		if defaultColor then
			colorPicker:setColor(defaultColor)
		end
		
		return colorPicker
	end
end

--/ dropdown
do
	local dropdownClass = {}
	dropdownClass.__index = dropdownClass
	
	function dropdownClass:destroy()
		for i, connection in self._callbackConnections do
			connection:Disconnect()
		end
		
		cleanUp(self)
	end
	
	function dropdownClass:select(name: string)
		for _, itemObject in self.items do
			itemObject.instance.BackgroundTransparency = 1
			itemObject.children.stroke.instance.Transparency = 0.9
		end
		
		local item = self.items[name]
		item.instance.BackgroundTransparency = 0.995
		item.children.stroke.instance.Transparency = 0.7
	end
	
	function dropdownClass:addItem(name: string)
		local item = create {
			className = "TextButton";
			Parent = self.window:_getInstance("content", self.object).instance;
			AutomaticSize = Enum.AutomaticSize.XY;
			BackgroundColor3 = Color3.new(1, 1, 1);
			BackgroundTransparency = 1;
			Size = UDim2.new(0.95, 0, 0, 20);
			Text = name;
			FontFace = Font.new("rbxassetid://16658246179", Enum.FontWeight.Medium);
			TextSize = 12;
			TextWrapped = true;
			RichText = true;
			TextColor3 = Color3.new(1, 1, 1);
			
			children = {
				corner = create {
					className = "UICorner";
					CornerRadius = UDim.new(0, 7);
				};
				stroke = create {
					className = "UIStroke";
					ApplyStrokeMode = Enum.ApplyStrokeMode.Border;
					Color = Color3.new(1, 1, 1);
					Transparency = 0.9;
				};
			}
		}
		
		self.items[name] = item
		self._callbackConnections[name] = item.instance.Activated:Connect(function()
			if self.callback then
				self.callback(name)
			end
			
			self:select(name)
		end)
		
		if self.value == name then
			self:select(name)
		end
		
		return self
	end
	
	function dropdownClass:setCallback(callback: (string) -> ())
		self.callback = callback
		if self.value then
			callback(self.value)
		end		
		
		return self
	end
	
	function dropdownClass:removeItem(name: string)
		self._callbackConnections[name]:Disconnect()
		self.items[name]:Destroy()
		self.items[name] = nil
		cleanUp(self.items[name])
		
		return self
	end
	
	function vertex:dropdown(defaultValue: string?)
		local dropdown = setmetatable({
			object = create {
				className = "Frame";
				Parent = self:_getInstance("background/content").instance;
				AutomaticSize = Enum.AutomaticSize.Y;
				BackgroundColor3 = Color3.fromRGB(17, 17, 25);
				BackgroundTransparency = 0.3;
				Size = UDim2.new(1, 0, 0, 0);
				LayoutOrder = #self.children;
				
				children = {
					padding = create {
						className = "UIPadding";
						PaddingBottom = UDim.new(0, 7);
						PaddingLeft = UDim.new(0, 7);
						PaddingRight = UDim.new(0, 7);
						PaddingTop = UDim.new(0, 7);
					};
					layout = create {
						className = "UIListLayout";
						Padding = UDim.new(0, 7);
						SortOrder = Enum.SortOrder.LayoutOrder;
						HorizontalAlignment = Enum.HorizontalAlignment.Center;
					};
					corner = create {
						className = "UICorner";
						CornerRadius = UDim.new(0, 7);
					};
					stroke = create {
						className = "UIStroke";
						Color = Color3.new(1, 1, 1);
						Transparency = 0.9;
					};
					
					content = create {
						className = "ScrollingFrame";
						BackgroundTransparency = 1;
						Size = UDim2.new(1, 0, 0, 35);
						AutomaticCanvasSize = Enum.AutomaticSize.Y;
						CanvasSize = UDim2.new();
						ScrollBarImageTransparency = 1;
						ScrollBarThickness = 0;
						LayoutOrder = 2;
						
						children = {
							padding = create {
								className = "UIPadding";
								PaddingBottom = UDim.new(0, 7);
								--PaddingLeft = UDim.new(0, 7);
								--PaddingRight = UDim.new(0, 7);
								PaddingTop = UDim.new(0, 7);
							};
							layout = create {
								className = "UIListLayout";
								Padding = UDim.new(0, 7);
								SortOrder = Enum.SortOrder.LayoutOrder;
								HorizontalAlignment = Enum.HorizontalAlignment.Center;
							};
						}
					};
					icon = create {
						className = "ImageLabel";
						BackgroundTransparency = 1;
						LayoutOrder = 1;
						Size = UDim2.fromOffset(10, 10);
						Image = "rbxassetid://7072706838";
						ImageColor3 = Color3.new(1, 1, 1);
					};
					label = create {
						className = "TextLabel";
						AutomaticSize = Enum.AutomaticSize.Y;
						BackgroundTransparency = 1;
						BorderSizePixel = 0;
						Size = UDim2.new(1, 0, 0, 20);
						FontFace = Font.new("rbxassetid://16658246179", Enum.FontWeight.Medium);
						TextSize = 12;
						TextWrapped = true;
						TextColor3 = Color3.new(1, 1, 1);
					};
				}
			};
			items = {};
			window = self;
			value = defaultValue;
			_callbackConnections = {};
		}, dropdownClass)
		
		return dropdown
	end
end

--/ notification
do
	local activeNotifications = 0
	
	function vertex:notify(properties: {
		title: string;
		text: string;
		duration: number?
		})
		activeNotifications += 1
		
		local paddingBearer = create {
			className = "Frame";
			Parent = self.ui.children.notificationBearer.instance;
			Size = UDim2.new();
			BackgroundTransparency = 1;
			BorderSizePixel = 0;
		}
		
		local notification = create {
			className = "Frame";
			Parent = paddingBearer.instance;
			Position = UDim2.new(0.5, 0, 0.5, 0);
			BackgroundColor3 = Color3.fromRGB(17, 17, 25);
			BackgroundTransparency = 1;
			AnchorPoint = Vector2.new(0.5, 0.5);
			--Size = UDim2.fromOffset(350, 150);
			LayoutOrder = activeNotifications;
			
			children = {
				stroke = create {
					className = "UIStroke";
					Color = Color3.new(1, 1, 1);
					Transparency = 1;
				};
				corner = create {
					className = "UICorner";
					CornerRadius = UDim.new(0, 7);
				};
				progressBar = create {
					className = "Frame";
					AnchorPoint = Vector2.new(0.5, 1);
					BackgroundColor3 = Color3.new(1, 1, 1);
					BackgroundTransparency = 1;
					Position = UDim2.fromScale(0.5, 1);
					Size = UDim2.new(1, 0, 0, 2);
					
					children = {
						corner = create {
							className = "UICorner";
							CornerRadius = UDim.new(1, 0);
						};
					}
				};
				
				title = create {
					className = "TextLabel";
					AutomaticSize = Enum.AutomaticSize.XY;
					BackgroundTransparency = 1;
					BorderSizePixel = 0;
					Size = UDim2.new(1, 0, 0, 30);
					Position = UDim2.new();
					FontFace = Font.new("rbxassetid://16658246179", Enum.FontWeight.Medium);
					TextSize = 18;
					TextWrapped = true;
					TextColor3 = Color3.new(1, 1, 1); 
					Text = properties.title;
					TextTransparency = 1;
				};
				line = create {
					className = "Frame";
					BorderSizePixel = 0;
					BackgroundColor3 = Color3.new(0, 0, 0);
					Size = UDim2.new(0.9, 0, 0, 3);
					AnchorPoint = Vector2.new(0.5, 0);
					Position = UDim2.new(0.5, 0, 0, 30);
					BackgroundTransparency = 1;
				};
				text = create {
					className = "TextLabel";
					AutomaticSize = Enum.AutomaticSize.XY;
					BackgroundTransparency = 1;
					BorderSizePixel = 0;
					Position = UDim2.new(0.5, 0, 0.5, 0);
					AnchorPoint = Vector2.new(0.5, 0.5);
					Size = UDim2.new(1, 0, 0, 50);
					FontFace = Font.new("rbxassetid://16658246179", Enum.FontWeight.Medium);
					TextSize = 18;
					TextWrapped = true;
					TextColor3 = Color3.new(1, 1, 1); 
					Text = properties.text;
					TextTransparency = 1;
				};
			}
		}
		
		-- fade in
		tweenService:Create(paddingBearer.instance, mainTweenInfo, {
			Size = UDim2.fromOffset(300, 100);
		}):Play()
		
		tweenService:Create(notification.children.stroke.instance, mainTweenInfo, {
			Transparency = 0.9;
		}):Play()
		
		tweenService:Create(notification.children.progressBar.instance, mainTweenInfo, {
			BackgroundTransparency = 0;
		}):Play()
		
		tweenService:Create(notification.children.line.instance, mainTweenInfo, {
			BackgroundTransparency = 0.9;
		}):Play()
		
		tweenService:Create(notification.children.title.instance, mainTweenInfo, {
			TextTransparency = 0;
		}):Play()
		
		tweenService:Create(notification.children.text.instance, mainTweenInfo, {
			TextTransparency = 0;
		}):Play()
		
		tweenService:Create(notification.instance, mainTweenInfo, {
			Size = UDim2.new(1, -7, 1, -7);
			BackgroundTransparency = 0.1;
		}):Play()
		
		-- progress bar
		local duration = properties.duration or 3
		tweenService:Create(notification.children.progressBar.instance, TweenInfo.new(duration, Enum.EasingStyle.Linear), {
			Size = UDim2.new(0, 0, 0, 3);
		}):Play()
		
		task.delay(duration, function()
			activeNotifications -= 1
			
			-- fade out
			tweenService:Create(notification.children.stroke.instance, mainTweenInfo, {
				Transparency = 1;
			}):Play()

			tweenService:Create(notification.children.progressBar.instance, mainTweenInfo, {
				BackgroundTransparency = 1;
			}):Play()
			
			tweenService:Create(notification.children.line.instance, mainTweenInfo, {
				BackgroundTransparency = 1;
			}):Play()

			tweenService:Create(notification.children.title.instance, mainTweenInfo, {
				TextTransparency = 1;
			}):Play()

			tweenService:Create(notification.children.text.instance, mainTweenInfo, {
				TextTransparency = 1;
			}):Play()

			tweenService:Create(notification.instance, mainTweenInfo, {
				BackgroundTransparency = 1;
			}):Play()
			
			task.wait(mainTweenInfo.Time)
			tweenService:Create(paddingBearer.instance, mainTweenInfo, {
				Size = UDim2.new();
			}):Play()
			
			task.wait(mainTweenInfo.Time)
			
			paddingBearer.instance:Destroy()
		end)
	end
end

return vertex
