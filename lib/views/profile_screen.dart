import 'package:ami_invisible_admin/providers/auth_provider.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();

  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Paramètres'),
          centerTitle: true,
        ),
        body: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            // Section profil
            Row(
              children: [
                const CircleAvatar(
                  radius: 30,
                  backgroundImage: AssetImage(
                      'assets/img/avatar_fem.jpg'), // ou NetworkImage(...)
                ),
                const SizedBox(width: 16),
                // Column(
                //   crossAxisAlignment: CrossAxisAlignment.start,
                //   children: [
                //     Text(
                //         '${Provider
                //             .of<AuthProvider>(context, listen: false)
                //             .userMap!['nom']} ${Provider
                //             .of<AuthProvider>(context, listen: false)
                //             .userMap!['prenom']}',
                //         style:
                //         TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                //     Text('${Provider
                //         .of<AuthProvider>(context, listen: false)
                //         .userMap!['profil']['age']} ans', style: TextStyle(color: Colors.grey)),
                //   ],
                // )
              ],
            ),
            const SizedBox(height: 30),

            // _buildSettingItem(Icons.notifications, 'Notifications', () {
            //   context.pushNamed('userNotification');
            // }),

            // _buildSettingItem(
            //     Icons.medical_services, 'Préférences médicales', () {}),
            _buildSettingItem(Icons.help_outline, 'Aide & Support', () {}),
            _buildSettingItem(Icons.logout, 'Se déconnecter', () async {
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) {
                  return const Center(child: CircularProgressIndicator());
                },
              );

              final provider = Provider.of<AuthProvider>(context, listen: false);
              await provider.logout();
              await FirebaseMessaging.instance.deleteToken();

              Navigator.of(context).pop();

              if (provider.error == null) {
                GoRouter.of(context).go('/signin');
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(provider.error!)),
                );
              }
            }),
          ],
        ),
      ),
    );
  }


  Widget _buildLoadingModal() {
    return Dialog(
      backgroundColor: Colors.transparent, // Fond transparent
      insetPadding: EdgeInsets.zero,
      child: Container(
        width: double.infinity,
        height: double.infinity, // Prend tout l'écran
        color: Colors.black.withOpacity(0.5), // Fond assombri
        child: const Center(
          child: CircularProgressIndicator(), // Loader centré
        ),
      ),
    );
  }


  Widget _buildSettingItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }
}
