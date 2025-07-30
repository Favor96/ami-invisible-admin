import 'dart:developer';
import 'dart:io';
import 'package:ami_invisible_admin/core/config/app_theme.dart';
import 'package:ami_invisible_admin/core/config/text_style.dart';
import 'package:ami_invisible_admin/providers/admin_provider.dart';
import 'package:ami_invisible_admin/providers/auth_provider.dart';
import 'package:ami_invisible_admin/providers/chat_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
class InteractionsPage extends StatefulWidget {
  final List<dynamic> interactions;
  final String username;
  final int id;
  const InteractionsPage({
    super.key,
    required this.interactions,
    required this.username,
    required this.id
  });

  @override
  State<InteractionsPage> createState() => _InteractionPageState();
}


class _InteractionPageState extends State<InteractionsPage> {
  final ScrollController _scrollController = ScrollController();
  bool _showSearch = false;
  final TextEditingController searchCtrl = TextEditingController();
  String searchText = '';
  bool selectUser = false ;

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.white, // Barre de statut blanche
      statusBarIconBrightness: Brightness.dark, // Icônes foncées
      systemNavigationBarColor: const Color(0xFFC4C4C4), // Barre de navigation blanche
      systemNavigationBarIconBrightness: Brightness.dark,
    ));
    Future.microtask(() async {
      final userMap =
      await Provider.of<AuthProvider>(context, listen: false).userMap;
      await Provider.of<AuthProvider>(context, listen: false).fetchUser();
      final userId = userMap!['user_id'];
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body:  Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                children: [
                  const SizedBox(height: 10),
                   Row(
                    children: [
                      const SizedBox(height: 10),
                       Text(
                        'Discussion de ${widget.username}',
                        style: AppTextStyles.h4Bold, // Ton style personnalisé
                      ),
                    ],
                  ),
                  if (_showSearch)
                    TextField(
                      controller: searchCtrl,
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(
                        hintText: "Rechercher",
                        hintStyle: const TextStyle(fontSize: 14, color: Colors.black),
                        prefixIcon:
                        const Icon(Icons.search, color: AppTheme.textColor),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(50),
                          borderSide:
                          const BorderSide(color: Color(0xFFADAFBB), width: 1.5),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(50),
                          borderSide:
                          const BorderSide(color: Color(0xFFADAFBB), width: 2.0),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(50),
                          borderSide:
                          const BorderSide(color: Color(0xFFADAFBB), width: 0),
                        ),
                      ),
                      onChanged: (value) {
                        setState(() {
                          searchText = value.toLowerCase();
                        });
                      },
                    ),
                  Expanded(
                    child: Consumer<AdminProvider>(
                      builder: (context, likeProvider, child) {
                        if (likeProvider.isLoading) {
                          return const Center(child: CircularProgressIndicator());
                        }
      
                        if (likeProvider.error != null) {
                          return Center(child: Text(likeProvider.error!));
                        }
      
                        final likedUsers = widget.interactions.where((user) {
                          final name = user['nom']?.toLowerCase() ?? '';
                          return name.contains(searchText);
                        }).toList();
                        log("LIKED $likedUsers");
      
                        if (likedUsers.isEmpty) {
                          return const Center(child: Text("Aucun utilisateur liké."));
                        }
      
                        return NotificationListener<UserScrollNotification>(
                          onNotification: (notification) {
                            if (notification.direction == ScrollDirection.forward) {
                              if (!_showSearch) {
                                setState(() {
                                  _showSearch = true;
                                });
                              }
                            } else if (notification.direction ==
                                ScrollDirection.reverse) {
                              if (_showSearch) {
                                setState(() {
                                  _showSearch = false;
                                });
                              }
                            }
                            return true;
                          },
                          child: ListView.builder(
                            controller: _scrollController,
                            physics: const AlwaysScrollableScrollPhysics(),
                            itemCount: likedUsers.length,
                            itemBuilder: (context, index) {
                              final user = likedUsers[index];
                              String name;
                              if (user['nom']?.toString().trim().isNotEmpty == true &&
                                  user['prenom']?.toString().trim().isNotEmpty == true) {
                                name = '${user['nom']} ${user['prenom']}';
                              } else if (user['prenom']?.toString().trim().isNotEmpty == true) {
                                name = user['prenom'];
                              } else if (user['nom']?.toString().trim().isNotEmpty == true) {
                                name = user['nom'];
                              } else {
                                name = '';
                              }
                              return GestureDetector(
                                onTap: () {
                                  final chatProvider = Provider.of<ChatProvider>(
                                      context,
                                      listen: false);
                                  chatProvider.setCurrentOpenUserId(user['id']);
                                  if (user['unread_messages_count'] > 0) {
                                    chatProvider.markAllMessageAsRead(user['id']);
                                  }
                                  if (chatProvider.unreadSendersCount > 0 && user['unread_messages_count'] > 0) {
                                    chatProvider.decrementUnreadSendersCount();
                                  }
                                  setState(() {
                                    selectUser = true;
                                    likedUsers[index]['unread_messages_count'] = 0;
                                  });
                                  _showChatModal(context, user);
      
                                },
      
                                child: messageItem(
                                    name: name,
                                    lastMessage: user['last_message'] == null ?'':user['last_message']['content'] == null ? "Photo" : user['last_message']['content'],
                                    time: user['last_message'] == null ?'': extractHour(
                                        user['last_message']['created_at']),
                                    isOnline: false,
                                    isMe: user['last_message_sent_by_me']),
      
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            )
      ),
    );
  }

  String formatMessageDate(DateTime date) {
    final now = DateTime.now();
    final yesterday = now.subtract(Duration(days: 1));
    final difference = now.difference(date);

    if (DateUtils.isSameDay(now, date)) {
      return 'Aujourd\'hui';
    } else if (DateUtils.isSameDay(yesterday, date)) {
      return 'Hier';
    } else if (difference.inDays < 7) {
      return DateFormat.EEEE('fr_FR').format(date);
    } else {
      return DateFormat('d MMMM', 'fr_FR').format(date);
    }
  }

  void showModal(BuildContext context, Map<String, dynamic> user) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Stack(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 40),
              height: MediaQuery.of(context).size.height * 0.8,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Nom, prénom et âge
                      Row(
                        children: [
                          Text(
                            '${user['nom']} ${user['prenom']}',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              '${user['profil']['age']} ans',
                              style: const TextStyle(
                                fontSize: 20,
                                color: Colors.grey,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      // Profession
                      if (user['profil']['profession'] != null)
                        Text(
                          user['profil']['profession'],
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                      const SizedBox(height: 20),

                      // Localisation
                      Row(
                        children: [
                          const Icon(Icons.location_on, size: 16),
                          const SizedBox(width: 5),
                          const Text('Adresse'),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(user['profil']['lieu_residence'] ?? ''),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Sexe
                      if (user['profil']['sexe'] != null)
                        Row(
                          children: [
                            const Text(
                              'Sexe : ',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(user['profil']['sexe']),
                          ],
                        ),
                      const SizedBox(height: 10),

                      // Nationalité
                      if (user['profil']['nationalite'] != null)
                        Row(
                          children: [
                            const Text(
                              'Nationalité : ',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(user['profil']['nationalite']),
                          ],
                        ),
                      const SizedBox(height: 10),

                      // Ethnie
                      if (user['profil']['ethnie'] != null)
                        Row(
                          children: [
                            const Text(
                              'Ethnie : ',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(user['profil']['ethnie']),
                          ],
                        ),
                      const SizedBox(height: 10),

                      // Situation matrimoniale
                      if (user['profil']['situation_matrimoniale'] != null)
                        Row(
                          children: [
                            const Text(
                              'Situation matrimoniale : ',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(user['profil']['situation_matrimoniale']),
                          ],
                        ),
                      const SizedBox(height: 10),

                      // Taille
                      if (user['profil']['taille'] != null)
                        Row(
                          children: [
                            const Text(
                              'Taille : ',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(user['profil']['taille']),
                          ],
                        ),
                      const SizedBox(height: 10),

                      // Teint
                      if (user['profil']['teint'] != null)
                        Row(
                          children: [
                            const Text(
                              'Teint : ',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(user['profil']['teint']),
                          ],
                        ),
                      const SizedBox(height: 10),

                      // Groupe sanguin
                      if (user['profil']['groupe_sanguin'] != null)
                        Row(
                          children: [
                            const Text(
                              'Groupe sanguin : ',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(user['profil']['groupe_sanguin']),
                          ],
                        ),
                      const SizedBox(height: 10),

                      // Religion
                      if (user['profil']['religion'] != null)
                        Row(
                          children: [
                            const Text(
                              'Religion : ',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(user['profil']['religion']),
                          ],
                        ),
                      const SizedBox(height: 10),

                      // Niveau d’études
                      if (user['profil']['niveau_etudes'] != null)
                        Row(
                          children: [
                            const Text(
                              'Niveau d’études : ',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(user['profil']['niveau_etudes']),
                          ],
                        ),
                      const SizedBox(height: 20),
                      // Centre d'intérêt (comme avant)
                      Row(
                        children: [
                          Expanded(child: Divider(color: Colors.grey[400])),
                          Padding(
                            padding:
                            const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Text(
                              'Centre d\'intérêt',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ),
                          Expanded(child: Divider(color: Colors.grey[400])),
                        ],
                      ),
                      const SizedBox(height: 20),

                      GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: 3,
                        childAspectRatio: 2,
                        children: user['interests']
                            .map<Widget>((interest) {
                          return _buildCategoryItem(interest['name']);
                        }).toList(),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCategoryItem(String title) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(50), // Full arrondi
      ),
      alignment: Alignment.center,
      child: Text(
        title,
        style: const TextStyle(fontSize: 12),
      ),
    );
  }


  void _showChatModal(BuildContext parent, Map<String, dynamic> user) async {
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    chatProvider.clearMessagesBetween();
    chatProvider.fetchChatMessageBetweenTwoUser(user['id'],widget.id);
    final TextEditingController controller = TextEditingController();
    final ScrollController _scrollController = ScrollController();
    void scrollToBottom() {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
        }
      });
    }
    List<PlatformFile> selectedFiles = [];
    showModalBottomSheet(
      context: parent,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
          statusBarColor: Colors.white,
          statusBarIconBrightness: Brightness.dark,
          systemNavigationBarColor: const Color(0xFFC4C4C4),
          systemNavigationBarIconBrightness: Brightness.dark,
        ));
        bool isSending = false;

        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.9,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Padding(
                padding:
                const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
                child: Column(
                  children: [
                    AppBar(
                      title: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${user['nom']} ${user['prenom']} -> ${widget.username}',
                                style: const TextStyle(fontWeight: FontWeight.bold,fontSize: 14),
                              ),
                              const Text(
                                'En ligne',
                                style: TextStyle(fontSize: 12, color: Colors.grey),
                              ),
                            ],
                          ),
                          Spacer(),

                          IconButton(
                            icon:  Icon(Icons.info, color: AppTheme.primaryColor),
                            tooltip: "Voir ses conversations",
                            onPressed: () {
                              showModal(context,user);
                            },
                          ),

                        ],
                      ),
                      centerTitle: false,
                      automaticallyImplyLeading: false,

                    ),
                    Expanded(
                      child: Consumer<ChatProvider>(
                        builder: (context, provider, child) {
                          if(selectUser && provider.isLoading){
                            return Container();
                          }
                          final messages = provider.chatAllMessageBetween ?? [];

                          if (messages.isEmpty) {
                            return const Center(
                              child: Text(
                                'Aucun Message',
                                style:
                                TextStyle(fontSize: 12, color: Colors.grey),
                              ),
                            );
                          }
                          if (messages.isNotEmpty) {
                            scrollToBottom();
                          }

                          return ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            controller: _scrollController,
                            itemCount: messages.length,
                            itemBuilder: (context, index) {
                              final msg = messages[index];
                              final List<dynamic> file = msg['files'] ?? [];
                              if(file.isNotEmpty){
                                file.forEach((e) {
                                });
                              }
                              final currentDate =
                              DateTime.parse(msg['created_at']);

                              String? dateLabel;
                              if (index == 0) {
                                dateLabel = formatMessageDate(currentDate);
                              } else {
                                final previousDate = DateTime.parse(
                                    messages[index - 1]['created_at']);
                                if (!DateUtils.isSameDay(
                                    currentDate, previousDate)) {
                                  dateLabel = formatMessageDate(currentDate);
                                }
                              }

                              final List<dynamic> files = msg['files'] ?? [];

                              return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (dateLabel != null)
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 8),
                                        child: Center(
                                          child: Text(
                                            dateLabel,
                                            style: const TextStyle(
                                                color: Colors.grey),
                                          ),
                                        ),
                                      ),
                                    if(msg['content'] != null) chatBubble(
                                      message: msg['content'] == null ? "" :msg['content'],
                                      time: msg['created_at'],
                                      isMe: msg['isMe'],
                                    ),
                                    if (files != null &&
                                        files .isNotEmpty)
                                      chatImageBubble(files: files, isMe: msg['isMe'])

                                  ]
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget chatImageBubble({
    required List<dynamic> files,
    required bool isMe,
    bool isRead = false,
    Key? key,
  }) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: isMe
            ? const EdgeInsets.only(left: 20)
            : const EdgeInsets.only(right: 20),
        child: Container(
          key: key,
          margin: const EdgeInsets.symmetric(vertical: 4),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isMe
                ? Colors.grey[200]
                : AppTheme.primaryColor.withOpacity(0.2),
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(12),
              topRight: const Radius.circular(12),
              bottomLeft:
              isMe ? const Radius.circular(12) : const Radius.circular(0),
              bottomRight:
              isMe ? const Radius.circular(0) : const Radius.circular(12),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: files.map<Widget>((fileData) {
                  final String mediaPath = fileData['media_path'] ?? '';
                  final String mediaType = fileData['media_type'] ?? '';

                  if (mediaType == 'image') {
                    return GestureDetector(
                      onTap: () {
                        openFullScreenImage(context, mediaPath);
                      },
                      child: Image.network(
                        mediaPath,
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 100,
                            height: 100,
                            color: Colors.grey[300],
                            child: const Icon(Icons.broken_image),
                          );
                        },
                      ),
                    );
                  } else {
                    return Container(
                      width: 100,
                      height: 100,
                      color: Colors.grey[200],
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.insert_drive_file, size: 40),
                          const SizedBox(height: 8),
                          Text(
                            mediaType.toUpperCase(),
                            style: const TextStyle(fontSize: 12),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  }
                }).toList(),
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    extractHour(files[0]['created_at']),
                    style: TextStyle(
                      color: isMe ? Colors.black : Colors.grey,
                      fontSize: 10,
                    ),
                  ),
                  if (isMe) ...[
                    const SizedBox(width: 6),
                    Icon(
                      isRead ? Icons.done_all : Icons.done,
                      size: 16,
                      color: isRead ? AppTheme.primaryColor : Colors.grey,
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }


  void openFullScreenImage(BuildContext context, String imageUrl) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
          body: Center(
            child: InteractiveViewer(
              panEnabled: true,
              minScale: 0.5,
              maxScale: 4,
              child: Image.network(
                imageUrl,
                errorBuilder: (context, error, stackTrace) => const Icon(
                  Icons.broken_image,
                  size: 100,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }



  Widget chatBubble({
    required String message,
    required String time,
    required bool isMe,
    bool isRead = false,
    Key? key,
  }) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: isMe
            ? const EdgeInsets.only(left: 20)
            : const EdgeInsets.only(right: 20),
        child: Container(
          key: key,
          margin: const EdgeInsets.symmetric(vertical: 4),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isMe
                ? Colors.grey[200]
                : AppTheme.primaryColor.withOpacity(0.2),
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(12),
              topRight: const Radius.circular(12),
              bottomLeft:
              isMe ? const Radius.circular(12) : const Radius.circular(0),
              bottomRight:
              isMe ? const Radius.circular(0) : const Radius.circular(12),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                message,
                style: TextStyle(
                  color: isMe ? Colors.black : Colors.black,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    extractHour(time),
                    style: TextStyle(
                      color: isMe ? Colors.black : Colors.grey,
                      fontSize: 10,
                    ),
                  ),
                  if (isMe) ...[
                    const SizedBox(width: 6),
                    Icon(
                      isRead ? Icons.done_all : Icons.done,
                      size: 16,
                      color: isRead ? AppTheme.primaryColor : Colors.grey,
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String extractHour(String time) {
    final date = DateTime.parse(time); // si ISO
    return DateFormat('HH:mm').format(date); // Exemple : 22:57
  }

  Widget messageItem({
    required String name,
    required String lastMessage,
    required String time,
    bool isOnline = false,
    bool isMe = false,
  }) {

    return Column(
      children: [
        ListTile(
          contentPadding: EdgeInsets.all(0),
          leading: CircleAvatar(
            radius: 30,
            backgroundColor: Colors.grey[300],
            child: Text(
              name.substring(0, 1),
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          title: Row(
            children: [
              Text(
                name,
                style: AppTextStyles.h6Bold,
              ),
              if (isOnline)
                Container(
                  margin: const EdgeInsets.only(left: 4),
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
          subtitle: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  isMe ? "Lui: $lastMessage" : lastMessage,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontStyle: lastMessage == "Ecrire.."
                        ? FontStyle.italic
                        : FontStyle.normal,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                time,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),

            ],
          ),
        ),
      ],
    );
  }

}


