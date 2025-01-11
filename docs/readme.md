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
      ButtonLibrary:new(0, 100, 500, 100, "Test", function()
        print("test")
    end)
```

