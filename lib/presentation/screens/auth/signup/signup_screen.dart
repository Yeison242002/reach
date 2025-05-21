import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _emailPasswordController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  //final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false;

  Future<void> _registerUser() async {
  if (!_formKey.currentState!.validate()) return;

  setState(() => _isLoading = true);

  final name = _nameController.text.trim();
  final email = _emailController.text.trim();
  final phone = _phoneController.text.trim();
  //final password = _passwordController.text.trim();

  try {
    // Verificar si el nombre de usuario ya existe
    final nameQuery = await FirebaseFirestore.instance
        .collection('users')
        .where('name', isEqualTo: name)
        .get();

    if (nameQuery.docs.isNotEmpty) {
      _showErrorDialog("El nombre de usuario ya está registrado. Usa otro.");
      setState(() => _isLoading = false);
      return;
    }

    // Verificar si el correo electrónico ya existe
    final emailQuery = await FirebaseFirestore.instance
        .collection('users')
        .where('email', isEqualTo: email)
        .get();

    if (emailQuery.docs.isNotEmpty) {
      _showErrorDialog("El correo electrónico ya está registrado. Usa otro.");
      setState(() => _isLoading = false);
      return;
    }

    // Verificar si el número de teléfono ya existe
    final phoneQuery = await FirebaseFirestore.instance
        .collection('users')
        .where('phone', isEqualTo: phone)
        .get();

    if (phoneQuery.docs.isNotEmpty) {
      _showErrorDialog("El número de teléfono ya está registrado. Usa otro.");
      setState(() => _isLoading = false);
      return;
    }

    // Crear usuario con correo y contraseña
    final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: email,
      password: _emailPasswordController.text.trim(),
    );

    // Guardar datos en Firestore
    await FirebaseFirestore.instance.collection('users').doc(credential.user!.uid).set({
      'uid': credential.user!.uid,
      'name': name,
      'email': email,
      'phone': phone,
      'createdAt': FieldValue.serverTimestamp(),
    });

    // Mostrar diálogo de éxito
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('¡Registro exitoso!'),
        content: const Text('Se ha registrado con éxito.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, '/signin');
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  } on FirebaseAuthException catch (e) {
    _showErrorDialog(e.message ?? 'Error desconocido');
  } catch (e) {
    _showErrorDialog('Error al registrar: $e');
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
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('OK'),
        ),
      ],
    ),
  );
}




  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 60),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const Text("Regístrate", style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
                const SizedBox(height: 30),

                _buildInputField(_nameController, Icons.person, "Ingresa tu nombre"),
                _buildInputField(_emailController, Icons.email, "Introduce tu correo electrónico", keyboardType: TextInputType.emailAddress),
                _buildInputField(_emailPasswordController, Icons.lock, "Introduce tu contraseña", obscureText: true),
                _buildInputField(_phoneController, Icons.phone, "Introduce tu número de teléfono", keyboardType: TextInputType.phone),
                //_buildInputField(_passwordController, Icons.lock_outline, "Enter your password", obscureText: true),

                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _isLoading ? null : _registerUser,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple[300],
                    padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("Regístrate", style: TextStyle(color: Colors.white)),
                ),

                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("¿Ya estás registrado?", style: TextStyle(color: Colors.white70)),
                    TextButton(
                      onPressed: () => Navigator.pushNamed(context, '/signin'),
                      child: const Text("Iniciar sesión", style: TextStyle(color: Colors.purpleAccent)),
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
