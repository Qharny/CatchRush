# CatchRush - Component Structure

This Flutter game has been refactored into a well-organized component-based architecture.

## Project Structure

```
lib/
├── main.dart                 # Main app entry point
├── models/
│   └── game_models.dart      # Data models (GameScore, UserData, GameSettings)
├── services/
│   ├── data_service.dart     # Data persistence and management
│   └── game_logic_service.dart # Game mechanics and calculations
├── screens/
│   └── game_screen.dart      # Main game screen
└── widgets/
    ├── game_ui_widgets.dart  # Reusable UI components
    └── dialog_widgets.dart   # Dialog and modal components
```

## Components Overview

### Models (`lib/models/`)
- **GameScore**: Represents a single game score with date and level
- **UserData**: Player information, statistics, and achievements
- **GameSettings**: Game configuration and preferences

### Services (`lib/services/`)
- **DataService**: Handles all data persistence using Hive
- **GameLogicService**: Contains game mechanics, collision detection, and calculations

### Screens (`lib/screens/`)
- **GameScreen**: Main game interface that orchestrates all components

### Widgets (`lib/widgets/`)
- **game_ui_widgets.dart**: Reusable UI components
  - `ScoreDisplay`: Shows current score and level
  - `LivesDisplay`: Shows remaining lives
  - `HighScoreDisplay`: Shows high score
  - `FallingObject`: Renders the falling apple
  - `Basket`: Renders the player's basket
  - `ControlButton`: Reusable control button

- **dialog_widgets.dart**: Dialog and modal components
  - `StatsDialog`: Shows game statistics
  - `ClearDataDialog`: Confirmation dialog for clearing data
  - `GameOverDialog`: Game over screen
  - `StartGameDialog`: Start game screen

## Benefits of This Structure

1. **Separation of Concerns**: Each component has a single responsibility
2. **Reusability**: UI widgets can be reused across different screens
3. **Maintainability**: Easy to modify individual components without affecting others
4. **Testability**: Each component can be tested independently
5. **Scalability**: Easy to add new features by creating new components

## Usage

The main entry point (`main.dart`) initializes the data service and launches the game screen. The game screen then uses all the components to create the complete game experience.

## Data Flow

1. **DataService** manages all data persistence
2. **GameLogicService** handles game calculations
3. **GameScreen** coordinates between UI and logic
4. **Widgets** render the UI based on game state

This architecture makes the code more organized, maintainable, and easier to extend with new features. 