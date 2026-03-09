# Museum AR Navigator

An Augmented Reality (AR) navigation application built with Flutter and GetX. This app helps users navigate through museums, stores, or any location by showing AR arrows and directional indicators pointing to their destinations.

## Features

✨ **AR Navigation** - Dynamic arrow indicators showing direction to destinations
🗺️ **Dual View** - Toggle between AR view and map view
📍 **Place Navigation** - Browse and select locations to navigate
🎯 **Dynamic Distance** - Real-time distance display to selected place
⚡ **GetX State Management** - Efficient state management and dependency injection

## Project Structure

```
lib/
├── main.dart                 # App entry point with GetX setup
├── models/
│   └── place_model.dart     # Place data model
├── controllers/
│   └── place_controller.dart # GetX controller for state management
├── screens/
│   └── home_screen.dart     # Main single-page application
└── widgets/
    ├── ar_view.dart         # AR visualization with arrow navigation
    ├── map_view.dart        # Map view representation
    └── place_card.dart      # Place selection card widget

assets/
└── data/
    └── places.json          # JSON file with places data (mock API)
```

## Getting Started

### 1. Install Dependencies

```bash
flutter pub get
```

### 2. Run the App

```bash
flutter run
```

## Adding New Places

To add new places to navigate, edit `assets/data/places.json`:

```json
{
  "places": [
    {
      "id": 6,
      "name": "Electronics",
      "icon": "📱",
      "description": "Latest electronic devices",
      "latitude": 40.7140,
      "longitude": -74.0040,
      "section": "Electronics",
      "distance": 95.2,
      "arImageUrl": "https://via.placeholder.com/300?text=Electronics"
    }
  ]
}
```

### Field Description:
- **id**: Unique identifier (integer)
- **name**: Display name of the place
- **icon**: Emoji icon representing the place
- **description**: Short description of the place
- **latitude**: Geographic latitude coordinate
- **longitude**: Geographic longitude coordinate
- **section**: Section/category of the place
- **distance**: Distance in meters from reference point
- **arImageUrl**: URL to placeholder image for AR view

## Key Components

### PlaceController (GetX Controller)

Manages the application state:

```dart
// Load places from JSON
loadPlaces()

// Select a place to navigate
selectPlace(Place place)

// Toggle between AR and map view
toggleArMode()

// Get navigation arrow based on direction
getDirectionArrow() -> String ('↑', '→', '↓', '←', etc.)

// Get angle to selected place
getDirectionAngle() -> double
```

### AR View Features

- **Animated Arrows**: Dynamic direction indicators that point to selected destination
- **Navigation Dots**: Visual indicators showing the path
- **Place Info Card**: Top card displaying current target information
- **Distance Display**: Real-time distance to destination

### Map View Features

- **Grid Background**: Visual coordinate system
- **Place Markers**: Orange dots for unselected places, red for selected
- **User Position**: Blue dot showing current position
- **Direction Line**: Path from user to selected place
- **Map Controls**: Zoom in/out buttons

## Usage Instructions

1. **View Places**: All available places are shown in a horizontal list at the bottom
2. **Select Destination**: Tap on any place card to select it as your navigation target
3. **AR Navigation**: Tap the camera icon to switch to AR view
   - Animated arrows show the direction to your destination
   - Distance is displayed at the top
   - Navigation dots guide your path
4. **Map View**: Tap the map icon to see the overall layout
   - See all places and their positions
   - Visual representation of your route
5. **Start Navigation**: Press the "Go" button to begin navigation

## Customization

### Modify Theme Colors

Edit [lib/main.dart](lib/main.dart):
```dart
colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
```

### Change Arrow Animation

Edit [lib/widgets/ar_view.dart](lib/widgets/ar_view.dart) - `_buildArrowNavigation()` method

### Adjust Distance Calculation

Edit [lib/controllers/place_controller.dart](lib/controllers/place_controller.dart) - `getDistanceToPlace()` method

## State Management with GetX

### Why GetX?

- **Reactive Architecture**: Automatic UI updates when data changes
- **Dependency Injection**: Easy controller initialization and access
- **Less Boilerplate**: Simpler than Provider or Bloc
- **Performance**: Optimized state management

### Example Usage in Widgets:

```dart
// Access controller
final controller = Get.find<PlaceController>();

// Reactive building
Obx(() {
  return Text(controller.selectedPlace.value?.name ?? 'No selection');
})

// Initializing controller
GetBuilder<PlaceController>(
  init: PlaceController(),
  builder: (controller) => /* widget */
)
```

## Future Enhancements

- Real AR integration using `arcore_flutter_plugin` or `apple_arkit`
- Google Maps integration for real location data
- GPS tracking for actual user position
- Database integration for dynamic places management
- Voice guidance for navigation
- Multi-language support
- Analytics tracking

## Dependencies

- **get**: ^4.6.6 - State management and dependency injection
- **google_maps_flutter**: ^2.5.0 - Maps integration (for future use)
- **geolocator**: ^11.0.0 - GPS location (for future use)
- **permission_handler**: ^11.4.4 - Permission management (for future use)

## Notes

- This is a single-page application with tab-like navigation between AR and Map views
- The map and AR view are simulated visualizations (not actual camera/maps)
- Feel free to extend with real camera and maps integration
- All place data is loaded from the JSON file for easy management

## License

MIT License - Feel free to use and modify
