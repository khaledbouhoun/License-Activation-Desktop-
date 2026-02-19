# Softel Control - Modern Admin Dashboard

A modern, beautiful admin dashboard UI for the Softel Control Flutter Windows application, built with GetX state management and clean architecture principles.

## 🎨 Design Features

### Theme & Aesthetics
- **Dark Mode**: Deep slate/charcoal background with vibrant accents
- **Glassmorphism Effects**: Translucent backgrounds with acrylic blur effects
- **Color Palette**:
  - Primary: Electric Blue (#00D9FF)
  - Accent: Emerald Green (#00FF88)
  - Background: Deep Slate (#0F1419)
  - Surface: Charcoal (#1A1F26)

### UI Components

#### 1. Sidebar Navigation (NavigationRail)
- Vertical, slim design (80px width)
- Animated icons with hover effects
- Navigation items:
  - Dashboard
  - Clients
  - Subscriptions
  - Devices
  - Settings
- Glassmorphic background with border glow

#### 2. Top Bar
- Dynamic breadcrumbs showing current location
- Search bar with modern styling
- Notification bell with badge indicator
- Admin profile icon

#### 3. Stats Cards
- Animated cards with gradient backgrounds
- Real-time statistics:
  - Total Active Licenses
  - Near Expiry Licenses
  - New Activations
- Trend indicators with percentage changes
- Glowing effects for visual appeal

#### 4. Data Grid (Subscriptions)
- Custom-built responsive table
- Features:
  - Pagination (10 items per page)
  - Filtering by status (All, Active, Near Expiry, Expired)
  - Sorting (by date, expiry, name)
  - Status badges with glowing indicators
  - Action buttons (Generate Key, Edit, Delete)
- Smooth animations on row appearance

#### 5. Forms & Inputs
- Modern input fields with subtle borders
- Clear validation error styles
- Glassmorphic backgrounds
- Focus states with blue glow

#### 6. Action Buttons
- Hover effects with scale transformation
- Glow effects on primary actions
- Shimmer animations for emphasis
- Gradient backgrounds

## 📁 Project Structure

```
lib/
├── controller/
│   ├── dashboard_controller.dart      # Main dashboard state management
│   └── subscription_controller.dart   # Subscription data & operations
├── core/
│   ├── constant/
│   │   ├── app_theme.dart            # Theme configuration & design tokens
│   │   └── routesstr.dart            # Route constants
│   └── shared/
│       └── dashboard_binding.dart    # GetX bindings for controllers
├── data/
│   └── model/
│       └── subscription_model.dart   # Subscription data model
└── view/
    ├── dashboard/
    │   ├── main_screen.dart          # Main dashboard with sidebar
    │   └── dashboard_home_view.dart  # Dashboard home with stats
    └── subscription/
        └── subscription_list_view.dart # Subscription management view
```

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (3.12.0 or higher)
- Windows development environment
- Dart SDK

### Installation

1. **Install Dependencies**
```bash
flutter pub get
```

2. **Run the Application**
```bash
flutter run -d windows
```

### Navigate to Dashboard
The admin dashboard is accessible at the route:
```dart
Get.toNamed(AppRoute.adminDashboard);
```

## 🎯 Key Features

### Responsive Design
- Adapts to different monitor sizes
- Flexible layouts with proper constraints
- Maintains visual hierarchy across screen sizes

### State Management (GetX)
- **Reactive State**: All UI updates automatically with Obx widgets
- **Dependency Injection**: Controllers lazy-loaded via bindings
- **Clean Separation**: Views use GetView<Controller> pattern

### Animations
- **Entry Animations**: Fade in and slide effects on page load
- **Hover Effects**: Scale and glow on interactive elements
- **Shimmer Effects**: Attention-grabbing animations on CTAs
- **Smooth Transitions**: 300ms duration with easeInOut curves

### Typography
- **Google Fonts**: Inter font family for professional look
- **Font Weights**: 
  - Bold (700) for headings
  - Semi-bold (600) for titles
  - Medium (500) for labels
  - Regular (400) for body text

## 🛠️ Customization

### Changing Colors
Edit `lib/core/constant/app_theme.dart`:
```dart
static const Color primaryBlue = Color(0xFF00D9FF);
static const Color accentGreen = Color(0xFF00FF88);
```

### Modifying Border Radius
```dart
static const double radiusMedium = 12.0;
static const double radiusLarge = 16.0;
```

### Adjusting Spacing
```dart
static const double spacingM = 16.0;
static const double spacingL = 24.0;
```

## 📊 Data Integration

### Connecting to Backend API

1. **Update Subscription Controller**
Edit `lib/controller/subscription_controller.dart`:
```dart
Future<void> loadSubscriptions() async {
  try {
    isLoading.value = true;
    
    // Replace with your API call
    final response = await http.get(
      Uri.parse('YOUR_API_URL/subscriptions'),
    );
    
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      subscriptions.value = data
          .map((json) => SubscriptionModel.fromJson(json))
          .toList();
    }
    
    applyFilters();
  } catch (e) {
    Get.snackbar('Error', 'Failed to load subscriptions: $e');
  } finally {
    isLoading.value = false;
  }
}
```

2. **Update Dashboard Statistics**
Edit `lib/controller/dashboard_controller.dart`:
```dart
Future<void> loadDashboardData() async {
  try {
    isLoading.value = true;
    
    // Replace with your API call
    final response = await http.get(
      Uri.parse('YOUR_API_URL/dashboard/stats'),
    );
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      totalActiveLicenses.value = data['total_active'];
      nearExpiryLicenses.value = data['near_expiry'];
      newActivations.value = data['new_activations'];
    }
  } catch (e) {
    Get.snackbar('Error', 'Failed to load dashboard data: $e');
  } finally {
    isLoading.value = false;
  }
}
```

## 🎨 Design Tokens

### Colors
| Token | Hex | Usage |
|-------|-----|-------|
| Primary Blue | #00D9FF | Primary actions, links |
| Accent Green | #00FF88 | Success states, active status |
| Warning Orange | #FFB800 | Near expiry warnings |
| Error Red | #FF4757 | Errors, expired status |
| Background Dark | #0F1419 | Main background |
| Surface Dark | #1A1F26 | Card backgrounds |

### Shadows
- **Card Shadow**: 20px blur, 4px offset, 20% opacity
- **Glow Shadow**: 20px blur, 2px spread, 30% opacity
- **Green Glow**: 15px blur, 1px spread, 30% opacity

## 📱 Components Usage

### Stats Card
```dart
_buildStatCard(
  title: 'Total Active Licenses',
  value: '1247',
  icon: Icons.verified_outlined,
  gradient: AppTheme.primaryGradient,
  trend: '+12.5%',
  trendUp: true,
  delay: 0,
)
```

### Status Badge
```dart
_buildStatusBadge('Active')  // Green with glow
_buildStatusBadge('Near Expiry')  // Orange
_buildStatusBadge('Expired')  // Red
```

### Action Button
```dart
_buildActionButton(
  icon: Icons.key_outlined,
  tooltip: 'Generate Key',
  onTap: () => controller.generateLicenseKey(id),
)
```

## 🔧 Technical Requirements

### Dependencies
```yaml
dependencies:
  get: ^4.7.3                          # State management & routing
  google_fonts: ^6.2.1                 # Typography
  flutter_animate: ^4.5.0              # Animations
  syncfusion_flutter_datagrid: ^27.1.58 # Data grid (optional)
  glassmorphism_ui: ^0.3.0             # Glassmorphism effects
  intl: ^0.19.0                        # Date formatting
```

## 🎯 Best Practices

1. **Use GetView Pattern**: All views extend `GetView<Controller>`
2. **Reactive Updates**: Wrap dynamic content with `Obx(() => ...)`
3. **Lazy Loading**: Controllers loaded via bindings, not directly
4. **Const Constructors**: Use `const` for static widgets
5. **Responsive Design**: Use `LayoutBuilder` and `MediaQuery`

## 🚀 Performance Tips

1. **Pagination**: Load data in chunks (10 items per page)
2. **Lazy Loading**: Use `Get.lazyPut` for controllers
3. **Const Widgets**: Maximize use of const constructors
4. **Debouncing**: Implement search debouncing for better UX
5. **Image Caching**: Cache network images when implemented

## 📝 TODO / Future Enhancements

- [ ] Add form for creating new subscriptions
- [ ] Implement license key generation dialog
- [ ] Add export functionality (CSV, PDF)
- [ ] Implement real-time notifications
- [ ] Add dark/light theme toggle
- [ ] Create settings page
- [ ] Add user management
- [ ] Implement advanced filtering
- [ ] Add charts and analytics
- [ ] Create mobile responsive version

## 🤝 Contributing

When adding new features:
1. Follow the existing clean architecture pattern
2. Use GetX for state management
3. Maintain consistent design tokens from `app_theme.dart`
4. Add animations for better UX
5. Document your code

## 📄 License

This project is part of the Softel Control application.

---

**Built with ❤️ using Flutter & GetX**
