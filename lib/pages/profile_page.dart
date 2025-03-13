import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  final String name;
  final String surname;
  final String phoneNumber;

  const ProfilePage({
    Key? key,
    required this.name,
    required this.surname,
    required this.phoneNumber,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile Details"),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header with background color & avatar
            Container(
              width: double.infinity,
              color: Colors.blueAccent, // pick any color you like
              padding: const EdgeInsets.symmetric(vertical: 40),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Profile picture
                  const CircleAvatar(
                    radius: 50,
                    backgroundImage: AssetImage('assets/images/jane.jpg'),
                    // or NetworkImage("https://example.com/jane.jpg")
                  ),
                  const SizedBox(height: 10),
                  // Name
                  Text(
                    "$name $surname",
                    style: const TextStyle(
                      fontSize: 22,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  // Phone
                  Text(
                    phoneNumber,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Card with extra details
            Card(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.person),
                    title: const Text("Name"),
                    subtitle: Text(name),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.person_outline),
                    title: const Text("Surname"),
                    subtitle: Text(surname),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.phone),
                    title: const Text("Phone"),
                    subtitle: Text(phoneNumber),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
