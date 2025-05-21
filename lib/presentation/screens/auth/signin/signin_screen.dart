import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _signInUser() async {
  if (!_formKey.currentState!.validate()) return;

  setState(() => _isLoading = true);

  try {
    // Buscar el email del usuario con el nombre en Firestore
    final querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('name', isEqualTo: _nameController.text.trim())
        .limit(1)
        .get();

    if (querySnapshot.docs.isEmpty) {
      _showErrorDialog('No existe un usuario con ese nombre.');
      setState(() => _isLoading = false);
      return;
    }

    final userData = querySnapshot.docs.first.data();
    final userEmail = userData['email'];

    // Intentar iniciar sesión con email y contraseña usando FirebaseAuth
    await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: userEmail,
      password: _passwordController.text.trim(),
    );

    Navigator.pushReplacementNamed(context, '/home');
  } on FirebaseAuthException catch (e) {
    // Captura errores específicos de Firebase Auth para mostrar mensajes claros
    if (e.code == 'wrong-password') {
      _showErrorDialog('Contraseña incorrecta.');
    } else if (e.code == 'user-not-found') {
      _showErrorDialog('Usuario no encontrado.');
    } else {
      _showErrorDialog('Error al iniciar sesión: ${e.message}');
    }
  } catch (e) {
    _showErrorDialog("Error al iniciar sesión: ${e.toString()}");
  } finally {
    setState(() => _isLoading = false);
  }
}


  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Aceptar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 60),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const Text(
                  "Iniciar sesión",
                  style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 30),
                _buildInputField(_nameController, Icons.person, "Introduce tu nombre de usuario"),
                _buildInputField(_passwordController, Icons.lock, "Introduce tu contraseña", obscureText: true),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _isLoading ? null : _signInUser,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple[300],
                    padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("Iniciar sesión", style: TextStyle(color: Colors.white)),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("¿No tienes una cuenta?", style: TextStyle(color: Colors.white70)),
                    TextButton(
                      onPressed: () => Navigator.pushNamed(context, '/signup'),
                      child: const Text("Regístrate", style: TextStyle(color: Colors.purpleAccent)),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputField(
    TextEditingController controller,
    IconData icon,
    String hintText, {
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(8),
      ),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.white70),
          hintText: hintText,
          hintStyle: const TextStyle(color: Colors.white60),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 18),
        ),
        validator: (value) => value == null || value.isEmpty ? 'Campo obligatorio' : null,
      ),
    );
  }
}
