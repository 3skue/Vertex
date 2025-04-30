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

function tabClass:setIcon(value: string)
	self.selectionButton.children.icon.instance.Image = value

	return self
end

function tabClass:setName(value: string)
	self.name = value
	self.selectionButton.instance.Text = value

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
			FontFace = Font.new("rbxassetid://16658246179");
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
									FontFace = Font.new("rbxassetid://16658246179");
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
				FontFace = Font.new("rbxassetid://16658246179");
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

	function buttonClass:setCallback(value)
		self.callback = value

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
				FontFace = Font.new("rbxassetid://16658246179");
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
		
		table.insert(button.connections, button.object.instance.Activated:Connect(function()
			if button.callback then
				button.callback()
			end
		end))

		return button
	end
end

--/ textbox
do
	local textboxClass = {}
	textboxClass.__index = textboxClass

	function textboxClass:destroy()
		cleanUp(self)
	end

	function textboxClass:setCallback(value)
		self.callback = value

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
						FontFace = Font.new("rbxassetid://16658246179");
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

	function toggleClass:setText(value)
		self.object.instance.Text = value
	end

	function toggleClass:setCallback(value)
		self.callback = value

		return self
	end

	function toggleClass:setState(newValue: boolean)
		self.state = newValue
		self.object.children.image.instance.Image = (newValue == true and "rbxassetid://7072725342") or "rbxassetid://7072706620";
		
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
				FontFace = Font.new("rbxassetid://16658246179");
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

		if defaultState ~= nil then
			toggle:setState(defaultState)
		end
		
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

	function dropdownClass:setTitle(value)
	end

	function dropdownClass:setCallback(value)
		self.callback = value

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
			FontFace = Font.new("rbxassetid://16658246179");
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
						FontFace = Font.new("rbxassetid://16658246179");
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

	function sliderClass:setMinimum(value: number)
		self.minimumValue = value

		return self
	end

	function sliderClass:setCallback(value)
		self.callback = value

		return self
	end

	function sliderClass:setMaximum(value: number)
		self.maximumValue = value

		return self
	end

	function sliderClass:setTitle(value: string)
		self.object.children.title.instance.Text = value

		return self
	end
	
	function sliderClass:setInterval(value: number)
		self.interval = value

		return self
	end

	function sliderClass:setValue(value: number)
		value = math.round(value / self.interval) * self.interval
		value = math.clamp(value, self.minimumValue, self.maximumValue)

		local visualValue = (value - self.minimumValue) / (self.maximumValue - self.minimumValue)

		local sliderBearer = self.object.children.sliderBearer
		sliderBearer.children.button.instance.Position = UDim2.fromScale(visualValue, 0.5)

		self.object.children.info.instance.Text = math.round(value)
		sliderBearer.children.selection.instance.Size = UDim2.new(visualValue, 0, 0, 2)
		self.value = value

		if self.callback then
			self.callback(value)
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

	function rangeSliderClass:setText(value: string)
		self.object.children.title.Text = value

		return self
	end

	function rangeSliderClass:_roundValue(n: number)
		return math.clamp(
			math.round(n / self.interval) * self.interval,
			self.minimumValue, self.maximumValue
		)
	end

	function rangeSliderClass:setValues(minimum: number, maximum: number)
		minimum, maximum = self:_roundValue(minimum), self:_roundValue(maximum)

		local visualValue = (value - self.minimumValue) / (self.maximumValue - self.minimumValue)

		local sliderBearer = self.object.children.sliderBearer
		sliderBearer.children.button.instance.Position = UDim2.fromScale(visualValue, 0.5)

		self.object.children.info.instance.Text = math.round(value)
		sliderBearer.children.selection.instance.Size = UDim2.new(visualValue, 0, 0, 2)

		self.value[1], self.value[2] = minimum, maximum

		if self.callback then
			self.callback(value)
		end

		return self
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
								Position = UDim2.fromScale(1 / 3, 0, 0.7, 0);
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
						Text = "33, 66";
						TextSize = 10;
						TextWrapped = true;
						TextXAlignment = Enum.TextXAlignment.Left;
					};
				};
			};
			connections = {};
			
			minimumValue = 0;
			maximumValue = 100;
			value = 50;
			interval = 2;
		}, rangeSliderClass)

		local sliderBearer = slider.object.children.sliderBearer
		local buttonMinimum: TextButton = sliderBearer.children.buttonMinimum.instance
		local buttonMaximum: TextButton = sliderBearer.children.buttonMaximum.instance
		local frameSize = sliderBearer.instance.AbsoluteSize

		table.insert(rangeSlider.connections, buttonMinimum.MouseButton1Down:Connect(function()
			dragging = true
			
			local dragStart = mouse.X
			local origin = button.Position.X.Scale
			
			while runService.PreRender:Wait() and dragging do
				slider:setValue(slider.minimumValue + (slider.maximumValue - slider.minimumValue) * ((mouse.X - dragStart) / frameSize.X) + origin)
			end
		end))

		table.insert(rangeSlider.connections, button.MouseButton1Down:Connect(function()
			dragging = true
			
			local dragStart = mouse.X
			local origin = button.Position.X.Scale
			
			while runService.PreRender:Wait() and dragging do
				slider:setValue(slider.minimumValue + (slider.maximumValue - slider.minimumValue) * ((mouse.X - dragStart) / frameSize.X) + origin)
			end
		end))

		return rangeSlider
	end
end

return guiLibrary
