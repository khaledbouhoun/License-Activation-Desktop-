# Quick Start Guide - Admin Dashboard

## 🚀 Running the Dashboard

### Option 1: Direct Route Navigation

Add this to your `main.dart` to start directly on the dashboard:

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initialServices();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      initialBinding: InitialBindings(),
      getPages: routes,
      // Change this to start on the admin dashboard
      initialRoute: AppRoute.adminDashboard,  // <-- Add this line
      theme: AppTheme.darkTheme,  // <-- Add this line for dark theme
    );
  }
}
```

### Option 2: Navigate from Existing Screen

Add a button to any existing screen:

```dart
import 'package:softel_control/core/constant/routesstr.dart';
import 'package:get/get.dart';

// In your widget's build method:
ElevatedButton(
  onPressed: () => Get.toNamed(AppRoute.adminDashboard),
  child: Text('Open Admin Dashboard'),
)
```

### Option 3: Use the Navigation Helper

```dart
import 'package:softel_control/widget/dashboard_navigation_example.dart';

// In your widget tree:
DashboardNavigationExample()

// Or call the function directly:
navigateToAdminDashboard();
```

## 📋 Testing the Dashboard

### 1. View Dashboard Home
- Navigate to the dashboard
- You should see:
  - Animated sidebar on the left
  - Top bar with search and breadcrumbs
  - Three stats cards with animations
  - Quick action buttons
  - Recent activity list

### 2. Test Subscriptions View
- Click on the "Subscriptions" icon in the sidebar (3rd icon)
- You should see:
  - Filter chips (All, Active, Near Expiry, Expired)
  - Sort dropdown
  - Paginated table with 25 mock subscriptions
  - Status badges with glowing effects
  - Action buttons (Generate Key, Edit, Delete)

### 3. Test Interactions

**Filtering:**
```dart
// Click on different filter chips
- "All" - Shows all subscriptions
- "Active" - Shows only active subscriptions
- "Near Expiry" - Shows subscriptions expiring soon
- "Expired" - Shows expired subscriptions
```

**Sorting:**
```dart
// Use the dropdown to sort by:
- Date (newest first)
- Expiry (soonest first)
- Name (alphabetical)
```

**Pagination:**
```dart
// Navigate through pages
- Click page numbers
- Use previous/next arrows
- 10 items per page
```

**Actions:**
```dart
// Test action buttons
- Generate Key - Shows success snackbar
- Delete - Removes subscription and shows confirmation
```

## 🎨 Customizing Mock Data

Edit `lib/controller/subscription_controller.dart`:

```dart
Future<void> loadSubscriptions() async {
  // Change the number of mock subscriptions
  subscriptions.value = List.generate(
    50,  // <-- Change this number
    (index) => SubscriptionModel(
      // Customize the data here
      clientName: 'Your Client ${index + 1}',
      email: 'client${index + 1}@yourcompany.com',
      // ... other fields
    ),
  );
}
```

## 🔧 Connecting to Your Backend

### Step 1: Update API Endpoints

Create a constants file for your API:

```dart
// lib/core/constant/api_constants.dart
class ApiConstants {
  static const String baseUrl = 'https://your-api.com/api';
  static const String subscriptions = '$baseUrl/subscriptions';
  static const String dashboardStats = '$baseUrl/dashboard/stats';
  static const String generateLicense = '$baseUrl/licenses/generate';
}
```

### Step 2: Update Controllers

Replace mock data with real API calls:

```dart
// In subscription_controller.dart
import 'package:http/http.dart' as http;
import 'dart:convert';

Future<void> loadSubscriptions() async {
  try {
    isLoading.value = true;
    
    final response = await http.get(
      Uri.parse(ApiConstants.subscriptions),
      headers: {
        'Authorization': 'Bearer YOUR_TOKEN',
        'Content-Type': 'application/json',
      },
    );
    
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      subscriptions.value = data
          .map((json) => SubscriptionModel.fromJson(json))
          .toList();
      applyFilters();
    }
  } catch (e) {
    Get.snackbar('Error', 'Failed to load: $e');
  } finally {
    isLoading.value = false;
  }
}
```

## 🎯 Next Steps

1. **Test the UI**: Run the app and navigate through all screens
2. **Customize Colors**: Edit `app_theme.dart` to match your brand
3. **Add Real Data**: Connect to your backend API
4. **Implement Forms**: Create dialogs for adding/editing subscriptions
5. **Add Authentication**: Protect routes with auth middleware

## 🐛 Troubleshooting

### Dashboard doesn't appear
- Check that you've run `flutter pub get`
- Verify the route is registered in `routes.dart`
- Ensure `DashboardBinding` is imported

### Animations not working
- Verify `flutter_animate` package is installed
- Check Flutter version (3.12.0+)
- Try hot restart instead of hot reload

### Styling looks different
- Make sure `google_fonts` package is installed
- Verify theme is applied in `GetMaterialApp`
- Check for conflicting theme settings

### Data not loading
- Check console for error messages
- Verify mock data generation in controllers
- Ensure controllers are properly bound

## 💡 Tips

1. **Hot Reload**: Use `r` in terminal for quick UI updates
2. **Hot Restart**: Use `R` when changing routes or bindings
3. **DevTools**: Use Flutter DevTools for debugging
4. **Performance**: Enable performance overlay with `P` key

## 📱 Keyboard Shortcuts (Windows)

- `Ctrl + F5` - Run without debugging
- `F5` - Run with debugging
- `Shift + F5` - Stop debugging
- `Ctrl + Shift + P` - Command palette

---

**Need Help?** Check the main `DASHBOARD_README.md` for detailed documentation.
