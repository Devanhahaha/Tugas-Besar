import 'package:flutter/material.dart';
import 'package:tugas_besar_mobile2/screens/home_screen.dart';
import 'package:tugas_besar_mobile2/screens/login_screen.dart';
import 'package:tugas_besar_mobile2/services/local_db.dart';
import 'package:shared_preferences/shared_preferences.dart';


class LoginformScreen extends StatefulWidget {
  const LoginformScreen({super.key});

  @override
  State<LoginformScreen> createState() => _LoginformScreenState();
}

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();


class _LoginformScreenState extends State<LoginformScreen> {

  void _login() async {
  if (_formKey.currentState!.validate()) {
    final email = _emailController.text;
    final password = _passwordController.text;

    final Users = await LocalDB.instance.checkUser(email, password);

    if (Users != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_data', Users.toJson());

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => HomeScreen()),
      );
    } else {

       Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => LoginScreen()),
        (route) => false
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Email atau password salah')),
      );
    }
  }
}
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton(
                  onPressed: () => Navigator.pop(context), 
                    child: Text('Batalkan', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.lightBlue))
                  ),

                ),
                Center(
                  child: Text('Login', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                )
            ],

          ),
          TextFormField(
            controller: _emailController,
            decoration: InputDecoration(
              prefixIcon: Icon(Icons.person),
              filled: true,
              fillColor: Colors.white,
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.grey)
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.grey)
              ),
              hintText: 'Masukkan email',
              border: InputBorder.none
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Masukkan email terlebih dahulu';
                }
                return null;
              },
          ),
          SizedBox(height: 20),
          TextFormField(
            controller: _passwordController,
            decoration: InputDecoration(
              hintText: 'Masukkan password',
              prefixIcon: Icon(Icons.key),
              filled: true,
              fillColor: Colors.white,
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.grey)
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.grey)
              )
              ),
                validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Masukkan password terlebih dahulu';
                }
                return null;
              },
          ),
          SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)
                  ),
                  backgroundColor: Colors.lightBlue
                ),
                onPressed: () => _login(), 
                child: Text('Login', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 17)))
            ),
          SizedBox(height: 20),
        ],
      )
      )
      );
  }
}