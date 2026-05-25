import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'ui/theme.dart';
import 'logic/shop_provider.dart';
import 'ui/screens/login_screen.dart';
import 'ui/screens/home_screen.dart';
import 'ui/screens/product_detail_screen.dart';
import 'ui/screens/cart_screen.dart';
import 'ui/screens/chat_screen.dart';
import 'ui/screens/map_screen.dart';
import 'ui/screens/notifications_screen.dart';

void main() {
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AeroSport Shop',
      theme: aeroTheme,
      debugShowCheckedModeBanner: false,
      home: const MainWrapper(),
    );
  }
}

class MainWrapper extends ConsumerWidget {
  const MainWrapper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(shopProvider);
    final unreadAlertsAsync = ref.watch(unreadNotificationsCountProvider);
    final unreadAlerts = unreadAlertsAsync.value ?? 0;

    if (!state.isLoggedIn) {
      return const LoginScreen();
    }

    // Determine screen content
    Widget body;
    switch (state.currentScreen) {
      case ActiveScreen.login:
        body = const LoginScreen();
        break;
      case ActiveScreen.home:
        body = const HomeScreen();
        break;
      case ActiveScreen.productDetail:
        body = ProductDetailScreen(productId: state.selectedProductId ?? 1);
        break;
      case ActiveScreen.cart:
        body = const CartScreen();
        break;
      case ActiveScreen.chat:
        body = const ChatScreen();
        break;
      case ActiveScreen.map:
        body = const MapScreen();
        break;
      case ActiveScreen.notifications:
        body = const NotificationsScreen();
        break;
    }

    return Scaffold(
      body: SafeArea(
        child: body,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: AeroColors.aeroM3Outline.withOpacity(0.2),
              width: 1,
            ),
          ),
        ),
        child: NavigationBar(
          backgroundColor: AeroColors.bottomBarBg,
          selectedIndex: _getSelectedIndex(state.currentScreen),
          onDestinationSelected: (index) {
            final notifier = ref.read(shopProvider.notifier);
            switch (index) {
              case 0:
                notifier.navigateTo(ActiveScreen.home);
                break;
              case 1:
                notifier.navigateTo(ActiveScreen.cart);
                break;
              case 2:
                notifier.navigateTo(ActiveScreen.chat);
                break;
              case 3:
                notifier.navigateTo(ActiveScreen.map);
                break;
              case 4:
                notifier.navigateTo(ActiveScreen.notifications);
                break;
            }
          },
          destinations: [
            const NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home),
              label: 'Cửa hàng',
            ),
            const NavigationDestination(
              icon: Icon(Icons.shopping_cart_outlined),
              selectedIcon: Icon(Icons.shopping_cart),
              label: 'Giỏ hàng',
            ),
            const NavigationDestination(
              icon: Icon(Icons.chat_outlined),
              selectedIcon: Icon(Icons.chat),
              label: 'Trợ lý AI',
            ),
            const NavigationDestination(
              icon: Icon(Icons.location_on_outlined),
              selectedIcon: Icon(Icons.location_on),
              label: 'Cửa hàng',
            ),
            NavigationDestination(
              icon: Badge(
                label: unreadAlerts > 0 ? Text('$unreadAlerts') : null,
                isLabelVisible: unreadAlerts > 0,
                child: const Icon(Icons.notifications_outlined),
              ),
              selectedIcon: Badge(
                label: unreadAlerts > 0 ? Text('$unreadAlerts') : null,
                isLabelVisible: unreadAlerts > 0,
                child: const Icon(Icons.notifications),
              ),
              label: 'Thông báo',
            ),
          ],
        ),
      ),
    );
  }

  int _getSelectedIndex(ActiveScreen screen) {
    switch (screen) {
      case ActiveScreen.home:
      case ActiveScreen.productDetail:
        return 0;
      case ActiveScreen.cart:
        return 1;
      case ActiveScreen.chat:
        return 2;
      case ActiveScreen.map:
        return 3;
      case ActiveScreen.notifications:
        return 4;
      default:
        return 0;
    }
  }
}
