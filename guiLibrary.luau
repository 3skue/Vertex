-- init
local players = game:GetService("Players")
local userInput = game:GetService("UserInputService")
local runService = game:GetService("RunService")
local tweenService = game:GetService("TweenService")

local player = select(2, pcall(function() return players.LocalPlayer end))
while not player do
	player = players:GetAttributeChangedSignal("LocalPlayer"):Wait()
end

local mouse = player:GetMouse()

-- constants
local DEBUGGING = runService:IsStudio()

-- gui init
local guiBearer
if DEBUGGING then
	guiBearer = player:WaitForChild("PlayerGui")
else
	if gethui then
		guiBearer = gethui()

		if cloneref then
			guiBearer = cloneref(guiBearer)
		end
	end
end

local function cleanUp(object)
	for _, connection in object.connections do
		connection:Disconnect()
	end

	for i, v in object do
		if (type(v) == "table" and v.instance) then
			v.instance:Destroy()
		end

		object[i] = nil
	end
end

local function create(properties: {
	[string]: {any};
	className: string;
	children: {[string]: Instance}?
	})
	local instance = Instance.new(properties.className)

	for _, child in properties.children or {} do
		child.instance.Parent = instance
	end

	for name, value in properties do
		if name ~= "className" and name ~= "children" then
			instance[name] = value
		end
	end

	if protectgui then
		protectgui(instance)
	end

	return {
		instance = instance;
		children = properties.children;
	}
end

-- library class
local dragging = false

local function generateClass()
	local t = {}
	t.__index = t

	return t
end

local guiLibrary = generateClass()
local tabClass = generateClass()

function tabClass:destroy()
	self:clearItems()

	cleanUp(self)
end

function tabClass:clearItems()
	for _, item in self.items do
		item:destroy()
	end
end

function tabClass:setIcon(newValue: string)
	self.selectionButton.children.icon.instance.Image = newValue

	return self
end

function tabClass:setName(newValue: string)
	self.name = newValue
	self.selectionButton.instance.Text = newValue

	return self
end

function guiLibrary:newTab()
	local tab = setmetatable({
		contentFrame = create {
			className = "ScrollingFrame";
			Parent = self.object.children.background.instance;
			BackgroundTransparency = 1;
			BorderSizePixel = 0;
			Position = UDim2.fromOffset(0, 42);
			Size = UDim2.new(1, 0, 1, -42);
			CanvasSize = UDim2.new();
			AutomaticCanvasSize = Enum.AutomaticSize.Y;
			ScrollBarThickness = 0;
			ScrollBarImageTransparency = 1;
			Visible = false;

			children = {
				layout = create {
					className = "UIListLayout";
					Padding = UDim.new(0, 7);
					HorizontalAlignment = Enum.HorizontalAlignment.Center;
					SortOrder = Enum.SortOrder.LayoutOrder;
				};
				padding = create {
					className = "UIPadding";
					PaddingBottom = UDim.new(0, 7);
					PaddingLeft = UDim.new(0, 7);
					PaddingRight = UDim.new(0, 7);
					PaddingTop = UDim.new(0, 7);
				};
			};
		};
		selectionButton = create {
			className = "TextButton";
			AutoButtonColor = false;
			Parent = self.object.children.background.children.tabSelection.instance;
			BackgroundColor3 = Color3.fromRGB(17, 17, 25);
			BackgroundTransparency = 0.37;
			LayoutOrder = #self.tabs;
			Size = UDim2.new(1, 0, 0, 30);
			FontFace = Font.new("rbxassetid://16658246179", Enum.FontWeight.Medium);
			Text = "Tab";
			TextColor3 = Color3.new(1, 1, 1);
			TextSize = 14;

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
				icon = create {
					className = "ImageLabel";
					AnchorPoint = Vector2.new(0, 0.5);
					BackgroundTransparency = 1;
					Position = UDim2.new(0, 7, 0.5, 0);
					Size = UDim2.fromOffset(15, 15);
					Image = "rbxassetid://7072715317";
					ImageColor3 = Color3.new(1, 1, 1);
				}
			}
		};
		items = {};
		connections = {};
		layoutOrder = 0;
		name = "Tab";
	}, tabClass)

	table.insert(self.tabs, tab)

	table.insert(tab.connections, tab.selectionButton.instance.Activated:Connect(function()
		tab.contentFrame.instance.Visible = true
		self.object.children.background.children.tabSelection.instance.Visible = false
		self.activeTab = tab

		self.object.children.background.children.dragBar.children.back.instance.Visible = true
	end))

	return tab
end

function guiLibrary:close()
	for _, tab in self.tabs do
		tab:destroy()
	end

	cleanUp(self)

	if self.closeCallback then
		self.closeCallback()
	end
end

function guiLibrary.newWindow()
	local window = setmetatable({
		object = create {
			Parent = guiBearer;
			className = "ScreenGui";
			IgnoreGuiInset = true;

			children = {
				background = create {
					className = "Frame";
					AnchorPoint = Vector2.new(0.5, 0.5);
					BackgroundColor3 = Color3.fromRGB(17, 17, 25);
					BackgroundTransparency = 0.1;
					Position = UDim2.fromScale(0.5, 0.5);
					Size = UDim2.fromOffset(300, 500);

					children = {
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
							Color = Color3.new(1, 1, 1);
							Transparency = 0.9;
						};

						dragBar = create {
							className = "Frame";
							BackgroundTransparency = 1;
							Size = UDim2.new(1, 0, 0, 35);

							children = {
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
									Color = Color3.new(1, 1, 1);
									Transparency = 0.9;
								};

								title = create {
									className = "TextLabel";
									BackgroundTransparency = 1;
									Size = UDim2.fromScale(1, 1);
									FontFace = Font.new("rbxassetid://16658246179", Enum.FontWeight.Medium);
									Text = "Title";
									TextColor3 = Color3.new(1, 1, 1);
									TextSize = 16;
									TextXAlignment = Enum.TextXAlignment.Left;
								};

								close = create {
									className = "TextButton";
									BackgroundTransparency = 1;
									AnchorPoint = Vector2.new(1, 0);
									Position = UDim2.new(1, 0, 0, 0);
									Size = UDim2.fromOffset(21, 21);
									FontFace = Font.new("rbxassetid://16658246179", Enum.FontWeight.Light);
									Text = "×";
									TextColor3 = Color3.new(1, 1, 1);
									TextSize = 24;
								};

								minimize = create {
									className = "TextButton";
									BackgroundTransparency = 1;
									AnchorPoint = Vector2.new(1, 0);
									Position = UDim2.new(1, -21, 0, 0);
									Size = UDim2.fromOffset(21, 21);
									FontFace = Font.new("rbxassetid://16658246179", Enum.FontWeight.Light);
									Text = "‐";
									TextColor3 = Color3.new(1, 1, 1);
									TextSize = 24;
								};

								back = create {
									className = "TextButton";
									AutoButtonColor = false;
									BackgroundColor3 = Color3.fromRGB(17, 17, 25);
									BackgroundTransparency = 1;
									Size = UDim2.new(0, 21, 0, 21);
									AnchorPoint = Vector2.new(1, 0);
									Position = UDim2.new(1, -42, 0, 0);
									FontFace = Font.new("rbxassetid://16658246179", Enum.FontWeight.Light);
									Text = "←";
									TextColor3 = Color3.new(1, 1, 1);
									TextSize = 20;
									Visible = false;
								};
							}
						};

						tabSelection = create {
							className = "ScrollingFrame";
							BackgroundTransparency = 1;
							BorderSizePixel = 0;
							Position = UDim2.fromOffset(0, 42);
							Size = UDim2.new(1, 0, 1, -42);
							ScrollBarThickness = 0;
							ScrollBarImageTransparency = 1;
							AutomaticCanvasSize = Enum.AutomaticSize.Y;
							CanvasSize = UDim2.new();

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
									HorizontalAlignment = Enum.HorizontalAlignment.Center;
									SortOrder = Enum.SortOrder.LayoutOrder;
								};
							}
						}
					}
				}
			}
		};
		tabs = {};
		connections = {};
	}, guiLibrary)

	local children = window.object.children
	local background = children.background
	local dragBar = background.children.dragBar

	local backgroundInstance = background.instance

	table.insert(window.connections, dragBar.instance.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true

			local mousePosition = Vector2.new(mouse.X, mouse.Y)
			while runService.PreRender:Wait() and dragging do
				local currentMousePosition = Vector2.new(mouse.X, mouse.Y)
				local delta = Vector2.new(
					currentMousePosition.X - mousePosition.X, currentMousePosition.Y - mousePosition.Y
				)

				backgroundInstance.Position += UDim2.fromOffset(delta.X, delta.Y)
				mousePosition = currentMousePosition
			end
		end
	end))

	table.insert(window.connections, dragBar.children.close.instance.Activated:Connect(function()
		window:close()
	end))

	local minimized = false
	table.insert(window.connections, dragBar.children.minimize.instance.Activated:Connect(function()
		minimized = not minimized

		if window.activeTab then
			window.activeTab.contentFrame.instance.Visible = not minimized
		else
			background.children.tabSelection.instance.Visible = not minimized
		end

		if minimized then
			backgroundInstance.Size -= UDim2.fromOffset(0, 451)
			backgroundInstance.Position -= UDim2.fromOffset(0, 225.5)
		else
			backgroundInstance.Size += UDim2.fromOffset(0, 451)
			backgroundInstance.Position += UDim2.fromOffset(0, 225.5)
		end
	end))

	table.insert(window.connections, dragBar.children.back.instance.Activated:Connect(function()
		window.activeTab.contentFrame.instance.Visible = false
		window.activeTab = nil

		if not minimized then
			background.children.tabSelection.instance.Visible = true
		end

		dragBar.children.back.instance.Visible = false
	end))

	table.insert(window.connections, userInput.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = false
		end
	end))

	return window
end

-- widgets

--/ label
do
	local labelClass = {}
	labelClass.__index = labelClass

	function labelClass:destroy()
		cleanUp(self)
	end

	function labelClass:setText(newValue: string)
		self.object.instance.Text = newValue

		return self
	end

	function tabClass:newLabel()
		local label = setmetatable({
			object = create {
				className = "TextLabel";
				Parent = self.contentFrame.instance;
				BackgroundTransparency = 1;
				Size = UDim2.new(1, 0, 0, 17);
				AutomaticSize = Enum.AutomaticSize.Y;
				FontFace = Font.new("rbxassetid://16658246179", Enum.FontWeight.Medium);
				TextWrapped = true;
				Text = "Label";
				TextColor3 = Color3.new(1, 1, 1);
				TextXAlignment = Enum.TextXAlignment.Left;
				TextSize = 14;
			};
		}, labelClass)

		return label
	end
end

--/ button
do
	local buttonClass = {}
	buttonClass.__index = buttonClass

	function buttonClass:destroy()
		cleanUp(self)
	end

	function buttonClass:setCallback(newValue)
		self.callback = newValue

		return self
	end

	function buttonClass:setText(newValue: string)
		self.object.instance.Text = newValue

		return self
	end

	function tabClass:newButton()
		local button = setmetatable({
			object = create {
				className = "TextButton";
				AutoButtonColor = false;
				Parent = self.contentFrame.instance;
				BackgroundColor3 = Color3.fromRGB(17, 17, 25);
				BackgroundTransparency = 0.1;
				Size = UDim2.new(1, 0, 0, 30);
				AutomaticSize = Enum.AutomaticSize.Y;
				FontFace = Font.new("rbxassetid://16658246179", Enum.FontWeight.Medium);
				TextWrapped = true;
				Text = "Label";
				TextColor3 = Color3.new(1, 1, 1);
				TextSize = 14;

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
				};
			};
			connections = {};
		}, buttonClass)

		local buttonInstance = button.object.instance
		local strokeInstance = button.object.children.stroke.instance

		table.insert(button.connections, buttonInstance.Activated:Connect(function()
			if button.callback then
				button.callback()
			end
		end))

		table.insert(button.connections, buttonInstance.MouseButton1Down:Connect(function()
			strokeInstance.Transparency = 0.75
			buttonInstance.MouseButton1Up:Wait()
			strokeInstance.Transparency = 0.9
		end))

		return button
	end
end

--/ keybind
do
	local keyStringLookup = {
		Space = "␣";
		Backspace = "[x]";
		Enter = "⏎*";
		Return = "⏎";
		LeftShift = "L⇧";
		RightShift = "R⇧";
		LeftSuper = "L⌘";
		RightSuper = "R⌘";
		Tab = "↹";
		LeftControl = "L^";
		RightControl = "R^";
		F1 = "F1";
		F2 = "F2";
		F3 = "F3";
		F4 = "F4";
		F5 = "F5";
		F6 = "F6";
		F7 = "F7";
		F8 = "F8";
		F9 = "F9";
		F10 = "F10";
		F11 = "F11";
		F12 = "F12";
		Backquote = "`";
		Right = "→";
		Left = "←";
		Up = "↑";
		Down = "↓";
		LeftAlt = "L◈";
		RightAlt = "R◈"
	}
	
	local toggleClass = {}
	toggleClass.__index = toggleClass

	function toggleClass:destroy()
		cleanUp(self)
	end

	function toggleClass:setText(newValue)
		self.object.instance.Text = newValue
	end

	function toggleClass:setCallback(newValue)
		self.callback = newValue

		return self
	end

	function toggleClass:setKey(newValue: Enum.KeyCode | Enum.UserInputType)
		local keyText = self.object.children.keyText.instance
		if newValue then
			if newValue.EnumType == Enum.KeyCode then
				keyText.Text = keyStringLookup[newValue.Name] or userInput:GetStringForKeyCode(newValue)
			else
				keyText.Text = "MB"..newValue.Name:sub(12)
			end
		else
			keyText.Text = ""
		end
		
		self.value = newValue
		
		return self
	end

	function tabClass:newKeybind(defaultKey: Enum.KeyCode)
		local keybind = setmetatable({
			object = create {
				className = "TextButton";
				AutoButtonColor = false;
				Parent = self.contentFrame.instance;
				BackgroundColor3 = Color3.fromRGB(17, 17, 25);
				BackgroundTransparency = 0.1;
				Size = UDim2.new(1, 0, 0, 30);
				AutomaticSize = Enum.AutomaticSize.Y;
				FontFace = Font.new("rbxassetid://16658246179", Enum.FontWeight.Medium);
				TextWrapped = true;
				Text = "Label";
				TextColor3 = Color3.new(1, 1, 1);
				TextSize = 14;

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
					keyText = create {
						className = "TextLabel";
						AnchorPoint = Vector2.new(1, 0.5);
						Size = UDim2.new(0, 15, 0, 15);
						Position = UDim2.new(1, -7, 0.5, 0);
						BackgroundTransparency = 1;
						AutomaticSize = Enum.AutomaticSize.Y;
						FontFace = Font.new("rbxassetid://16658246179");
						Text = "Label";
						TextColor3 = Color3.new(1, 1, 1);
						TextSize = 14;
					};
					image = create {
						className = "ImageLabel";
						AnchorPoint = Vector2.new(0, 0.5);
						Size = UDim2.new(0, 15, 0, 15);
						Position = UDim2.new(0, 7, 0.5, 0);
						BackgroundTransparency = 1;
						ImageColor3 = Color3.new(1, 1, 1);
						Image = "rbxassetid://16898613509";
						ImageRectSize = Vector2.new(48, 48);
						ImageRectOffset = Vector2.new(453, 820)
					};
				};
			};
			value = defaultKey;
			connections = {};
		}, toggleClass)

		keybind:setKey(nil)
		
		local instance = keybind.object.instance
		table.insert(keybind.connections, instance.Activated:Connect(function()
			local oldText = instance.Text
			
			keybind:setText("[ Enter target key ]")
			
			local selectedKey = userInput.InputBegan:Wait()
			if selectedKey.KeyCode == Enum.KeyCode.Escape then
				keybind:setKey(nil)
			else
				if selectedKey.UserInputType.Name:find("Mouse") then
					keybind:setKey(selectedKey.UserInputType)
				else
					keybind:setKey(selectedKey.KeyCode)
				end
			end
			
			keybind:setText(oldText)
		end))
		
		table.insert(keybind.connections, userInput.InputBegan:Connect(function(input)
			if input.KeyCode == self.value and self.callback then
				self.callback()
			end
		end))

		return keybind
	end
end

--/ textbox
do
	local textboxClass = {}
	textboxClass.__index = textboxClass

	function textboxClass:destroy()
		cleanUp(self)
	end

	function textboxClass:setCallback(newValue)
		self.callback = newValue

		return self
	end

	function textboxClass:setText(newValue: string)
		self.object.children.textBox.instance.Text = newValue

		return self
	end

	function textboxClass:setPlaceholder(newValue: string)
		self.object.children.textBox.instance.PlaceholderText = newValue

		return self
	end

	function tabClass:newTextBox()
		local textbox = setmetatable({
			object = create {
				className = "Frame";
				Parent = self.contentFrame.instance;
				BackgroundColor3 = Color3.fromRGB(17, 17, 25);
				BackgroundTransparency = 0.1;
				Size = UDim2.new(1, 0, 0, 30);
				AutomaticSize = Enum.AutomaticSize.Y;

				children = {
					image = create {
						className = "ImageLabel";
						AnchorPoint = Vector2.new(0, 0.5);
						Size = UDim2.new(0, 15, 0, 15);
						Position = UDim2.new(0, 7, 0.5, 0);
						BackgroundTransparency = 1;
						Image = "rbxassetid://7072715962";
						ImageColor3 = Color3.new(1, 1, 1);
					};
					textBox = create {
						className = "TextBox";
						BackgroundTransparency = 1;
						Size = UDim2.new(1, -28, 1, 0);
						Position = UDim2.fromOffset(28, 0);
						AutomaticSize = Enum.AutomaticSize.Y;
						FontFace = Font.new("rbxassetid://16658246179", Enum.FontWeight.Medium, Enum.FontStyle.Italic);
						PlaceholderText = "TextBox";
						Text = "";
						TextWrapped = true;
						TextColor3 = Color3.new(1, 1, 1);
						TextXAlignment = Enum.TextXAlignment.Left;
						TextSize = 14;
					};
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
				};
			};
			connections = {};
		}, textboxClass)

		table.insert(textbox.connections, textbox.object.children.textBox.instance.FocusLost:Connect(function()
			if textbox.callback then
				textbox.callback(textbox.object.instance.Text)
			end
		end))

		return textbox
	end
end

--/ toggle
do
	local toggleClass = {}
	toggleClass.__index = toggleClass

	function toggleClass:destroy()
		cleanUp(self)
	end

	function toggleClass:setText(newValue)
		self.object.instance.Text = newValue
		
		return self
	end

	function toggleClass:setCallback(newValue)
		self.callback = newValue

		return self
	end

	function toggleClass:setState(newValue: boolean)
		self.state = newValue

		local image = self.object.children.image.instance
		image.Image = (newValue == true and "rbxassetid://7072725342") or "rbxassetid://7072706620";
		image.ImageColor3 = Color3.new((newValue == true and 1) or 0, (newValue == false and 1) or 0, 0)

		if self.callback then
			self.callback(newValue)
		end
	end

	function tabClass:newToggle(defaultState: boolean)
		local toggle = setmetatable({
			object = create {
				className = "TextButton";
				AutoButtonColor = false;
				Parent = self.contentFrame.instance;
				BackgroundColor3 = Color3.fromRGB(17, 17, 25);
				BackgroundTransparency = 0.1;
				Size = UDim2.new(1, 0, 0, 30);
				AutomaticSize = Enum.AutomaticSize.Y;
				FontFace = Font.new("rbxassetid://16658246179", Enum.FontWeight.Medium);
				TextWrapped = true;
				Text = "Label";
				TextColor3 = Color3.new(1, 1, 1);
				TextSize = 14;

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
					image = create {
						className = "ImageLabel";
						AnchorPoint = Vector2.new(0, 0.5);
						Size = UDim2.new(0, 15, 0, 15);
						Position = UDim2.new(0, 7, 0.5, 0);
						BackgroundTransparency = 1;
						ImageColor3 = Color3.new(1, 1, 1);
					}
				};
			};
			state = defaultState;
			connections = {};
		}, toggleClass)

		toggle:setState(not not defaultState)

		table.insert(toggle.connections, toggle.object.instance.Activated:Connect(function()
			toggle:setState(not toggle.state)
		end))

		return toggle
	end
end

--/ dropdown
do
	local dropdownClass = {}
	dropdownClass.__index = dropdownClass

	function dropdownClass:destroy()
		cleanUp(self)
	end

	function dropdownClass:setTitle(newValue)
		self.object.instance.Text = newValue
	end

	function dropdownClass:setCallback(newValue)
		self.callback = newValue

		return self
	end

	function dropdownClass:select(name: string)
		for _, item in self.items do
			item.children.stroke.instance.Transparency = 0.9
		end

		self.items[name].children.stroke.instance.Transparency = 0.75

		if self.callback then
			self.callback(name)
		end

		return self
	end

	function dropdownClass:removeItem(name: string)
		local item = self.items[name]

		item.instance:Destroy()
		cleanUp(item)
	end

	function dropdownClass:addItem(name: string)
		if self.items[name] then return end
		self.items[name] = create {
			className = "TextButton";
			Parent = self.object.children.content.instance;
			AutoButtonColor = false;
			AutomaticSize = Enum.AutomaticSize.Y;
			BackgroundColor3 = Color3.fromRGB(17, 17, 25);
			BackgroundTransparency = 0.37;
			TextColor3 = Color3.new(1, 1, 1);
			Size = UDim2.new(1, -7, 0, 25);
			FontFace = Font.new("rbxassetid://16658246179", Enum.FontWeight.Medium);
			TextWrapped = true;
			Text = name;
			TextSize = 14;
			LayoutOrder = self.layoutOrder;

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
			};
		}

		table.insert(self.connections, self.items[name].instance.Activated:Connect(function()
			self:select(name)
		end))

		self.layoutOrder += 1

		return self
	end

	function tabClass:newDropdown()
		local dropdown = setmetatable({
			object = create {
				className = "Frame";
				Parent = self.contentFrame.instance;
				AutomaticSize = Enum.AutomaticSize.Y;
				BackgroundTransparency = 0.37;
				BackgroundColor3 = Color3.fromRGB(17, 17, 25);
				Size = UDim2.new(1, 0, 0, 50);

				children = {
					corner = create {
						className = "UICorner";
						CornerRadius = UDim.new(0, 7);
					};
					layout = create {
						className = "UIListLayout";
						HorizontalAlignment = Enum.HorizontalAlignment.Center;
						SortOrder = Enum.SortOrder.LayoutOrder;
					};
					stroke = create {
						className = "UIStroke";
						Color = Color3.new(1, 1, 1);
						Transparency = 0.9;
					};

					label = create {
						className = "TextLabel";
						AutomaticSize = Enum.AutomaticSize.Y;
						BackgroundTransparency = 1;
						Size = UDim2.new(1, 0, 0, 25);
						FontFace = Font.new("rbxassetid://16658246179", Enum.FontWeight.Medium);
						TextWrapped = true;
						Text = "Label";
						TextColor3 = Color3.new(1, 1, 1);
						TextSize = 14;
						LayoutOrder = 0;
					};

					icon = create {
						className = "ImageLabel";
						BackgroundTransparency = 1;
						Size = UDim2.fromOffset(15, 15);
						Image = "rbxassetid://7072706838";
						ImageColor3 = Color3.new(1, 1, 1);
						LayoutOrder = 1;
					};

					content = create {
						className = "ScrollingFrame";
						AnchorPoint = Vector2.new(0, 1);
						BackgroundTransparency = 1;
						LayoutOrder = 2;
						Size = UDim2.new(1, 0, 0, 40);
						CanvasSize = UDim2.new();
						AutomaticCanvasSize = Enum.AutomaticSize.Y;
						ScrollBarThickness = 0;
						ScrollBarImageTransparency = 1;

						children = {
							layout = create {
								className = "UIListLayout";
								HorizontalAlignment = Enum.HorizontalAlignment.Center;
								SortOrder = Enum.SortOrder.LayoutOrder;
								Padding = UDim.new(0, 14)
							};
							paddings = create {
								className = "UIPadding";
								PaddingBottom = UDim.new(0, 7);
								PaddingLeft = UDim.new(0, 7);
								PaddingRight = UDim.new(0, 7);
								PaddingTop = UDim.new(0, 7);
							};
						};
					};
				};
			};
			layoutOrder = 0;
			items = {};
			connections = {};
		}, dropdownClass)

		return dropdown
	end
end

--/ slider
do
	local sliderClass = {}
	sliderClass.__index = sliderClass

	function sliderClass:destroy()
		cleanUp(self)
	end

	function sliderClass:setMinimum(newValue: number)
		self.minimumValue = newValue

		return self
	end

	function sliderClass:setCallback(newValue)
		self.callback = newValue

		return self
	end

	function sliderClass:setMaximum(newValue: number)
		self.maximumValue = newValue

		return self
	end

	function sliderClass:setTitle(newValue: string)
		self.object.children.title.instance.Text = newValue

		return self
	end

	function sliderClass:setInterval(newValue: number)
		self.interval = newValue

		return self
	end

	function sliderClass:setValue(newValue: number)
		newValue = math.round(newValue / self.interval) * self.interval
		newValue = math.clamp(newValue, self.minimumValue, self.maximumValue)

		local visualValue = (newValue - self.minimumValue) / (self.maximumValue - self.minimumValue)

		local children = self.object.children
		local sliderBearerChildren = children.sliderBearer.children
		sliderBearerChildren.button.instance.Position = UDim2.fromScale(visualValue, 0.5)
		sliderBearerChildren.selection.instance.Size = UDim2.new(visualValue, 0, 0, 2)

		children.info.instance.Text = math.round(newValue)
		self.value = newValue

		if self.callback then
			self.callback(newValue)
		end

		return self
	end

	function tabClass:newSlider()
		local slider = setmetatable({
			object = create {
				className = "Frame";
				Parent = self.contentFrame.instance;

				BackgroundTransparency = 0.3;
				BackgroundColor3 = Color3.fromRGB(17, 17, 25);
				BorderSizePixel = 0;

				Size = UDim2.new(1, 0, 0, 50);
				AutomaticSize = Enum.AutomaticSize.Y;

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
			connections = {};

			minimumValue = 0;
			maximumValue = 100;
			value = 50;
			interval = 2;
		}, sliderClass)

		local sliderBearer = slider.object.children.sliderBearer
		local button: TextButton = sliderBearer.children.button.instance
		local frameSize = sliderBearer.instance.AbsoluteSize

		table.insert(slider.connections, button.MouseButton1Down:Connect(function()
			dragging = true

			local dragStart = mouse.X
			local origin = button.Position.X.Scale

			while runService.PreRender:Wait() and dragging do
				local visualValue = ((mouse.X - dragStart) / frameSize.X) + origin

				slider:setValue(slider.minimumValue + (slider.maximumValue - slider.minimumValue) * visualValue)
			end
		end))

		return slider
	end
end

--/ rangeSlider
do
	local rangeSliderClass = {}
	rangeSliderClass.__index = rangeSliderClass

	function rangeSliderClass:destroy()
		cleanUp(self)
	end

	function rangeSliderClass:setText(newValue: string)
		self.object.children.title.Text = newValue

		return self
	end

	function rangeSliderClass:setRanges(minimum: number, maximum: number)
		self.minimumValue = minimum
		self.maximumValue = maximum

		return self
	end

	function rangeSliderClass:setCallback(newValue)
		self.callback = newValue

		return self
	end

	function rangeSliderClass:setValues(minimum: number, maximum: number)
		local function roundToInterval(value)
			return math.round(value / self.interval) * self.interval
		end

		minimum = roundToInterval(minimum)
		maximum = roundToInterval(maximum)

		local oldMaximum = maximum
		maximum = math.clamp(maximum, math.min(minimum + self.interval, self.maximumValue), self.maximumValue)
		minimum = math.clamp(minimum, self.minimumValue, math.max(oldMaximum - self.interval, self.minimumValue + self.interval))

		self.value = {minimum, maximum}

		local range = self.maximumValue - self.minimumValue
		local visualMin = (minimum - self.minimumValue) / range
		local visualMax = (maximum - self.minimumValue) / range

		local children = self.object.children
		local sliderBearerChildren = children.sliderBearer.children
		sliderBearerChildren.buttonMinimum.instance.Position = UDim2.fromScale(visualMin, 0.5)
		sliderBearerChildren.buttonMaximum.instance.Position = UDim2.fromScale(visualMax, 0.5)

		local selection = sliderBearerChildren.selection.instance
		selection.Position = UDim2.fromScale(visualMin, 0.5)
		selection.Size = UDim2.new(visualMax - visualMin, 0, 0, 2)

		children.info.instance.Text = `{math.round(minimum)}/{math.round(maximum)}`

		if self.callback then
			self.callback(minimum, maximum)
		end

		return self
	end

	function rangeSliderClass:getValue()
		local n = math.random()
		local value = self.value[1] + ((self.value[2] - self.value[1]) * n)

		return math.round(value / self.interval) * self.interval
	end

	function tabClass:newRangeSlider()
		local rangeSlider = setmetatable({
			object = create {
				className = "Frame";
				Parent = self.contentFrame.instance;

				BackgroundTransparency = 0.3;
				BackgroundColor3 = Color3.fromRGB(17, 17, 25);
				BorderSizePixel = 0;

				Size = UDim2.new(1, 0, 0, 50);
				AutomaticSize = Enum.AutomaticSize.Y;

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

							buttonMinimum = create {
								className = "ImageButton";
								AnchorPoint = Vector2.new(0.5, 1);
								AutoButtonColor = false;
								BackgroundTransparency = 1;
								Position = UDim2.fromScale(1 / 3, 0.5);
								Size = UDim2.fromOffset(12.5, 12.5);
								Image = "rbxassetid://7072706663";

								children = {
									corner = create {
										className = "UICorner";
										CornerRadius = UDim.new(0, 7);
									};
								}
							};

							buttonMaximum = create {
								className = "ImageButton";
								AnchorPoint = Vector2.new(0.5, 1);
								AutoButtonColor = false;
								BackgroundTransparency = 1;
								Position = UDim2.fromScale(2 / 3, 0.5);
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
								Position = UDim2.fromScale(1 / 3, 0.5);
								Size = UDim2.new(1 / 3, 0, 0, 2);
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
						Text = "33/66";
						TextSize = 10;
						TextWrapped = true;
						TextXAlignment = Enum.TextXAlignment.Left;
					};
				};
			};
			connections = {};

			minimumValue = 0;
			maximumValue = 100;
			value = {100 / 3, 200 / 3};
			interval = 2;
		}, rangeSliderClass)

		local sliderBearer = rangeSlider.object.children.sliderBearer
		local buttonMinimum: TextButton = sliderBearer.children.buttonMinimum.instance
		local buttonMaximum: TextButton = sliderBearer.children.buttonMaximum.instance
		local frameSize = sliderBearer.instance.AbsoluteSize

		rangeSlider:setValues(100 / 3, 200 / 3)

		table.insert(rangeSlider.connections, buttonMinimum.MouseButton1Down:Connect(function()
			if dragging then return end
			dragging = true

			local dragStart = mouse.X
			local origin = buttonMinimum.Position.X.Scale

			while runService.PreRender:Wait() and dragging do
				local visualValue = ((mouse.X - dragStart) / frameSize.X) + origin

				rangeSlider:setValues(rangeSlider.minimumValue + (rangeSlider.maximumValue - rangeSlider.minimumValue) * visualValue, rangeSlider.value[2])
			end
		end))

		table.insert(rangeSlider.connections, buttonMaximum.MouseButton1Down:Connect(function()
			if dragging then return end
			dragging = true

			local dragStart = mouse.X
			local origin = buttonMaximum.Position.X.Scale

			while runService.PreRender:Wait() and dragging do
				local visualValue = ((mouse.X - dragStart) / frameSize.X) + origin

				rangeSlider:setValues(rangeSlider.value[1], rangeSlider.minimumValue + (rangeSlider.maximumValue - rangeSlider.minimumValue) * visualValue)
			end
		end))

		return rangeSlider
	end
end

--/ colorPicker
do
	local colorPickerClass = {}
	colorPickerClass.__index = colorPickerClass
	
	function colorPickerClass:destroy()
		cleanUp(self)
	end
	
	function colorPickerClass:setText(newValue: string)
		self.object.children.title.instance.Text = newValue
		
		return self
	end
	
	function colorPickerClass:setCallback(newValue: any)
		self.callback = newValue
		
		return self
	end
	
	function colorPickerClass:setColor(newValue: Color3)
		local hue, saturation, value = newValue:ToHSV()
		local children = self.object.children
		
		children.hueSlider.children.button.instance.Position = UDim2.fromScale(hue, 0.5)
		children.valueSlider.children.button.instance.Position = UDim2.fromScale(value, 0.5)
		children.saturationSlider.children.button.instance.Position = UDim2.fromScale(saturation, 0.5)
		children.hexInput.PlaceHolderText = "#"..newValue:ToHex()
		children.colorPreview.instance.BackgroundColor3 = newValue
		
		if self.callback then
			self.callback(newValue)
		end
		
		return self
	end
	
	function tabClass:newColorPicker(defaultColor: Color3)
		local colorPicker = setmetatable({
			object = create {
				className = "Frame";
				Parent = self.contentFrame.instance;

				BackgroundTransparency = 0.3;
				BackgroundColor3 = Color3.fromRGB(17, 17, 25);
				BorderSizePixel = 0;

				Size = UDim2.new(1, 0, 0, 50);
				AutomaticSize = Enum.AutomaticSize.Y;

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
					
					layout = create {
						className = "UIListLayout";
						Padding = UDim.new(0, 10);
						HorizontalAlignment = Enum.HorizontalAlignment.Center;
						SortOrder = Enum.SortOrder.LayoutOrder;
					};

					hueSlider = create {
						className = "Frame";
						BackgroundTransparency = 0;
						BackgroundColor3 = Color3.new(1, 1, 1);
						Size = UDim2.new(1, 0, 0, 4);
						LayoutOrder = 2;

						children = {
							corner = create {
								className = "UICorner";
								CornerRadius = UDim.new(0, 7);
							};
							
							gradient = create {
								className = "UIGradient";
								Color = ColorSequence.new({
									ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0));
									ColorSequenceKeypoint.new(1 / 6, Color3.fromRGB(255, 255, 0));
									ColorSequenceKeypoint.new(1 / 3, Color3.fromRGB(0, 255, 0));
									ColorSequenceKeypoint.new(1 / 2, Color3.fromRGB(0, 255, 255));
									ColorSequenceKeypoint.new(2 / 3, Color3.fromRGB(0, 0, 255));
									ColorSequenceKeypoint.new(5 / 6, Color3.fromRGB(255, 0, 255));
									ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0));
								});
							};

							button = create {
								className = "ImageButton";
								AnchorPoint = Vector2.new(0.5, 1);
								AutoButtonColor = false;
								BackgroundTransparency = 1;
								Position = UDim2.fromScale(0, 0.5);
								Size = UDim2.fromOffset(12.5, 12.5);
								Image = "rbxassetid://7072706663";

								children = {
									corner = create {
										className = "UICorner";
										CornerRadius = UDim.new(0, 7);
									};
								}
							};
						}
					};
					
					saturationSlider = create {
						className = "Frame";
						BackgroundTransparency = 0;
						BackgroundColor3 = Color3.new(1, 1, 1);
						Size = UDim2.new(1, 0, 0, 4);
						LayoutOrder = 3;

						children = {
							corner = create {
								className = "UICorner";
								CornerRadius = UDim.new(0, 7);
							};
							
							gradient = create {
								className = "UIGradient";
								Color = ColorSequence.new({
									ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 0, 0));
									ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0));
								});
							};

							button = create {
								className = "ImageButton";
								AnchorPoint = Vector2.new(0.5, 1);
								AutoButtonColor = false;
								BackgroundTransparency = 1;
								Position = UDim2.fromScale(0, 0.5);
								Size = UDim2.fromOffset(12.5, 12.5);
								Image = "rbxassetid://7072706663";

								children = {
									corner = create {
										className = "UICorner";
										CornerRadius = UDim.new(0, 7);
									};
								}
							};
						}
					};
					
					valueSlider = create {
						className = "Frame";
						BackgroundTransparency = 0;
						BackgroundColor3 = Color3.new(1, 1, 1);
						Size = UDim2.new(1, 0, 0, 4);
						LayoutOrder = 4;

						children = {
							corner = create {
								className = "UICorner";
								CornerRadius = UDim.new(0, 7);
							};
							
							gradient = create {
								className = "UIGradient";
								Color = ColorSequence.new({
									ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 0, 0));
									ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255));
								});
							};

							button = create {
								className = "ImageButton";
								AnchorPoint = Vector2.new(0.5, 1);
								AutoButtonColor = false;
								BackgroundTransparency = 1;
								Position = UDim2.fromScale(1, 0.5);
								Size = UDim2.fromOffset(12.5, 12.5);
								Image = "rbxassetid://7072706663";

								children = {
									corner = create {
										className = "UICorner";
										CornerRadius = UDim.new(0, 7);
									};
								}
							}
						}
					};
					
					colorPreview = create {
						className = "Frame";
						Size = UDim2.new(1, 0, 0, 25);
						BackgroundColor3 = Color3.new(1, 1, 1);
						LayoutOrder = 5;
						
						children = {
							corner = create {
								className = "UICorner";
								CornerRadius = UDim.new(0, 5);
							};
						};
					};
					
					hexInput = create {
						className = "TextBox";
						BackgroundTransparency = 0.9;
						BackgroundColor3 = Color3.fromRGB(17, 17, 25);
						Size = UDim2.new(1, 0, 0, 10);
						Position = UDim2.fromOffset(28, 0);
						AutomaticSize = Enum.AutomaticSize.Y;
						FontFace = Font.new("rbxassetid://16658246179", Enum.FontWeight.Medium, Enum.FontStyle.Italic);
						PlaceholderText = "#ffffff";
						Text = "";
						TextColor3 = Color3.new(1, 1, 1);
						TextXAlignment = Enum.TextXAlignment.Center;
						TextSize = 10;
						LayoutOrder = 6;
						
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
						}
					};

					title = create {
						className = "TextLabel";
						AnchorPoint = Vector2.new(1, 0);
						AutomaticSize = Enum.AutomaticSize.Y;
						BackgroundTransparency = 1;
						Size = UDim2.fromScale(1, 0);
						FontFace = Font.new("rbxassetid://16658246179", Enum.FontWeight.Medium);
						TextSize = 12;
						TextWrapped = true;
						TextColor3 = Color3.new(1, 1, 1);
						LayoutOrder = 1;
					};
				}
			};
			color = {0, 0, 1};
			connections = {};
		}, colorPickerClass)
		
		if defaultColor then
			colorPicker:setColor(defaultColor)
		end
		
		local function handleSlider(slider: any, colorIndex: string)
			local button: TextButton = slider.children.button.instance
			local frameSize = slider.instance.AbsoluteSize
			
			table.insert(colorPicker.connections, button.MouseButton1Down:Connect(function()
				if dragging then return end
				dragging = true

				local dragStart = mouse.X
				local origin = button.Position.X.Scale

				while runService.PreRender:Wait() and dragging do
					colorPicker.color[colorIndex] = math.clamp(((mouse.X - dragStart) / frameSize.X) + origin, 0, 1)
					colorPicker:setColor(Color3.fromHSV(unpack(colorPicker.color)))
				end
			end))
		end
		
		local children = colorPicker.object.children
		handleSlider(children.hueSlider, 1)
		handleSlider(children.saturationSlider, 2)
		handleSlider(children.valueSlider, 3)
		
		local hexInput: TextBox = colorPicker.object.children.hexInput.instance
		table.insert(colorPicker.connections, hexInput.FocusLost:Connect(function()
			pcall(function()
				colorPicker:setColor(Color3.fromHex(hexInput.Text))
			end)
		end))
		
		return colorPicker
	end
end

--/ progressBar
do
	local progressBarClass = {}
	progressBarClass.__index = progressBarClass
	
	function progressBarClass:destroy()
		cleanUp(self)
	end
	
	function progressBarClass:setTitle(newValue: string)
		self.object.children.title.instance.Text = newValue
		
		return self
	end
	
	function progressBarClass:setProgress(newPercent: number)
		self.object.children.sliderBearer.children.selection.instance.Size = UDim2.fromScale(newPercent, 1)
		
		return self
	end
	
	function tabClass:newProgressBar()
		local progressBar = setmetatable({
			object = create {
				className = "Frame";
				Parent = self.contentFrame.instance;

				BackgroundTransparency = 0.3;
				BackgroundColor3 = Color3.fromRGB(17, 17, 25);
				BorderSizePixel = 0;

				Size = UDim2.new(1, 0, 0, 50);
				AutomaticSize = Enum.AutomaticSize.Y;

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

							selection = create {
								className = "Frame";
								BackgroundColor3 = Color3.new(1, 1, 1);
								Position = UDim2.fromScale(0, 0, 0.7, 0);
								Size = UDim2.new(0, 0, 0, 2);
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
				}
			};
			connections = {};
		}, progressBarClass)
		
		return progressBar
	end
end

return guiLibrary
