# Nya Engine

**Nya Engine** is a community-driven 2D game engine built with [LÖVE2D](https://love2d.org/), designed to be lightweight, easy to use, and *kawaii* 🌸. With a simple UI and physics integration, Nya Engine allows developers to create interactive 2D games quickly.

## Table of Contents

- [Features](#features)
- [Installation](#installation)
- [Usage](#usage)
- [Creating Your First Object](#creating-your-first-object)
- [UI Features](#ui-features)
- [Physics Integration](#physics-integration)
- [Contributing](#contributing)
- [License](#license)

---

## Features

- **Cute and Customizable UI**: A kawaii-themed interface that lets you create and manipulate objects with ease.
- **Physics Integration**: Powered by Box2D for realistic movement, collisions, and gravity.
- **Scene Management**: Easily manage multiple scenes within a project.
- **Object Creation & Manipulation**: Add, move, resize, and delete objects directly in the engine.
- **Color Picker**: Customize object colors through a built-in RGB slider.

## Installation

1. **Clone the Repository**:
   ```bash
   git clone https://github.com/your-username/Nya-Engine.git
   ```
2. **Install LÖVE2D**:
   - Download [LÖVE2D](https://love2d.org/) (version 11.3 or newer).
   - Follow the instructions on the LÖVE2D website for installation.

3. **Run the Engine**:
   ```bash
   love Nya-Engine
   ```

## Usage

### 1. Launching Nya Engine

Open the Nya Engine project using LÖVE2D:
```bash
love .
```

### 2. Adding Objects

Use the UI buttons to add, select, delete, or modify objects within the scene. Each object is represented visually in the editor and can be customized.

## Creating Your First Object

1. Launch Nya Engine and load the default scene.
2. Use the **"Add Object"** button to create a new game object.
3. Modify its properties:
   - **Position**: Drag and drop it on the screen.
   - **Color**: Use the color picker to adjust the object's color.
   - **Physics**: The object will fall and interact with other physics-enabled objects.

## UI Features

The Nya Engine UI is designed with a kawaii aesthetic and includes:

- **Add/Delete Buttons**: Quickly add or remove objects from the scene.
- **Color Picker**: Adjust RGB values to customize object colors.
- **Physics Control**: Easily switch between static, dynamic, and kinematic physics types.

## Physics Integration

Nya Engine utilizes LÖVE2D's built-in Box2D engine for physics, which provides:

- **Gravity**: Objects will fall according to the set gravity.
- **Collision Detection**: Objects will collide naturally with others in the scene.
- **Body Types**: Supports `dynamic`, `static`, and `kinematic` body types for diverse object behaviors.

### Example Physics Object

```lua
local PhysicsObject = require("physics_object")
local box = PhysicsObject:new(NyaEngine.physicsWorld, 400, 100, 50, 50, "dynamic")
NyaEngine.activeScene:addObject(box)
```

## Contributing

We welcome contributions from the community! Here’s how you can get involved:

1. **Fork the repository** and create your branch:
   ```bash
   git checkout -b feature/AmazingFeature
   ```
2. **Commit your changes** and submit a pull request.
3. Join our [Discord server](https://discord.com/invite/example) to discuss features, report bugs, and meet the community.

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

---

**Nya Engine** is maintained by community contributors, with love and a sprinkle of *nyan-ness* 🐾. Let’s build something cute and fun together!

---

## Support
If you find this engine useful and would like to support its development, consider making a donation. Your contributions help cover development costs and improve the engine. Here’s how you can support:

[![ko-fi](https://ko-fi.com/img/githubbutton_sm.svg)](https://ko-fi.com/M4M5XFVTB)

---

## Contact
You can contact us through any of those ways:

BlueSky: https://nyaengine.bsky.social

Discord: https://discord.gg/SnAnC4x7VT
