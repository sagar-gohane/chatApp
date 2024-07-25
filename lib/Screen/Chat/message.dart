import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class DisplayMessage extends StatefulWidget {
  final String recipientId;
  const DisplayMessage({super.key, required this.recipientId});

  @override
  State<DisplayMessage> createState() => _DisplayMessageState();
}

class _DisplayMessageState extends State<DisplayMessage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection("messages")
          .orderBy('time', descending: true)
          .snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text("Something went wrong: ${snapshot.error}"));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text("No messages yet"));
        }

        var messages = snapshot.data!.docs.where((doc) {
          var data = doc.data() as Map<String, dynamic>;
          return (data['recipientId'] == widget.recipientId &&
                  data['senderId'] == _auth.currentUser?.uid) ||
              (data['recipientId'] == _auth.currentUser?.uid &&
                  data['senderId'] == widget.recipientId);
        }).toList();

        return ListView.builder(
          reverse: true,
          itemCount: messages.length,
          itemBuilder: (context, index) {
            var message = messages[index];
            var data = message.data() as Map<String, dynamic>;
            var time = data['time'] as Timestamp;
            var dateTime = time.toDate();
            var type = data['type'] ?? 'text';
            var isCurrentUser = _auth.currentUser?.uid == data['senderId'];

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Align(
                alignment: isCurrentUser
                    ? Alignment.centerRight
                    : Alignment.centerLeft,
                child: Container(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.75,
                  ),
                  decoration: BoxDecoration(
                    color: isCurrentUser ? Colors.blue[300] : Colors.grey[300],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Column(
                    crossAxisAlignment: isCurrentUser
                        ? CrossAxisAlignment.end
                        : CrossAxisAlignment.start,
                    children: [
                      Text(
                        isCurrentUser ? 'You' : (data['name'] ?? 'Unknown'),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: isCurrentUser ? Colors.white : Colors.black,
                        ),
                      ),
                      const SizedBox(height: 4),
                      if (type == 'text')
                        Text(
                          data['message'] ?? '',
                          style: TextStyle(
                            fontSize: 16,
                            color: isCurrentUser ? Colors.white : Colors.black,
                          ),
                        )
                      else if (type == 'image')
                        Image.network(
                          data['fileUrl'] ?? '',
                          width: 200,
                          height: 200,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Text(
                              'Could not load image',
                              style: TextStyle(color: Colors.red),
                            );
                          },
                        )
                      else if (type == 'video')
                        Container(
                          width: 200,
                          height: 200,
                          color: Colors.black26,
                          child: Center(
                            child: Text(
                              'Video: ${data['fileUrl'] ?? ''}',
                              style: TextStyle(
                                fontSize: 16,
                                color:
                                    isCurrentUser ? Colors.white : Colors.black,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      const SizedBox(height: 4),
                      Text(
                        "${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}",
                        style: TextStyle(
                          fontSize: 12,
                          color:
                              isCurrentUser ? Colors.white70 : Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
