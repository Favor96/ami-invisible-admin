import 'package:ami_invisible_admin/core/config/app_theme.dart';
import 'package:ami_invisible_admin/core/config/text_style.dart';
import 'package:ami_invisible_admin/providers/admin_provider.dart';
import 'package:ami_invisible_admin/providers/notification_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PayementScreen extends StatefulWidget {
  @override
  State<PayementScreen> createState() => _PayementScreenState();
}

class _PayementScreenState extends State<PayementScreen> {
  @override
  void initState() {
    super.initState();

    Future.microtask(() =>
        Provider.of<AdminProvider>(context, listen: false)
            .fetchPayements());
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AdminProvider>(context);
    return  SafeArea(
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          scrolledUnderElevation: 0,
          title: Stack(
            alignment: Alignment.center,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    border: Border.all(color: Colors.grey.shade300),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: IconButton(
                    icon: ShaderMask(
                      shaderCallback: (bounds) =>
                          AppTheme.primaryGradient.createShader(bounds),
                      child: const Icon(Icons.arrow_back, color: Colors.white),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ),
              ),
              Text("Liste des payements", style: AppTextStyles.h3Bold),
            ],
          ),
        ),
        body: provider.isLoading
            ? const Center(child: CircularProgressIndicator())
            : provider.error != null
            ? Center(child: Text(provider.error!))
            : provider.payements.isEmpty
            ? const Center(
          child: Text(
            'Pas de payements effectué',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        )
            :  ListView.builder(
          itemCount: provider.payements.length,
          itemBuilder: (context, index) {
            final notif = provider.payements[index];
            final currentUser = notif['user'];

            final user1 = notif['match']['user1'];
            final user2 = notif['match']['user2'];

            final femm = currentUser['id'] == user1['id'] ? user2 : user1;
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              color: Colors.grey.shade200,
              child: ListTile(
                leading: Icon(Icons.swap_horiz, color: AppTheme.primaryColor),
                title: Text("Paiement de ${notif['amount']} FCFA"),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "${notif['user']['nom']} ${notif['user']['prenom']} a effectué le paiement de ${notif['amount']} pour son match avec ${femm['nom']} ${femm['prenom']}",
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${notif['created_at']}',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // Status avec couleur
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: getStatusColor(notif['status']).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        getStatusLabel(notif['status']),
                        style: TextStyle(
                          color: getStatusColor(notif['status']),
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(height: 1),
                    // Date

                  ],
                ),
              ),
            );
          },

        ),
      ),
    );

  }

  Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'accepted':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'failed':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String getStatusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'paid':
        return 'Payé';
      case 'pending':
        return 'En cours';
      case 'failed':
        return 'Échoué';
      default:
        return 'Inconnu';
    }
  }
}
