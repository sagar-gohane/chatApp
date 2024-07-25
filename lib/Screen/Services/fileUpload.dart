import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

Future<void> _pickAndUploadFile() async {
  final ImagePicker _picker = ImagePicker();
  final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

  if (image != null) {
    File file = File(image.path);
    String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    try {
      await FirebaseStorage.instance.ref('uploads/$fileName').putFile(file);
      String downloadUrl = await FirebaseStorage.instance
          .ref('uploads/$fileName')
          .getDownloadURL();
    } catch (e) {
      print("Error uploading file: $e");
    }
  }
}
