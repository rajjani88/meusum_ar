# Quick Reference Guide - Museum AR Navigator

## JSON File Format

Edit `assets/data/places.json` to modify places or add new ones.

### Complete Example

```json
{
  "places": [
    {
      "id": 1,
      "name": "Pizza",
      "icon": "🍕",
      "description": "Fresh pizza ready to serve",
      "latitude": 40.7128,
      "longitude": -74.0060,
      "section": "Food Court",
      "distance": 45.5,
      "arImageUrl": "https://via.placeholder.com/300?text=Pizza"
    },
    {
      "id": 2,
      "name": "Coffee Shop",
      "icon": "☕",
      "description": "Premium coffee and tea",
      "latitude": 40.7130,
      "longitude": -74.0055,
      "section": "Cafeteria",
      "distance": 62.3,
      "arImageUrl": "https://via.placeholder.com/300?text=Coffee"
    }
  ]
}
```

## Field Reference

| Field | Type | Description | Example |
|-------|------|-------------|---------|
| id | Integer | Unique identifier (must be unique) | 1 |
| name | String | Display name of the location | "Pizza" |
| icon | String | Emoji representing the location (1 character) | "🍕" |
| description | String | Short description shown in bottom card | "Fresh pizza ready to serve" |
| latitude | Number | Geographic latitude coordinate | 40.7128 |
| longitude | Number | Geographic longitude coordinate | -74.0060 |
| section | String | Category/section name | "Food Court" |
| distance | Number | Distance in meters from reference point | 45.5 |
| arImageUrl | String | URL to AR view image (currently unused) | "https://..." |

## Adding a New Place

1. **Open** `assets/data/places.json`
2. **Copy** an existing place object
3. **Modify** the fields:
   ```json
   {
     "id": 6,
     "name": "New Place",
     "icon": "🎯",
     "description": "Your description here",
     "latitude": 40.7140,
     "longitude": -74.0040,
     "section": "Category",
     "distance": 100.0,
     "arImageUrl": "https://via.placeholder.com/300?text=NewPlace"
   }
   ```
4. **Save** the file
5. **Hot reload** the app (Ctrl+S or Cmd+S in VS Code)

## Common Emoji Icons

```
🍕 Pizza           🥤 Beverages        🧀 Cheese          
🥐 Bakery          🥬 Vegetables       📱 Electronics     
🎬 Cinema          🏥 Hospital         📚 Library          
🛍️ Shopping        🏪 Store           🍔 Burger           
🍜 Noodles         🍱 Sushi            🥘 Cooking          
🎨 Art             🎵 Music            🏋️ Fitness          
🧘 Yoga            💆 Spa              ⚽ Sports           
🎮 Gaming          🎯 Target           📍 Location         
```

## Coordinate System Notes

- **Latitude**: Increases North, decreases South
- **Longitude**: Increases East, decreases West
- The app uses these coordinates for:
  - Arrow direction calculation
  - Distance calculation
  - Map visualization positioning

### Example Coordinates (New York City)
```
Manhattan Center: 40.7580°N, 73.9855°W
Empire State Building: 40.7484°N, 73.9857°W
Central Park: 40.7829°N, 73.9654°W
```

## Distance Calculation

The distance shown in the app is the `distance` field value from the JSON file. It doesn't automatically calculate from coordinates. Update this manually or use a distance calculator:

```
Distance = sqrt((lat2-lat1)² + (lng2-lng1)²) × 111000 meters approximately
```

## Testing Your Changes

### After adding/modifying JSON:
1. **Save** the `places.json` file
2. **Hot reload** (Cmd+S or Ctrl+S)
3. **Verify** the place appears in the list
4. **Tap** the place card to navigate to it
5. **Check** the AR and map views

### Debugging:
- If place doesn't appear: Check JSON syntax (use jsonlint.com)
- If wrong distance shown: Verify the `distance` field value
- If wrong direction: Check `latitude` and `longitude` values

## Advanced Customization

### Change Default User Location
In `lib/controllers/place_controller.dart`:
```dart
final userLat = 40.7128.obs;  // Change this
final userLng = -74.0060.obs; // Change this
```

### Add More Navigation Routes
Modify `getDirectionArrow()` in place_controller.dart to add custom arrow logic.

### Customize UI Colors
In `lib/main.dart`, change the theme:
```dart
colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
```

Replace `Colors.blue` with any color: `Colors.green`, `Colors.red`, `Colors.purple`, etc.

## Performance Tips

- Keep the number of places under 100 for best performance
- Use shorter descriptions (under 60 characters)
- Emoji work best for icons (1-2 characters max)
- Test on actual device for accurate performance

## Troubleshooting

### App crashes on startup
- Verify JSON file syntax
- Check all required fields are present
- Ensure all field types match (string/number)

### Navigation arrows point wrong direction
- Verify latitude/longitude coordinates
- Check if user location is set correctly
- Test with different place coordinates

### Places don't show
- Hot reload might not be enough, try hot restart
- Check `places.json` is in correct path: `assets/data/places.json`
- Verify `pubspec.yaml` has the asset listed

## File Locations Reference

```
meusum_ar/
├── assets/data/places.json           (Edit this to add places)
├── lib/main.dart                     (App theme/setup)
├── lib/controllers/place_controller.dart  (Navigation logic)
├── lib/screens/home_screen.dart      (Main UI layout)
└── lib/widgets/                      (AR view, map, cards)
```
