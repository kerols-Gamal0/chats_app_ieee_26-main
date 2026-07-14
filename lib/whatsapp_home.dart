import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'chat_room_screen.dart';
import 'contacts_screen.dart';

class WhatsAppHome extends StatelessWidget {
  const WhatsAppHome({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUserId = FirebaseAuth.instance.currentUser!.uid;

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFF075E54),
          foregroundColor: Colors.white,
          title: const Text(
            "WhatsApp",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          actions: [
            IconButton(onPressed: () {}, icon: const Icon(Icons.search)),
            IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(Icons.logout),
            ),
          ],
          bottom: const TabBar(
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            tabs: [
              Tab(text: "CHATS"),
              Tab(text: "STATUS"),
              Tab(text: "CALLS"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: FirebaseFirestore.instance
                  .collection('chat_rooms')
                  .where('particentesnts_id', arrayContains: currentUserId)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData) {
                  return const Center(child: Text("لا يوجد محادثات بعد"));
                }

                final rooms = snapshot.data!.docs.where((doc) {
                  final data = doc.data();
                  final lastMessage = data['lastMessage'];
                  return lastMessage != null &&
                      lastMessage.toString().trim().isNotEmpty;
                }).toList();

                if (rooms.isEmpty) {
                  return const Center(child: Text("لا يوجد محادثات بعد"));
                }
                rooms.sort((a, b) {
                  final aDate = a.data()['lastMessageDate'];
                  final bDate = b.data()['lastMessageDate'];
                  if (aDate == null && bDate == null) return 0;
                  if (aDate == null) return 1;
                  if (bDate == null) return -1;
                  return (bDate as Timestamp).compareTo(aDate as Timestamp);
                });

                return ListView.builder(
                  itemCount: rooms.length,
                  itemBuilder: (context, index) {
                    final room = rooms[index];
                    final data = room.data();

                    final List participantsIds = List.from(
                      data['particentesnts_id'] ?? [],
                    );
                    final List participantsNames = List.from(
                      data['particentesnts_names'] ?? [],
                    );

                    final myIndex = participantsIds.indexOf(currentUserId);
                    final peerIndex = myIndex == 0 ? 1 : 0;

                    final peerName = (peerIndex < participantsNames.length)
                        ? participantsNames[peerIndex].toString()
                        : "Unknown";

                    final lastMessageDate = data['lastMessageDate'];
                    final time = lastMessageDate is Timestamp
                        ? lastMessageDate.toDate()
                        : DateTime.now();

                    return ChatBarWidget(
                      roomId: room.id,
                      name: peerName,
                      lastMessage: data['lastMessage'] ?? '',
                      time: time,
                    );
                  },
                );
              },
            ),

            const Center(child: Text("Status Tab")),
            const Center(child: Text("Calls Tab")),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: const Color(0xFF25D366),
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const ContactsScreen()),
            );
          },
          child: const Icon(Icons.message, color: Colors.white),
        ),
      ),
    );
  }
}

class ChatBarWidget extends StatelessWidget {
  ChatBarWidget({
    super.key,
    required this.name,
    required this.lastMessage,
    required this.time,
    required this.roomId,
  });

  final String roomId;
  final String name;
  final String lastMessage;
  final DateTime time;

  String _formatChatTime(DateTime time) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDate = DateTime(time.year, time.month, time.day);

    if (messageDate == today) {
      return "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}";
    } else if (messageDate == today.subtract(const Duration(days: 1))) {
      return "Yesterday";
    } else {
      return "${time.day}/${time.month}/${time.year}";
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const CircleAvatar(
        radius: 25,
        backgroundColor: Color(0xFF25D366),
        child: Icon(Icons.group, color: Colors.white),
      ),
      title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(lastMessage, maxLines: 1, overflow: TextOverflow.ellipsis),
      trailing: Text(
        _formatChatTime(time),
        style: const TextStyle(color: Colors.grey, fontSize: 12),
      ),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ChatRoomScreen(roomId: roomId, peerName: name),
          ),
        );
      },
    );
  }
}
