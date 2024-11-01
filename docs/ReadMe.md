# Nya Engine Documentation

Nya Engine is a lightweight 2D game engine built on LÖVE2D. It is designed to be community-friendly and includes physics capabilities using Box2D, allowing developers to create games with basic physics-based interactions.

---

## Table of Contents
1. [Getting Started](#getting-started)
2. [Core Components](#core-components)
   - [NyaEngine](#nyaengine)
   - [Scene](#scene)
   - [PhysicsObject](#physicsobject)
3. [Basic Usage](#basic-usage)
4. [Extending the Engine](#extending-the-engine)
5. [Example Code](#example-code)
6. [Known Limitations and Future Improvements](#known-limitations-and-future-improvements)

---

## Getting Started

### Requirements
- **LÖVE2D**: Install LÖVE2D version 11.3 or newer from [https://love2d.org/](https://love2d.org/).
- **Nya Engine Files**: Include the following files in your project directory:
  - `main.lua`
  - `nya_engine.lua`
  - `scene.lua`
  - `physics_object.lua`
  - `ui.lua` (if using the UI editor)
  - `ui_button.lua`
  - `ui_color_picker.lua`

### Running the Engine
To run Nya Engine:
1. Open your terminal in the project directory.
2. Execute the command: `love .`

---

## Core Components

### NyaEngine
The `NyaEngine` class manages the game’s core, including scenes, physics, and the main update and render loop.

- **Initialization**: `NyaEngine:init()`
  - Initializes the physics world and creates the first scene.

- **addScene(name, scene)**: Adds a scene to the engine.
  - `name` (string): Identifier for the scene.
  - `scene` (Scene): Instance of a scene.

- **switchScene(name)**: Switches the active scene.
  - `name` (string): Name of the scene to switch to.

- **update(dt)**: Updates the engine, including the physics world.
  - `dt` (float): Delta time since the last frame.

- **render()**: Renders the active scene.

### Scene
Scenes are containers that hold game objects. Each scene runs independently and can be switched as needed.

- **new(world)**: Initializes a scene with a reference to the physics world.
  - `world` (love.physics.World): The physics world used by the engine.

- **addObject(object)**: Adds an object to the scene.
  - `object` (GameObject): Any object with `update()` and `render()` methods.

- **removeObject(object)**: Removes an object from the scene.
  - `object` (GameObject): Object to remove.

- **update(dt)**: Updates all objects in the scene.
  - `dt` (float): Delta time.

- **render()**: Renders all objects in the scene.

### PhysicsObject
`PhysicsObject` is a class that extends the basic game object with Box2D physics capabilities.

- **new(world, x, y, width, height, type)**: Creates a new physics object.
  - `world` (love.physics.World): Physics world.
  - `x`, `y` (float): Initial position of the object.
  - `width`, `height` (float): Dimensions of the object.
  - `type` (string): Type of physics body (`"dynamic"`, `"static"`, or `"kinematic"`).

- **update(dt)**: Updates the object’s position based on physics.

- **render()**: Renders the object at its current position, rotation, and color.

- **destroy()**: Cleans up the object’s physics body and removes it from the world.

---

## Basic Usage

1. **Initialize the Engine**: Create an instance of `NyaEngine` in `main.lua` and initialize it in `love.load()`.

2. **Create and Add Physics Objects**:
   - Use `PhysicsObject` to create interactive objects and add them to the active scene.
   - Example: Create a ground platform and a falling box.

3. **Set Up Physics**: Configure gravity or other physics properties in `NyaEngine`.

4. **UI for Object Manipulation** (Optional): If using `ui.lua`, you can add UI elements for creating, moving, and deleting objects.

### Example Setup in `main.lua`

```lua
local NyaEngine = require("nya_engine")
local PhysicsObject = require("physics_object")

function love.load()
    -- Initialize the engine
    NyaEngine:init()

    -- Create and add objects
    local ground = PhysicsObject:new(NyaEngine.physicsWorld, 400, 550, 800, 50, "static")
    NyaEngine.activeScene:addObject(ground)

    local box = PhysicsObject:new(NyaEngine.physicsWorld, 400, 100, 50, 50, "dynamic")
    NyaEngine.activeScene:addObject(box)
end

function love.update(dt)
    NyaEngine:update(dt)
end

function love.draw()
    NyaEngine:render()
end
```

---

## Extending the Engine

Nya Engine is designed to be simple yet extensible. Here are some ways to extend it:

1. **Additional Physics Properties**: Add properties like density, friction, and restitution to `PhysicsObject` for more customization.
2. **Collision Handling**: Use `setCallbacks` in the physics world to handle custom collision events.
3. **User Interface**: Expand `ui.lua` with additional controls for object manipulation (scaling, rotation, color changes).
4. **Scene Management**: Add more sophisticated scene transitions or multiple scenes.

---

## Example Code

Here’s a brief example that demonstrates how to create a ground object, a dynamic box, and handle basic collision detection.

```lua
local NyaEngine = require("nya_engine")
local PhysicsObject = require("physics_object")

function love.load()
    -- Initialize engine
    NyaEngine:init()

    -- Create ground (static)
    local ground = PhysicsObject:new(NyaEngine.physicsWorld, 400, 580, 800, 50, "static")
    NyaEngine.activeScene:addObject(ground)

    -- Create a dynamic box that will fall
    local box = PhysicsObject:new(NyaEngine.physicsWorld, 400, 50, 50, 50, "dynamic")
    NyaEngine.activeScene:addObject(box)

    -- Set collision callbacks
    NyaEngine.physicsWorld:setCallbacks(
        function(a, b, coll) print("Collision started") end,
        function(a, b, coll) print("Collision ended") end
    )
end

function love.update(dt)
    NyaEngine:update(dt)
end

function love.draw()
    NyaEngine:render()
end
```

---

## Known Limitations and Future Improvements

### Current Limitations
- **Basic Physics**: Currently only supports basic rectangle shapes. Adding support for other shapes (e.g., circles) would enhance the engine.
- **No Scene Transitions**: Scene transitions (e.g., fade-in/fade-out) are not built-in.
- **Limited UI**: The built-in UI is minimal and meant for basic manipulation. It can be expanded with additional controls.

### Planned Improvements
- **Expanded Physics Properties**: Adding density, friction, and restitution properties for physics objects.
- **Customizable Gravity**: Allow setting gravity direction and magnitude per scene.
- **Animation Support**: Introduce sprite animations and basic timelines for character actions.
- **Save and Load Scenes**: Enable saving scenes to file for persistence.
- **A lot more**: Since this engine is currently being developed we will constantly add new features such as: camera, assets, lighting, audio, etc.

---

### Contributions

**Nya Engine** is open for community contributions! To contribute:
1. Fork the project.
2. Add your feature or fix.
3. Submit a pull request for review.

---

With **Nya Engine**, you have a simple yet powerful base to create physics-driven 2D games with LÖVE2D. Use this documentation as a guide, and feel free to expand on it as you develop more complex features!
