<p align="left">
  <img width="100" alt="Nya Engine logo" src="docs/NyaEngine.jpg">
</p>

# Nya Engine Documentation

**Nya Engine** is a community-driven 2D game engine built with [LÖVE2D](https://love2d.org/), designed to be lightweight, easy to use, and *kawaii* 🌸. Nya Engine includes an integrated IDE, visual scripting, Lua coding, object and scene management, UI customization, and more — all to empower game developers to create amazing interactive 2D games quickly and easily.

## Table of Contents

- [Syntax](#syntax)

## Syntax

Nya Engine uses the default LÖVE syntax and some additional changes.

- ButtonLibrary
It's a library for easy creation of buttons.

To create a button use ButtonLibrary:new(x, y, width, height, text, function, image(optional))

for example: 

```lua
    function love.load()
      Button = ButtonLibrary:new(0, 100, 500, 100, "Test", function()
        print("test")
    end)
```

You can also change the background transparency by using this code:

```lua
    Button:IsVisibleBG(false) -- true or false
```

or 

``` lua
    Button:SetTransparency(1) -- transparency value
```

If you want to change the button position while the game is running you can do:

```lua
    function love.draw()
        Button:setPosition(x, y)
    end
```

This is the whole example for creating buttons:

```lua
    local ButtonPressed = false

    function love.load()
      Button = ButtonLibrary:new(0, 100, 500, 100, "Test", function()
        ButtonPressed = not ButtonPressed
    end)

    function love.update(dt)
        local mouseX, mouseY = love.mouse.getPosition()

        Button:update(mouseX, mouseY)
    end

    function love.draw()
        Button:draw()

        if ButtonPressed == true then
            Button:setPosition(100, 100)
        else
            Button:setPosition(0, 100)
        end
    end

    function love.mousepressed(x, y, button, istouch, presses)
        Button:mousepressed(x, y, button)
    end
```

This code makes it so when the button is pressed then it changes the position