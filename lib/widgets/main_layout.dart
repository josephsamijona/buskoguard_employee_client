import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../screens/home_screen.dart';
import '../screens/qr_screen.dart';
import '../screens/leave_screen.dart';
import '../api.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _currentIndex = 0;
  final ApiService _apiService = ApiService();

  final List<Widget> _screens = [
    const HomeScreen(),
    const QRScreen(),
    const LeaveScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      systemOverlayStyle: SystemUiOverlayStyle.dark,
      backgroundColor: Colors.white,
      elevation: 0,
      title: Row(
        children: [
          Image.asset(
            'assets/images/logo.png',
            height: 32,
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'BuskoGuard',
                style: TextStyle(
                  color: Colors.black87,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Portail Employé',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        // Icône de notification avec badge
        Stack(
          children: [
            IconButton(
              icon: const Icon(Icons.notifications_outlined),
              color: Colors.black87,
              onPressed: () {
                // Gérer les notifications
              },
            ),
            Positioned(
              right: 8,
              top: 8,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                constraints: const BoxConstraints(
                  minWidth: 8,
                  minHeight: 8,
                ),
              ),
            ),
          ],
        ),
        // Bouton de déconnexion
        IconButton(
          icon: const Icon(Icons.logout),
          color: Colors.black87,
          onPressed: () async {
            await _apiService.logout();
            if (mounted) {
              Navigator.of(context).pushReplacementNamed('/login');
            }
          },
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 8,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: NavigationBar(
          height: 65,
          selectedIndex: _currentIndex,
          onDestinationSelected: _onItemTapped,
          destinations: [
            NavigationDestination(
              icon: Icon(
                Icons.dashboard_outlined,
                color: _currentIndex == 0 ? Theme.of(context).primaryColor : Colors.grey,
              ),
              label: 'Dashboard',
            ),
            NavigationDestination(
              icon: Icon(
                Icons.qr_code,
                color: _currentIndex == 1 ? Theme.of(context).primaryColor : Colors.grey,
              ),
              label: 'QR Code',
            ),
            NavigationDestination(
              icon: Icon(
                Icons.calendar_today_outlined,
                color: _currentIndex == 2 ? Theme.of(context).primaryColor : Colors.grey,
              ),
              label: 'Congés',
            ),
          ],
        ),
      ),
    );
  }
}