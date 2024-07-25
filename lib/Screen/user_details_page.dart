import 'package:chatt_app/Screen/Services/auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserDetailsPage extends StatelessWidget {
  final String name;
  final AuthServices _authService = AuthServices();

  UserDetailsPage({super.key, required this.name});

  @override
  Widget build(BuildContext context) {
    User? user = _authService.getCurrentUser();
    print("User details: ${user?.displayName}, ${user?.email}");

    return Scaffold(
      appBar: AppBar(
        title: Text('User Details'),
        backgroundColor: Theme.of(context).colorScheme.background,
        elevation: 0,
      ),
      body: user != null
          ? Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircleAvatar(
                    backgroundImage: AssetImage("images/3135715.png"),
                    radius: 60,
                    backgroundColor: Colors.grey.shade200,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    name,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    user.email ?? 'No email provided',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    height: 160,
                    child: ListView(
                      children: <Widget>[
                        ListTile(
                          leading: Icon(Icons.settings),
                          title: Text('Settings'),
                          onTap: () {},
                        ),
                        ListTile(
                          leading: Icon(Icons.info),
                          title: Text('About'),
                          onTap: () {},
                        ),
                        ListTile(
                          leading: Icon(Icons.help),
                          title: Text('Help'),
                          onTap: () {},
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      _authService.signOut().then((_) {
                        Navigator.pop(context);
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      primary: Theme.of(context).colorScheme.primary,
                      padding:
                          EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Sign Out',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                  ),
                ],
              ),
            )
          : Center(
              child: Text(
                'No user logged in',
                style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
              ),
            ),
    );
  }
}
