import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../api.dart';
import '../models/dashboard_models.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  final ApiService _apiService = ApiService();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  bool _isLoading = true;
  DashboardResponse? _dashboardData;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 1.0, curve: Curves.easeOut),
      ),
    );
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    try {
      final data = await _apiService.getDashboardData();
      if (mounted) {
        setState(() {
          _dashboardData = data;
          _isLoading = false;
        });
        _animationController.forward();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erreur de chargement des données')),
        );
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Widget _buildStatsCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
    required int index,
  }) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        final delay = index * 0.2;
        final slideAnimation = Tween<Offset>(
          begin: const Offset(0.0, 0.5),
          end: Offset.zero,
        ).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Interval(
              delay,
              delay + 0.5,
              curve: Curves.easeOut,
            ),
          ),
        );

        return FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: slideAnimation,
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          title,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                        Icon(icon, color: color, size: 24),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      value,
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildRecentLeaves() {
    if (_dashboardData == null || _dashboardData!.recentLeaves.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Dernières demandes',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 16),
            ...List.generate(
              _dashboardData!.recentLeaves.length,
              (index) {
                final leave = _dashboardData!.recentLeaves[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: Row(
                    children: [
                      Container(
                        width: 4,
                        height: 40,
                        decoration: BoxDecoration(
                          color: leave.status.toLowerCase().contains('approuvé')
                              ? Colors.green
                              : Colors.orange,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              leave.type,
                              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              '${DateFormat('d MMM').format(leave.startDate)} - ${leave.days} jours',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: leave.status.toLowerCase().contains('approuvé')
                              ? Colors.green.withOpacity(0.1)
                              : Colors.orange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          leave.status,
                          style: TextStyle(
                            color: leave.status.toLowerCase().contains('approuvé')
                                ? Colors.green
                                : Colors.orange,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      // AppBar retiré
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadDashboardData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      childAspectRatio: 1.3,
                      children: [
                        _buildStatsCard(
                          title: 'Présence',
                          value: '${_dashboardData?.attendanceStats.presentDays ?? 0}',
                          subtitle: 'sur ${_dashboardData?.attendanceStats.totalWorkingDays ?? 0} jours',
                          icon: Icons.calendar_today,
                          color: Colors.blue,
                          index: 0,
                        ),
                        _buildStatsCard(
                          title: 'Retards',
                          value: '${_dashboardData?.attendanceStats.lateCount ?? 0}',
                          subtitle: 'ce mois-ci',
                          icon: Icons.access_time,
                          color: Colors.orange,
                          index: 1,
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    _buildRecentLeaves(),
                  ],
                ),
              ),
            ),
    );
  }
}
