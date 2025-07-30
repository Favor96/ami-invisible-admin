import 'package:ami_invisible_admin/core/config/app_theme.dart';
import 'package:ami_invisible_admin/core/config/text_style.dart';
import 'package:ami_invisible_admin/providers/notification_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


class NotificationUserScreen extends StatefulWidget {
  @override
  State<NotificationUserScreen> createState() => _NotificationUserScreenState();
}

class _NotificationUserScreenState extends State<NotificationUserScreen> {
  @override
  void initState() {
    super.initState();

    Future.microtask(() =>
        Provider.of<NotificationProvider>(context, listen: false)
            .fetchNotifications());
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<NotificationProvider>(context);

    return  SafeArea(
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
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
               Text("Notification", style: AppTextStyles.h3Bold),
            ],
          ),
        ),
        body: provider.isLoading
            ? const Center(child: CircularProgressIndicator())
            : provider.error != null
            ? Center(child: Text(provider.error!))
            : provider.notifications.isEmpty
            ? const Center(
          child: Text(
            'Pas de notification',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        )
            :  ListView.builder(
          itemCount: provider.notifications.length,
          itemBuilder: (context, index) {
            final notif = provider.notifications[index];
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              color: notif.is_read ? Colors.white : Colors.grey.shade200,
              child: ListTile(
                leading: Icon(Icons.notifications, color: AppTheme.primaryColor),
                title: Text(notif.title),
                subtitle: Text(notif.body),
                trailing: Text(
                  '${notif.created_at_formatted.toLocal()}'.split('.')[0],
                  style: const TextStyle(fontSize: 12),
                ),
              ),
            );
          },

        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            context.read<NotificationProvider>().fetchNotifications();
          },
          child: const Icon(Icons.refresh),
        ),
      ),
    );

  }
}
