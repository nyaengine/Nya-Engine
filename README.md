<p align="left">
  <img width="100" alt="Nya Engine logo" src="docs/NyaEngine.jpg">
</p>

# Nya Engine

**Nya Engine** is a community-driven 2D game engine built with [LÖVE2D](https://love2d.org/), designed to be lightweight, easy to use, and *kawaii* 🌸. Nya Engine includes an integrated IDE, visual scripting, Lua coding, object and scene management, UI customization, and more — all to empower game developers to create amazing interactive 2D games quickly and easily.

## Table of Contents

- [Features](#features)
- [Installation](#installation)
- [Usage](#usage)
  - [Launching Nya Engine](#launching-nya-engine)
  - [Creating Your First Object](#creating-your-first-object)
- [UI Features](#ui-features)
- [Physics Integration](#physics-integration)
- [Visual and Lua Coding](#visual-and-lua-coding)
- [Scenes & Objects](#scenes-objects)
- [Contributing](#contributing)
- [License](#license)
- [Support](#support)
- [Contact](#contact)

---

## Features

- **Integrated IDE**: A built-in IDE for game development, making it easier to code and visualize your projects.
- **Visual Coding**: Create game logic using an intuitive drag-and-drop interface, no coding skills required.
- **Lua Scripting**: Full Lua scripting support for those who want to create complex game logic and functionality.
- **UI System**: Build and customize user interfaces directly within the engine with a fully integrated UI system.
- **Physics Integration**: Use Box2D for realistic object behavior with gravity, collisions, and physics interactions.
- **Object Creation & Scene Management**: Easily create, manipulate, and manage game objects and scenes.
- **Scene Transitions**: Switch between scenes seamlessly, making it easier to manage different parts of your game.
- **Color Customization**: Adjust object colors using an intuitive built-in RGB color picker.

## Installation

### 1. Clone the Repository:
```bash
git clone https://github.com/Virus10Official/Nya-Engine.git
```

### 2. Install LÖVE2D:
- Download [LÖVE2D](https://love2d.org/) (version 11.3 or newer).
- Follow the installation instructions on the LÖVE2D website.

### 3. Run the Engine:
```bash
love Nya-Engine
```

## Usage

### Launching Nya Engine
Once the engine is set up, launch it using LÖVE2D:
```bash
love .
```

### Creating Your First Object
1. Open Nya Engine and load the default scene.
2. Click on the **"Add Object"** button to create a new game object.
3. Use the UI tools to modify its properties:
   - **Position**: Drag and drop the object to set its position.
   - **Size & Color**: Customize the object's size and color using the built-in tools.
   - **Physics**: Enable physics for the object (gravity, collision detection, etc.).

## UI Features

Nya Engine features a kawaii-themed UI designed for ease of use and functionality:

- **Object Creation**: Easily add new objects to the scene using the UI buttons.
- **Scene Management**: Switch between scenes with ease using the scene manager.
- **UI Customization**: Use the built-in UI tools to customize buttons, sliders, and layouts.
- **Physics Control**: Toggle between static, dynamic, and kinematic physics types for objects.
- **Color Picker**: Adjust the color of objects with an RGB slider for precise color control.

## Physics Integration

Nya Engine utilizes **Box2D** for physics, providing:

- **Gravity**: Objects respond to gravity and fall naturally.
- **Collision Detection**: Objects collide with each other and interact accordingly.
- **Body Types**: Support for `dynamic`, `static`, and `kinematic` body types to suit different needs.

### Example Physics Object:
```lua
local PhysicsObject = require("physics_object")
local box = PhysicsObject:new(NyaEngine.physicsWorld, 400, 100, 50, 50, "dynamic")
NyaEngine.activeScene:addObject(box)
```

## Visual and Lua Coding

Nya Engine supports both **Visual Coding** and **Lua Scripting**:

- **Visual Coding**: Use a drag-and-drop interface to create game logic without writing code. This is perfect for those who want to quickly prototype or don't have coding experience.
- **Lua Scripting**: For developers who prefer to write code, Nya Engine fully supports Lua scripting, allowing you to create complex game mechanics, handle events, and interact with the engine’s features.

## Scenes & Objects

- **Scenes**: Nya Engine supports multiple scenes, allowing you to manage different parts of your game (e.g., menus, levels) with ease. Switch between scenes through scripting or UI controls.
- **Objects**: Objects are the building blocks of your game, and you can add, delete, and manipulate them within the engine. Each object can have its own properties like position, size, color, and physics.

## Contributing

We welcome contributions from the community! Here's how you can get involved:

1. **Fork the repository** and create your branch:
   ```bash
   git checkout -b feature/AmazingFeature
   ```
2. **Commit your changes** and submit a pull request.
3. Join our [Discord server](https://discord.com/invite/example) to discuss features, report bugs, and meet the community.

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

---

## Contact

You can contact us through any of the following ways:

- **BlueSky**: [@NyaEngine](https://nyaengine.bsky.social)
- **Discord**: [Join our Discord community](https://discord.gg/SnAnC4x7VT)


## Support
If you find this engine useful and would like to support its development, consider making a donation. Your contributions help cover development costs and improve the engine. Here’s how you can support:

[![ko-fi](https://ko-fi.com/img/githubbutton_sm.svg)](https://ko-fi.com/M4M5XFVTB)
