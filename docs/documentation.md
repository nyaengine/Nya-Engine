# **Moonwave Game Engine Documentation**

## **Overview**

This game engine is designed to provide a simple yet expandable framework for 2D game development in Lua using the Love2D framework. It includes core features like UI elements, a camera system, user-defined entities, and a basic export functionality. The engine is organized into several key modules, each responsible for a specific part of the game.

## **Directory Structure**

```
MW Engine/
├── game/
│   ├── scenes/              # Folder for game scenes (levels, menus, etc.)
│   ├── game_object.lua      # Base class for all game objects/entities
├── assets/              # Contains images, sounds, and other assets
├── engine/
│   ├── engine.lua           # Core engine management (initialization, update, draw)
│   ├── camera.lua           # Camera module to manage game view transformations
│   ├── ui/                  # UI elements folder
│   │   ├── button.lua       # Button UI element
│   │   ├── label.lua        # Label UI element
│   │   ├── textbox.lua      # Textbox UI element
│   │   └── ui_manager.lua   # UI Manager for handling UI elements
├── main.lua             # Main entry point of the game
└── ui_creator.lua           # UI for creating and managing game entities
```

## **Core Modules**

### **1. Main Game Loop (`main.lua`)**

**Purpose**:  
The `main.lua` file is the entry point of the game, responsible for initializing the engine, updating game state, and rendering everything on the screen.

**Key Functions**:
- `love.load()`: Initializes the engine, camera, UI creator, and sets up initial states.
- `love.update(dt)`: Updates the engine, camera, and UI creator.
- `love.draw()`: Draws game objects within the camera's view and UI elements fixed to the screen.
- `love.mousepressed(x, y, button)`: Handles mouse inputs for UI interactions and object placements.
- `love.textinput(text)`: Handles text input for text boxes.
- `love.keypressed(key)`: Handles key presses for UI elements and game controls.

### **2. Engine (`engine/engine.lua`)**

**Purpose**:  
Manages the core engine functionalities, including initialization, updating, and rendering. This module coordinates all other systems, ensuring the game loop runs smoothly.

**Key Functions**:
- `Engine:init()`: Sets up the initial state of the engine, including loading necessary resources.
- `Engine:update(dt)`: Updates all game elements managed by the engine.
- `Engine:draw()`: Draws game elements onto the screen.

### **3. Camera System (`engine/camera.lua`)**

**Purpose**:  
Handles the camera movement, zoom, and screen transformations, allowing dynamic views of the game world. UI elements remain fixed to the screen and are not affected by camera movement.

**Key Functions**:
- `Camera:new()`: Initializes the camera with default position and zoom settings.
- `Camera:update(dt)`: Updates the camera position based on input.
- `Camera:attach() / Camera:detach()`: Applies and resets the camera transformation for drawing game elements.
- `Camera:move(dx, dy)`: Moves the camera by a specified amount.
- `Camera:zoom(scale)`: Adjusts the camera zoom level.

### **4. Game Object (`game/game_object.lua`)**

**Purpose**:  
Defines the basic structure for all game entities. Handles properties like position, size, and color, and provides methods for movement and interaction.

**Key Functions**:
- `GameObject:new(x, y, width, height, color)`: Creates a new game object with specified properties.
- `GameObject:update(dt)`: Updates the object's state (e.g., movement if selected).
- `GameObject:draw()`: Renders the object on the screen.
- `GameObject:isClicked(mx, my)`: Checks if the object is clicked based on mouse coordinates.
- `GameObject:setColor(color)`: Changes the object's color.
- `GameObject:setSize(width, height)`: Adjusts the object's size.
- `GameObject:setPosition(x, y)`: Moves the object to a new position.

### **5. UI Manager (`engine/ui/ui_manager.lua`)**

**Purpose**:  
Manages all UI elements, ensuring they are updated and rendered properly. Handles interactions between UI components and the player.

**Key Functions**:
- `UIManager:new()`: Creates a new UI Manager instance.
- `UIManager:addElement(element)`: Adds a UI element (button, textbox, etc.) to the manager.
- `UIManager:update(dt)`: Updates all managed UI elements.
- `UIManager:draw()`: Draws all UI elements.
- `UIManager:mousepressed(x, y, button)`: Handles mouse input for UI elements.

### **6. UI Elements (`engine/ui/`)**

**Purpose**:  
Contains various UI elements like buttons, labels, and textboxes. Each element has its own set of properties and behaviors.

- **Button (`button.lua`)**: 
  - Used for clickable buttons.
  - Key functions: `Button:new(x, y, width, height, text, onClick)`, `Button:draw()`, `Button:update()`.
  
- **Label (`label.lua`)**: 
  - Displays static text on the screen.
  - Key functions: `Label:new(x, y, text)`, `Label:draw()`.
  
- **Textbox (`textbox.lua`)**: 
  - Provides a field for user input.
  - Key functions: `Textbox:new(x, y, width, height)`, `Textbox:draw()`, `Textbox:textinput(text)`, `Textbox:keypressed(key)`.

### **7. UI Creator (`ui_creator.lua`)**

**Purpose**:  
Provides an interface for creating, placing, and managing game entities. Includes buttons for adding new entities, deleting selected ones, and allows users to interactively place and modify entities on the screen.

**Key Functions**:
- `UICreator:new()`: Initializes the UI Creator with buttons for managing entities.
- `UICreator:update(dt)`: Updates the UI and all managed entities.
- `UICreator:draw()`: Renders the UI and entities on the screen.
- `UICreator:mousepressed(x, y, button)`: Handles mouse input for creating new entities and selecting existing ones.

### **8. Export Functionality**

**Purpose**:  
Allows users to export the created game into a standalone package. This feature packages the game's assets and code into a format suitable for distribution.

**Key Features**:
- Exports assets, scenes, and main game logic.
- Generates configuration files for easy launching of the game.

## **Extending the Engine**

### **Adding New UI Elements**
To add a new UI element, create a new file in the `engine/ui/` directory. Define the element’s appearance, behavior, and interaction functions. Register the new element in the UI Manager to integrate it with the rest of the UI system.

### **Creating New Game Entities**
New game entities can be created by extending the `GameObject` class. Define new properties or behaviors specific to the entity. Integrate the entity creation into `ui_creator.lua` to make it available to users via the UI.

### **Expanding the Camera System**
Enhance the camera system by adding features like screen shake, camera locking, or path-following. Modify `camera.lua` to implement these features and adjust how the camera interacts with game objects.

### **Advanced Export Options**
To add more export options, modify the export script to support different platforms or packaging formats. Integrate additional asset handling or configuration options to cater to the game's needs.
