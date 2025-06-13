import 'package:ami_invisible_admin/core/config/app_theme.dart';
import 'package:ami_invisible_admin/providers/admin_provider.dart';
import 'package:ami_invisible_admin/providers/auth_provider.dart';
import 'package:ami_invisible_admin/providers/notification_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int users = 1000;
  int matches = 250;
  int unpaidMatches = 30;
  double totalRevenue = 1500.0;

  List<Map<String, String>> recentActivities = [
    {
      'user1': 'Michel',
      'user2': 'Kossi',
      'time': '12-05-2020 18:00',
    },
    {
      'user1': 'Afi',
      'user2': 'Koffi',
      'time': '13-05-2020 14:30',
    },
  ];

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      Provider.of<AdminProvider>(context, listen: false).fetchVerifiedUsers();
      Provider.of<AdminProvider>(context, listen: false).fetchMatchs();
      Provider.of<NotificationProvider>(context, listen: false).fetchNotifications();
    });
  }


  @override
  Widget build(BuildContext context) {
    final adminProvider = Provider.of<AdminProvider>(context);
    final isLoading = adminProvider.isLoading;
    final error = adminProvider.error;
    final verifiedUsers = adminProvider.verifiedUsers;
    final totalVerifiedUsers = adminProvider.totalVerifiedUsers;
    final screenWidth = MediaQuery.of(context).size.width;

    final isMobile = screenWidth < 600;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child:  isLoading
            ? const Center(child: CircularProgressIndicator())
            : error != null
            ? Center(child: Text("Erreur : $error"))
            : Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Dashboard',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Stack(
                    alignment: Alignment.topRight,
                    children: [
                      IconButton(
                        icon: Icon(Icons.notifications_none,
                          size: 30,),
                        onPressed:  (() {
                          context.pushNamed('notification');
                        }),
                      ),
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            Provider.of<AuthProvider>(context, listen: false).notifications_unread > 0 ? Provider.of<AuthProvider>(context, listen: false).notifications_unread.toString() : '' , // Remplace par ta variable si nécessaire
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                crossAxisSpacing: 15,
                mainAxisSpacing: 15,
                childAspectRatio: isMobile ? 1.2 : 2.3,
                physics: NeverScrollableScrollPhysics(),
                children: [
                  _buildStatCard(Icons.person, totalVerifiedUsers.toString(), 'Utilisateurs',() {
                    Provider.of<AuthProvider>(context, listen: false).changeTab(1);
                  },isMobile),
                  _buildStatCard(Icons.favorite, adminProvider.totalMatch.toString(), 'Matches',() {


                  },isMobile),
                  _buildStatCard(Icons.attach_money, '${adminProvider.totalMatchAmountPaid.toStringAsFixed(0)} FCFA', 'Total Revenue',() {
                    context.pushNamed('payement');
                  },isMobile),
                  _buildStatCard(Icons.favorite_border, adminProvider.totalMatchUnPaid.toString(), 'Matches Non Payé',() {

                  },isMobile),
                ],
              ),
              const SizedBox(height: 30),
              Text(
                'Activités recentes',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: Consumer<NotificationProvider>(
                  builder: (context, provider, child) {
                    if (provider.isLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (provider.error != null) {
                      return Center(child: Text(provider.error!));
                    }

                    final notifications = provider.notifications;

                    if (notifications.isEmpty) {
                      return const Center(child: Text('Pas d\'activité récente.'));
                    }

                    return ListView.builder(
                      itemCount: notifications.length,
                      itemBuilder: (context, index) {
                        final notif = notifications[index];

                        return Container(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Contenu textuel (titre + description)
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      notif.title ?? 'Nouveau paiement',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${notif.body}',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[800],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Date/heure à droite
                              Text(
                                notif.createdAt.toString(), // par ex. "12 juin 2025"
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                )


              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(IconData icon, String value, String label, VoidCallback onTap, bool isMobile) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: AppTheme.primaryGradient,
          borderRadius: BorderRadius.circular(20),
        ),
        padding:isMobile ?EdgeInsets.symmetric(horizontal: 20,vertical: 10)  :EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 36),
            SizedBox(height: isMobile ? 4: 10),
            Text(
              value,
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}