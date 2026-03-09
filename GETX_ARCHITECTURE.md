# GetX State Management Architecture

This document explains how the Museum AR Navigator uses GetX for state management and dependency injection.

## Overview

GetX provides:
- **Reactive Variables**: Automatically update UI when data changes
- **Dependency Injection**: Easy service and controller registration
- **Route Management**: Simple navigation
- **Less Boilerplate**: Compared to Provider or Bloc pattern

## Project Architecture

```
GetX Architecture in Museum AR Navigator
│
├── Service Layer (Controllers)
│   └── PlaceController (GetxController)
│       ├── Reactive State
│       │   ├── places (RxList<Place>)
│       │   ├── selectedPlace (Rx<Place?>)
│       │   ├── isArMode (RxBool)
│       │   ├── userLat (RxDouble)
│       │   └── userLng (RxDouble)
│       └── Methods
│           ├── loadPlaces()
│           ├── selectPlace()
│           ├── toggleArMode()
│           └── Navigation helpers
│
├── UI Layer (Screens & Widgets)
│   └── HomeScreen
│       ├── ARViewWidget
│       ├── MapViewWidget
│       ├── PlaceCard
│       └── Place Info Card
│
└── Data Layer
    ├── Models
    │   └── Place (Data class)
    └── Assets
        └── places.json
```

## Key Components

### 1. PlaceController (lib/controllers/place_controller.dart)

The main GetX controller managing all application state.

#### Reactive State Variables

```dart
final places = <Place>[].obs;              // Observable list
final selectedPlace = Rx<Place?>(null);    // Observable nullable
final isArMode = false.obs;                // Observable boolean
final userLat = 40.7128.obs;               // Observable double
final userLng = -74.0060.obs;              // Observable double
```

**Usage:**
- `.obs` makes the variable reactive
- Changes trigger automatic UI updates
- No need for `setState()` or manual rebuilds

#### Business Logic Methods

```dart
void loadPlaces()                    // Load places from JSON
void selectPlace(Place place)        // Set selected destination
void toggleArMode()                  // Switch AR/Map view
double getDistanceToPlace()          // Get distance to target
String getDirectionArrow()           // Get arrow emoji direction
double getDirectionAngle()           // Get angle in degrees
```

### 2. Data Flow

```
JSON File (places.json)
    ↓
PlaceController.loadPlaces()
    ↓
places (RxList) <- UI observes this
    ↓
HomeScreen receives updates
    ↓
PlaceCard & Info Card display updated data
```

### 3. Dependency Injection Setup

**In main.dart:**

```dart
GetMaterialApp(
  home: const HomeScreen(),
  initialBinding: BindingsBuilder(() {
    Get.put(PlaceController());  // Register controller
  }),
)
```

**Usage in Widgets:**

```dart
// Access controller
final controller = Get.find<PlaceController>();

// Or in GetBuilder (rebuilds on state change)
GetBuilder<PlaceController>(
  init: PlaceController(),
  builder: (controller) => /* widget */
)
```

## Reactive Programming Patterns

### Pattern 1: Obx() - Simple Reactive Widget

```dart
Obx(() {
  return Text(controller.selectedPlace.value?.name ?? 'None');
})
```
- Rebuilds whenever `selectedPlace` changes
- Most common pattern for simple widgets

### Pattern 2: GetBuilder() - Full Rebuild

```dart
GetBuilder<PlaceController>(
  init: PlaceController(),
  builder: (controller) {
    return ListView.builder(
      itemCount: controller.places.length,
      itemBuilder: (context, index) => PlaceCard(
        place: controller.places[index],
      ),
    );
  },
)
```
- Better for list rebuilds
- Used in home_screen.dart for main layout

### Pattern 3: Rx Variables with .value

```dart
// Reading
print(controller.selectedPlace.value?.name);

// Updating
controller.selectedPlace.value = newPlace;

// Toggling boolean
controller.isArMode.toggle();
```

## State Management Flow

### When User Taps a Place Card

```
User Taps Card
    ↓
PlaceCard.onTap() triggered
    ↓
controller.selectPlace(place)
    ↓
selectedPlace.value = place
    ↓
Obx() widgets observe change
    ↓
UI automatically updates:
    - AR View shows new target
    - Info card displays details
    - Map recalculates path
```

### When AR Mode is Toggled

```
User Taps AR/Map Icon
    ↓
controller.toggleArMode()
    ↓
isArMode.toggle()
    ↓
Obx(() { isArMode.value ? ARView : MapView })
    ↓
UI switches between views (no rebuild needed)
```

## Best Practices Used

### 1. Single Controller Pattern
- One `PlaceController` manages all state
- Easy to test and debug
- Clear responsibility

### 2. Reactive Variables
- Uses `.obs` for reactive state
- Automatic UI updates
- No manual state management

### 3. Initialization
- `onInit()` loads data when controller is created
- Uses GetX lifecycle automatically

```dart
@override
void onInit() {
  super.onInit();
  loadPlaces();  // Load data when ready
}
```

### 4. Clean Separation
- **Models**: Pure data classes
- **Controllers**: Business logic
- **Widgets**: UI only
- **Screens**: Layout composition

## Adding New Features

### Add a New Reactive Variable

```dart
// In PlaceController
final newFeature = ''.obs;

// In UI
Obx(() => Text(controller.newFeature.value))

// Update it
controller.newFeature.value = 'new value';
```

### Add a New Method

```dart
// In PlaceController
void newMethod() {
  // Business logic here
  selectedPlace.value = places.first;
}

// In UI
ElevatedButton(
  onPressed: controller.newMethod,
  child: Text('Action'),
)
```

### Add a Computed Value (Getter)

```dart
// In PlaceController
String get selectedPlaceName => selectedPlace.value?.name ?? 'None';

// In UI
Obx(() => Text(controller.selectedPlaceName))
```

## Performance Optimization

### 1. Selective Updates with Obx()
- Only widgets wrapped in `Obx()` rebuild on changes
- Other widgets remain unchanged

### 2. List Updates Efficiency
```dart
// Add to list reactively
places.add(newPlace);

// Update list reactively
places.assignAll(newPlacesList);

// Refresh specific item
places.refresh();
```

### 3. Avoid Unnecessary Rebuilds
✅ **Good**: Use specific `Obx()` widgets
❌ **Bad**: Rebuild entire screen on small changes

## Testing GetX Controllers

### Unit Test Example
```dart
test('selectPlace updates selectedPlace', () {
  final controller = PlaceController();
  final testPlace = places.first;
  
  controller.selectPlace(testPlace);
  
  expect(controller.selectedPlace.value, testPlace);
});
```

### Widget Test Example
```dart
testWidgets('Obx updates on state change', (WidgetTester tester) async {
  final controller = PlaceController();
  
  await tester.pumpWidget(
    GetMaterialApp(
      home: Scaffold(
        body: Obx(() => Text(controller.selectedPlace.value?.name ?? 'None')),
      ),
    ),
  );
  
  controller.selectPlace(newPlace);
  await tester.pumpAndSettle();
  
  expect(find.text(newPlace.name), findsOneWidget);
});
```

## Comparison with Other Patterns

| Feature | GetX | Provider | Bloc | Riverpod |
|---------|------|----------|------|----------|
| **Boilerplate** | Low | Medium | High | Low |
| **Learning Curve** | Shallow | Medium | Steep | Medium |
| **Performance** | Excellent | Good | Good | Excellent |
| **DI Support** | Built-in | Weak | No | Built-in |
| **Route Management** | Built-in | No | No | No |
| **Community** | Large | Huge | Large | Growing |

## Common Issues & Solutions

### Issue: Obx() not updating
**Solution**: Ensure you're using `.value` for primitives
```dart
// Wrong: observer won't trigger
counter.value = 5;
if (counter == 5) { }  // ❌ Direct comparison

// Right: Use .value
if (counter.value == 5) { }  // ✅
```

### Issue: Controller not found with Get.find()
**Solution**: Ensure controller is registered in initialBinding
```dart
GetMaterialApp(
  initialBinding: BindingsBuilder(() {
    Get.put(PlaceController());  // Must be called
  }),
)
```

### Issue: Multiple controller instances
**Solution**: Use `Get.find()` instead of `Get.put()` everywhere
```dart
// ✅ Register once in main
Get.put(PlaceController());

// ✅ Access everywhere
final controller = Get.find<PlaceController>();
```

## Further Resources

- [GetX Documentation](https://github.com/jonataslaw/getx)
- [GetX Examples](https://github.com/jonataslaw/getx/tree/master/example)
- [State Management Comparison](https://pub.dev/packages/get#comparison)

## Summary

GetX provides:
- ✅ Simple reactive state management
- ✅ Built-in dependency injection
- ✅ Efficient UI updates with Obx()
- ✅ Less boilerplate code
- ✅ Built-in route management
- ✅ Perfect for museums/location apps

This architecture makes it easy to:
- Add new places and features
- Update UI reactively
- Test business logic
- Scale the application
