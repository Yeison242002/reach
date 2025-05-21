import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final User? currentUser = FirebaseAuth.instance.currentUser;
  Map<String, dynamic>? userData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    if (currentUser == null) return;

    final uid = currentUser!.uid;
    final doc =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();

    if (doc.exists) {
      setState(() {
        userData = doc.data();
        isLoading = false;
      });
    } else {
      setState(() {
        userData = null;
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E1E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E1E1E),
        title: const Text(
          'Perfil de Usuario',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.purpleAccent),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Colors.purpleAccent),
            )
          : userData == null
              ? const Center(
                  child: Text(
                    'No se encontraron datos del usuario.',
                    style: TextStyle(color: Colors.white),
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      profileField('Nombre', userData!['name'] ?? 'Desconocido'),
                      profileField('Email', userData!['email'] ?? 'No disponible'),
                      profileField(
                          'Número de teléfono', userData!['phone'] ?? 'No registrado'),
                      profileField('UID', userData!['uid']),
                    ],
                  ),
                ),
    );
  }

  Widget profileField(String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                  color: Colors.purpleAccent, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(color: Colors.white)),
        ],
      ),
    );
  }
}
