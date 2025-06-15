# Vertex

A OOP-based GUI library built from scratch.

```lua
local VertexLibrary = loadstring(game:HttpGetAsync("https://raw.githubusercontent.com/3skue/Vertex/refs/heads/main/guiLibrary.luau"))()

local window = VertexLibrary.newWindow()
local aimbotTab = window:newTab()
	:setName("Aimbot")
	:setIcon("rbxassetid://7072715317")

aimbotTab:newLabel()
  :setText("Test label")
aimbotTab:newButton()
aimbotTab:newTextBox()
aimbotTab:newToggle()
aimbotTab:newDropdown()
  :addItem("test")
  :addItem("abcd")
aimbotTab:newSlider()
aimbotTab:newRangeSlider()
aimbotTab:newKeybind()
aimbotTab:newColorPicker()
aimbotTab:newProgressBar()
```
