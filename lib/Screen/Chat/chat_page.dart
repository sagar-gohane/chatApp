import 'package:chatt_app/Screen/Chat/message.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

class ChatScreen extends StatefulWidget {
  final String recipientName;
  final String recipientId;
  const ChatScreen(
      {super.key, required this.recipientName, required this.recipientId});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController msgController = TextEditingController();
  final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
  final ImagePicker _picker = ImagePicker();
  final User? _currentUser = FirebaseAuth.instance.currentUser;

  Future<void> pickAndUploadFile() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      File file = File(image.path);
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      try {
        await FirebaseStorage.instance.ref('uploads/$fileName').putFile(file);
        String downloadUrl = await FirebaseStorage.instance
            .ref('uploads/$fileName')
            .getDownloadURL();
        firebaseFirestore.collection("messages").add({
          'message': 'Image',
          'fileUrl': downloadUrl,
          'type': 'image',
          'time': DateTime.now(),
          'senderId': _currentUser?.uid,
          'recipientId': widget.recipientId,
        });
      } catch (e) {
        print(e);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue[900],
        centerTitle: true,
        title: Text(
          widget.recipientName,
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: DisplayMessage(
              recipientId: widget.recipientId,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            child: Row(
              children: [
                GestureDetector(
                  onTap: pickAndUploadFile,
                  child: CircleAvatar(
                    radius: 20,
                    backgroundImage: AssetImage("images/img1.jpeg"),
                  ),
                ),
                Expanded(
                  child: TextFormField(
                    controller: msgController,
                    decoration: const InputDecoration(
                      filled: true,
                      hintText: "Message",
                      contentPadding:
                          EdgeInsets.only(left: 15, bottom: 8, top: 8),
                      focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.green,
                          ),
                          borderRadius: BorderRadius.all(Radius.circular(20))),
                      enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.blue,
                          ),
                          borderRadius: BorderRadius.all(Radius.circular(20))),
                    ),
                    onSaved: (newValue) {
                      msgController.text = newValue!;
                    },
                  ),
                ),
                IconButton(
                    onPressed: () {
                      if (msgController.text.isNotEmpty) {
                        firebaseFirestore.collection("messages").add({
                          'message': msgController.text.trim(),
                          'time': DateTime.now(),
                          'senderId': _currentUser?.uid,
                          'recipientId': widget.recipientId,
                        });
                        msgController.clear();
                      }
                    },
                    icon: Icon(
                      Icons.send,
                      color: Theme.of(context).colorScheme.primary,
                    ))
              ],
            ),
          )
        ],
      ),
    );
  }
}
