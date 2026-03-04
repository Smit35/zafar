# Zafar Food Delivery

A Flutter mobile application for food delivery with two user types: Outlets (Restaurants) and Drivers (Riders).

## Features

### Authentication
- Login screen with tabs for Outlet and Driver
- Mock authentication (accepts any email/password for demo purposes)
- Persistent login state

### Outlet Flow
- **Menu Screen**: Browse restaurant menu with search functionality
- **Cart Management**: Add/remove items with quantity controls
- **Cart Screen**: Review selected items and quantities
- **Place Order Screen**: Enter delivery details and customer information
- **Order Confirmation**: Success screen with order details

### Driver Flow
- **Driver Dashboard**: View active and completed orders in separate tabs
- **Order Details**: Detailed view of each order with customer info
- **Order Management**: Mark orders as completed
- **Navigation**: Call customer and get directions (UI buttons)

## Project Structure

```
lib/
├── models/           # Data models (User, MenuItem, CartItem, Order)
├── providers/        # State management with Provider pattern
├── screens/          # UI screens organized by user type
│   ├── auth/        # Authentication screens
│   ├── outlet/      # Restaurant/outlet screens
│   └── driver/      # Driver screens
├── services/        # API services and business logic
├── utils/           # Utility functions
└── widgets/         # Reusable UI components
```

## Getting Started

### Prerequisites
- Flutter SDK (3.9.0 or higher)
- Android Studio / VS Code with Flutter extensions
- Android device or emulator for testing

### Installation

1. Clone the repository
2. Navigate to the project directory:
   ```bash
   cd zafar_food_delivery
   ```

3. Install dependencies:
   ```bash
   flutter pub get
   ```

4. Run the app:
   ```bash
   flutter run
   ```

## Usage

### For Testing Outlets:
1. Select the "Outlet" tab on login screen
2. Enter any email and password
3. Browse menu items and add to cart
4. Go to cart and proceed to place order
5. Fill in delivery details and confirm order

### For Testing Drivers:
1. Select the "Driver" tab on login screen
2. Enter any email and password
3. View active orders in dashboard
4. Tap on any order to see details
5. Mark orders as completed

## Dependencies

- `flutter`: UI framework
- `provider`: State management
- `http`: HTTP requests
- `shared_preferences`: Local storage

## Technical Notes

- Uses Provider pattern for state management
- Mock data for demonstration purposes
- Responsive design for mobile screens
- Material Design 3 with custom orange theme
- Persistent authentication state

## Mock Data

The app includes sample menu items and mock orders for demonstration:
- 6 sample menu items across different categories
- Mock active orders for driver testing
- Mock completed orders for history

## Future Enhancements

- Real API integration
- Push notifications for order updates
- GPS integration for delivery tracking
- Payment gateway integration
- Order history and analytics
- Multi-language support
