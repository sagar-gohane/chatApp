import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthServices {
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? getCurrentUser() {
    return _auth.currentUser;
  }

  Future<void> updateDisplayName(String name) async {
    User? user = _auth.currentUser;
    if (user != null) {
      await user.updateProfile(displayName: name);
      await user.reload();
      user = _auth.currentUser;
      print("Updated user display name to: ${user!.displayName}");
    }
  }

  Future<String> getUserId() async {
    User? user = _auth.currentUser;
    return user?.uid ?? "";
  }

  Future<String> getUserName() async {
    User? user = _auth.currentUser;
    return user?.displayName ?? "";
  }

  Future<String> signUpUser({
    required String email,
    required String password,
    required String name,
  }) async {
    String res = "Some error occurred";
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      User? user = result.user;

      if (user != null) {
        await updateDisplayName(name);
        await _firebaseFirestore.collection('users').doc(user.uid).set({
          'uid': user.uid,
          'email': email,
          'name': name,
        });
        res = "User registered successfully";
      }
    } catch (e) {
      print(e.toString());
      res = _getFriendlyErrorMessage(e);
    }
    return res;
  }

  Future<Map<String, dynamic>> loginUser({
    required String email,
    required String password,
  }) async {
    Map<String, dynamic> res = {
      "status": "Some error occurred",
      "name": "",
    };
    try {
      if (email.isNotEmpty && password.isNotEmpty) {
        UserCredential userCredential = await _auth.signInWithEmailAndPassword(
            email: email, password: password);

        DocumentSnapshot userDoc = await _firebaseFirestore
            .collection('users')
            .doc(userCredential.user!.uid)
            .get();

        if (userDoc.exists) {
          res["status"] = "Successfully logged in";
          res["name"] = userDoc.get('name');
        } else {
          res["status"] = "User not registered";
        }
      } else {
        res["status"] = "Please enter all the fields";
      }
    } catch (e) {
      print(e.toString());
      res["status"] = _getFriendlyErrorMessage(e);
    }
    return res;
  }

  void addTypeFieldToMessages() async {
    QuerySnapshot querySnapshot =
        await _firebaseFirestore.collection('Message').get();
    for (QueryDocumentSnapshot doc in querySnapshot.docs) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      if (!data.containsKey('type')) {
        await doc.reference.update({'type': 'text'});
      }
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  String _getFriendlyErrorMessage(dynamic error) {
    // Customize this method to map common errors to friendly messages
    return error.toString();
  }
}
