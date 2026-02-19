# Component Hierarchy & Architecture

## 🏗️ Application Structure

```
GetMaterialApp (main.dart)
│
├── Theme: AppTheme.darkTheme
├── InitialBinding: InitialBindings
└── Routes: routes[]
    │
    └── /admin/dashboard → MainScreen
        │
        ├── Binding: DashboardBinding
        │   ├── DashboardController (lazy)
        │   └── SubscriptionController (lazy)
        │
        └── MainScreen (GetView<DashboardController>)
            │
            ├── Container (Background Gradient)
            │   │
            │   ├── Row
            │   │   │
            │   │   ├── Sidebar (80px)
            │   │   │   ├── Logo (Shield Icon)
            │   │   │   ├── NavigationRail
            │   │   │   │   ├── Dashboard Icon
            │   │   │   │   ├── Clients Icon
            │   │   │   │   ├── Subscriptions Icon
            │   │   │   │   ├── Devices Icon
            │   │   │   │   └── Settings Icon
            │   │   │   └── Profile Icon
            │   │   │
            │   │   └── Expanded (Main Content)
            │   │       │
            │   │       ├── TopBar (80px height)
            │   │       │   ├── Breadcrumbs
            │   │       │   ├── Spacer
            │   │       │   ├── Search Bar (300px)
            │   │       │   └── Notification Bell
            │   │       │
            │   │       └── Content Area
            │   │           │
            │   │           └── Obx (selectedIndex)
            │   │               │
            │   │               ├── [0] DashboardHomeView
            │   │               ├── [1] Coming Soon
            │   │               ├── [2] SubscriptionListView
            │   │               ├── [3] Coming Soon
            │   │               └── [4] Coming Soon
```

## 📊 Dashboard Home View Hierarchy

```
DashboardHomeView (GetView<DashboardController>)
│
└── Obx (isLoading)
    │
    ├── [Loading] CircularProgressIndicator
    │
    └── [Loaded] RefreshIndicator
        │
        └── SingleChildScrollView
            │
            └── Column
                │
                ├── Welcome Header
                │   ├── "Welcome back, Admin" (32px, Bold)
                │   └── "Here's what's happening..." (16px)
                │
                ├── Stats Cards Row
                │   ├── Total Active Licenses Card
                │   │   ├── Gradient Background
                │   │   ├── Icon (56x56)
                │   │   ├── Title
                │   │   ├── Value (32px)
                │   │   └── Trend Badge (+12.5%)
                │   │
                │   ├── Near Expiry Card
                │   │   └── [Same structure]
                │   │
                │   └── New Activations Card
                │       └── [Same structure]
                │
                ├── Quick Actions
                │   ├── "Generate License Key" Button
                │   ├── "Add New Client" Button
                │   └── "View Reports" Button
                │
                └── Recent Activity
                    └── ListView (5 items)
                        └── Activity Item
                            ├── Icon (40x40)
                            ├── Title
                            └── Timestamp
```

## 📋 Subscription List View Hierarchy

```
SubscriptionListView (GetView<SubscriptionController>)
│
└── Obx (isLoading)
    │
    ├── [Loading] CircularProgressIndicator
    │
    └── [Loaded] Padding
        │
        └── Column
            │
            ├── Header Row
            │   ├── Title + Count
            │   └── "Add Subscription" Button
            │
            ├── Filters Container
            │   ├── Filter Chips
            │   │   ├── All
            │   │   ├── Active
            │   │   ├── Near Expiry
            │   │   └── Expired
            │   │
            │   └── Sort Dropdown
            │       ├── Sort by Date
            │       ├── Sort by Expiry
            │       └── Sort by Name
            │
            ├── Data Table Container
            │   │
            │   ├── Table Header
            │   │   ├── Client
            │   │   ├── License Key
            │   │   ├── Status
            │   │   ├── Expiry Date
            │   │   ├── Devices
            │   │   └── Actions
            │   │
            │   └── Obx (filteredSubscriptions)
            │       │
            │       ├── [Empty] Empty State
            │       │   ├── Inbox Icon
            │       │   └── "No subscriptions found"
            │       │
            │       └── [Data] ListView
            │           └── Table Row (per subscription)
            │               ├── Client Info
            │               │   ├── Name
            │               │   └── Email
            │               │
            │               ├── License Key
            │               │   ├── Key Text
            │               │   └── Copy Button
            │               │
            │               ├── Status Badge
            │               │   ├── Glowing Dot
            │               │   └── Status Text
            │               │
            │               ├── Expiry Info
            │               │   ├── Date
            │               │   └── Days Left
            │               │
            │               ├── Device Count
            │               │
            │               └── Actions
            │                   ├── Generate Key Button
            │                   ├── Edit Button
            │                   └── Delete Button
            │
            └── Pagination
                ├── Previous Button
                ├── Page Numbers (1-5)
                └── Next Button
```

## 🎨 Component Composition

### Reusable Components

```
Stats Card
├── Props:
│   ├── title: String
│   ├── value: String
│   ├── icon: IconData
│   ├── gradient: Gradient
│   ├── trend: String
│   ├── trendUp: bool
│   └── delay: int
│
└── Structure:
    ├── Container (320x160)
    │   ├── Gradient Overlay (animated)
    │   └── Content
    │       ├── Icon Container (56x56)
    │       ├── Spacer
    │       ├── Title Text
    │       └── Row
    │           ├── Value (32px)
    │           └── Trend Badge

Filter Chip
├── Props:
│   ├── label: String
│   ├── isSelected: bool
│   ├── onTap: VoidCallback
│   └── color: Color?
│
└── Structure:
    └── AnimatedContainer
        ├── Border (conditional)
        ├── Background (conditional)
        └── Text (color changes)

Status Badge
├── Props:
│   └── status: String
│
└── Structure:
    └── Container
        ├── Border (color-coded)
        ├── Background (semi-transparent)
        └── Row
            ├── Glowing Dot (8x8)
            └── Status Text

Action Button
├── Props:
│   ├── icon: IconData
│   ├── tooltip: String
│   ├── onTap: VoidCallback
│   └── color: Color?
│
└── Structure:
    └── Tooltip
        └── GestureDetector
            └── Container (32x32)
                └── Icon (16x16)
```

## 🔄 State Flow Diagram

```
User Action
    ↓
┌─────────────────────────┐
│   Controller Method     │
│  (e.g., changePage())   │
└─────────────────────────┘
    ↓
┌─────────────────────────┐
│  Update Reactive State  │
│  (e.g., currentPage.value = 2) │
└─────────────────────────┘
    ↓
┌─────────────────────────┐
│   Obx Widget Detects    │
│      State Change       │
└─────────────────────────┘
    ↓
┌─────────────────────────┐
│   Widget Rebuilds       │
│   (Only affected parts) │
└─────────────────────────┘
    ↓
UI Updated
```

## 🎯 Navigation Flow

```
App Start
    ↓
main.dart
    ↓
GetMaterialApp
    ↓
initialRoute: "/" (or AppRoute.adminDashboard)
    ↓
┌─────────────────────────┐
│   DashboardBinding      │
│   ├── DashboardController │
│   └── SubscriptionController │
└─────────────────────────┘
    ↓
MainScreen
    ↓
selectedIndex = 0 (default)
    ↓
DashboardHomeView
    ↓
User clicks "Subscriptions" icon
    ↓
controller.changeNavigation(2)
    ↓
selectedIndex.value = 2
    ↓
Obx rebuilds content area
    ↓
SubscriptionListView displayed
```

## 📦 Data Flow (Subscriptions)

```
SubscriptionController.onInit()
    ↓
loadSubscriptions()
    ↓
┌─────────────────────────┐
│  Generate Mock Data     │
│  (25 subscriptions)     │
└─────────────────────────┘
    ↓
subscriptions.value = [...]
    ↓
applyFilters()
    ↓
┌─────────────────────────┐
│  Filter by Status       │
│  (if filterStatus != 'All') │
└─────────────────────────┘
    ↓
┌─────────────────────────┐
│  Sort by Selected       │
│  (date/expiry/name)     │
└─────────────────────────┘
    ↓
filteredSubscriptions.value = [...]
    ↓
┌─────────────────────────┐
│  Calculate Total Pages  │
│  (length / itemsPerPage) │
└─────────────────────────┘
    ↓
totalPages.value = X
    ↓
UI displays paginated data
    ↓
User changes filter/sort/page
    ↓
[Repeat from applyFilters()]
```

## 🎨 Animation Timeline

### Page Load Animations

```
Time    Component               Animation
0ms     Background              Fade in
0ms     Sidebar Logo            Fade in + Scale
100ms   Nav Item 1              Fade in
200ms   Nav Item 2              Fade in
300ms   Nav Item 3              Fade in
400ms   Nav Item 4              Fade in
400ms   Profile Icon            Fade in
200ms   Search Bar              Fade in
300ms   Notification            Fade in
0ms     Welcome Header          Fade in + Slide X
200ms   Subtitle                Fade in + Slide X
0ms     Stats Card 1            Fade in + Slide Y
100ms   Stats Card 2            Fade in + Slide Y
200ms   Stats Card 3            Fade in + Slide Y
400ms   Quick Actions           Fade in
500ms   Recent Activity         Fade in
```

### Interaction Animations

```
Hover on Nav Item
    ↓
Scale: 1.0 → 1.05 (200ms)

Click Filter Chip
    ↓
Border Color Change (300ms)
Background Color Change (300ms)

Hover on Action Button
    ↓
Background Opacity Change (200ms)

Page Change
    ↓
Table Rows Fade in (staggered 50ms)
```

## 🔧 Dependency Injection

```
GetMaterialApp
    ↓
initialBinding: InitialBindings()
    ↓
Global Services Initialized
    ↓
Route: /admin/dashboard
    ↓
binding: DashboardBinding()
    ↓
Get.lazyPut<DashboardController>()
Get.lazyPut<SubscriptionController>()
    ↓
Controllers created when first accessed
    ↓
GetView<Controller> accesses via 'controller' getter
    ↓
Type-safe controller access
```

---

**This architecture ensures**:
- ✅ Clean separation of concerns
- ✅ Efficient state management
- ✅ Reusable components
- ✅ Smooth animations
- ✅ Scalable structure
