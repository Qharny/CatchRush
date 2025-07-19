# CatchRush - Component Structure

This Flutter game has been refactored into a well-organized component-based architecture with full Hive integration for data persistence and caching.

## Project Structure

```
lib/
├── main.dart                 # Main app entry point
├── models/
│   └── game_models.dart      # Hive data models (GameScore, UserData, GameSettings, GameCache)
├── services/
│   ├── data_service.dart     # Data persistence and management with Hive
│   ├── game_logic_service.dart # Game mechanics and calculations
│   └── cache_service.dart    # Advanced caching functionality
├── screens/
│   └── game_screen.dart      # Main game screen
└── widgets/
    ├── game_ui_widgets.dart  # Reusable UI components
    └── dialog_widgets.dart   # Dialog and modal components
```

## Components Overview

### Models (`lib/models/`)
- **GameScore**: Represents a single game score with date and level (Hive persisted)
- **UserData**: Player information, statistics, and achievements (Hive persisted)
- **GameSettings**: Game configuration and preferences (Hive persisted)
- **GameCache**: Screen dimensions, session data, and additional cache data (Hive persisted)

### Services (`lib/services/`)
- **DataService**: Handles all Hive data operations with typed boxes
- **GameLogicService**: Contains game mechanics, collision detection, and calculations
- **CacheService**: Advanced caching functionality for basket position, game state, and user preferences

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

## Hive Integration Features

### Data Persistence
- **Game Scores**: All game scores are automatically saved to Hive
- **User Data**: Player statistics, achievements, and preferences are persisted
- **Game Settings**: Sound, vibration, game speed, and theme settings are saved
- **Cache Data**: Screen dimensions, basket position, and session data are cached

### Cache Management
- **Basket Position**: Automatically saves and restores basket position
- **Game State**: Can save and restore current game state
- **User Preferences**: Stores user-specific preferences and settings
- **Session Data**: Tracks last session information and screen dimensions

### Cache Service Features
- `saveBasketPosition()`: Save current basket position
- `getBasketPosition()`: Retrieve cached basket position
- `saveGameState()`: Save current game state (score, level, lives)
- `getGameState()`: Retrieve cached game state
- `saveUserPreferences()`: Save user preferences
- `getUserPreferences()`: Retrieve user preferences
- `clearAllCache()`: Clear all cached data
- `getCacheStats()`: Get cache statistics and information

## Benefits of This Structure

1. **Separation of Concerns**: Each component has a single responsibility
2. **Reusability**: UI widgets can be reused across different screens
3. **Maintainability**: Easy to modify individual components without affecting others
4. **Testability**: Each component can be tested independently
5. **Scalability**: Easy to add new features by creating new components
6. **Data Persistence**: Full Hive integration for reliable data storage
7. **Caching**: Advanced caching system for better user experience

## Usage

The main entry point (`main.dart`) initializes the data service with Hive and launches the game screen. The game screen then uses all the components to create the complete game experience with full data persistence.

## Data Flow

1. **DataService** manages all Hive data persistence with typed boxes
2. **CacheService** handles advanced caching functionality
3. **GameLogicService** handles game calculations
4. **GameScreen** coordinates between UI and logic
5. **Widgets** render the UI based on game state

## Hive Setup

The app uses Hive for data persistence with the following setup:
- **GameScore**: TypeId 0 - Stores individual game scores
- **UserData**: TypeId 1 - Stores player information and achievements
- **GameSettings**: TypeId 2 - Stores game configuration
- **GameCache**: TypeId 3 - Stores cache data and session information

All Hive adapters are automatically generated using `build_runner`.

This architecture makes the code more organized, maintainable, and provides reliable data persistence with advanced caching capabilities. 