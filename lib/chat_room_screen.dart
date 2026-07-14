import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatRoomScreen extends StatefulWidget {
  const ChatRoomScreen({
    super.key,
    required this.roomId,
    required this.peerName,
  });

  final String roomId;
  final String peerName;

  @override
  State<ChatRoomScreen> createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends State<ChatRoomScreen> {
  final TextEditingController messageController = TextEditingController();
  final String myId = FirebaseAuth.instance.currentUser!.uid;

  @override
  void initState() {
    super.initState();
    _markRoomAsSeen();
  }

  Future<void> _markRoomAsSeen() async {
    await FirebaseFirestore.instance
        .collection('chat_rooms')
        .doc(widget.roomId)
        .update({'lastSeen.$myId': DateTime.now()});
  }

  Future<void> _markMessagesAsSeen(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> messages,
  ) async {
    final batch = FirebaseFirestore.instance.batch();
    bool hasUpdates = false;

    for (final doc in messages) {
      final data = doc.data();
      final isFromPeer = data['senderId'] != myId;
      final alreadySeen = data['seen'] == true;

      if (isFromPeer && !alreadySeen) {
        batch.update(doc.reference, {'seen': true});
        hasUpdates = true;
      }
    }

    if (hasUpdates) {
      await batch.commit();
    }
  }

  @override
  void dispose() {
    messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFECE5DD),
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: const Icon(Icons.arrow_back),
        ),
        backgroundColor: const Color(0xFF075E54),
        foregroundColor: Colors.white,
        leadingWidth: 20,
        title: Row(
          children: [
            const CircleAvatar(
              radius: 18,
              backgroundColor: Colors.white24,
              child: Icon(Icons.group, color: Colors.white),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.peerName,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(onPressed: () {}, icon: const Icon(Icons.search)),
            IconButton(onPressed: () {}, icon: const Icon(Icons.settings)),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: FirebaseFirestore.instance
                  .collection('chat_rooms')
                  .doc(widget.roomId)
                  .collection('messages')
                  .orderBy('time', descending: false)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final messages = snapshot.data!.docs;

                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _markMessagesAsSeen(messages);
                });

                return ListView.builder(
                  padding: const EdgeInsets.all(8.0),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final data = message.data();
                    final isMe = data['senderId'] == myId;

                    return MessageBubble(
                      message: data['message'],
                      isMe: isMe,
                      time: (data['time'] as Timestamp).toDate(),
                      seen: data['seen'] == true,
                    );
                  },
                );
              },
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: messageController,
                    decoration: InputDecoration(
                      hintText: "Message",
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  radius: 25,
                  backgroundColor: const Color(0xFF075E54),
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white),
                    onPressed: () async {
                      if (messageController.text.trim() != "") {
                        final textToSend = messageController.text.trim();
                        final now = DateTime.now();

                        await FirebaseFirestore.instance
                            .collection('chat_rooms')
                            .doc(widget.roomId)
                            .collection('messages')
                            .add({
                              'message': textToSend,
                              'senderId': myId,
                              'time': now,
                              'seen': false,
                            });

                        await FirebaseFirestore.instance
                            .collection('chat_rooms')
                            .doc(widget.roomId)
                            .update({
                              'lastMessage': textToSend,
                              'lastMessageDate': now,
                            });

                        messageController.clear();
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class MessageBubble extends StatelessWidget {
  final String message;
  final bool isMe;
  final DateTime time;
  final bool seen;

  const MessageBubble({
    super.key,
    required this.message,
    required this.isMe,
    required this.time,
    this.seen = false,
  });

  @override
  Widget build(BuildContext context) {
    final String formattedTime =
        "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}";

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.8,
        ),
        decoration: BoxDecoration(
          color: isMe ? const Color(0xFFDCF8C6) : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(15),
            topRight: const Radius.circular(15),
            bottomLeft: Radius.circular(isMe ? 15 : 0),
            bottomRight: Radius.circular(isMe ? 0 : 15),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 1,
            ),
          ],
        ),
        child: Wrap(
          alignment: WrapAlignment.end,
          crossAxisAlignment: WrapCrossAlignment.end,
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 8.0, bottom: 2.0),
              child: Text(message, style: const TextStyle(fontSize: 16)),
            ),
            Text(
              formattedTime,
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            if (isMe) ...[
              const SizedBox(width: 4),
              Icon(
                seen ? Icons.done_all : Icons.done,
                size: 16,
                color: seen ? const Color(0xFF34B7F1) : Colors.grey[600],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
