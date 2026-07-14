import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'chat_room_screen.dart';

class ContactsScreen extends StatelessWidget {
  const ContactsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF075E54),
        foregroundColor: Colors.white,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Select contact",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            Text(
              "Available Users",
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.normal),
            ),
          ],
        ),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.search)),
          IconButton(onPressed: () {}, icon: const Icon(Icons.more_vert)),
        ],
      ),

      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('users').snapshots(),
        builder: (context, asyncSnapshot) {
          if (asyncSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          List<Map<String, dynamic>> users = asyncSnapshot.data!.docs
              .map((e) => e.data())
              .toList();
          return ListView.separated(
            itemBuilder: (context, index) => ListTile(
              leading: const CircleAvatar(
                radius: 25,
                backgroundColor: Color(0xFF25D366),
                child: Icon(Icons.person, color: Colors.white),
              ),
              title: Text(
                users[index]['name'],
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(users[index]['email']),
              onTap: () async {
                final currentUserId = FirebaseAuth.instance.currentUser!.uid;
                final peerId = users[index]['uid'];

                DocumentSnapshot<Map<String, dynamic>> myData =
                    await FirebaseFirestore.instance
                        .collection("users")
                        .doc(currentUserId)
                        .get();

                final existingRooms = await FirebaseFirestore.instance
                    .collection('chat_rooms')
                    .where('particentesnts_id', arrayContains: currentUserId)
                    .get();

                QueryDocumentSnapshot<Map<String, dynamic>>? foundRoom;
                for (var doc in existingRooms.docs) {
                  List participants = doc['particentesnts_id'];
                  if (participants.contains(peerId)) {
                    foundRoom = doc;
                    break;
                  }
                }

                if (foundRoom != null) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ChatRoomScreen(
                        roomId: foundRoom!.id,
                        peerName: users[index]['name'],
                      ),
                    ),
                  );
                  return;
                }

                await FirebaseFirestore.instance
                    .collection('chat_rooms')
                    .add({
                      'particentesnts_id': [currentUserId, peerId],
                      'particentesnts_names': [
                        myData['name'],
                        users[index]['name'],
                      ],
                      'lastMessage': '',
                      'lastMessageDate': null,
                    })
                    .then((value) {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ChatRoomScreen(
                            roomId: value.id,
                            peerName: users[index]['name'],
                          ),
                        ),
                      );
                    });
              },
            ),
            separatorBuilder: (context, index) => const SizedBox(height: 10),

            itemCount: users.length,
          );
        },
      ),
    );
  }
}
