import 'package:flutter/material.dart';
import 'package:tugas_besar_mobile2/models/user_model.dart';
import 'package:tugas_besar_mobile2/screens/login_screen.dart';
import 'package:tugas_besar_mobile2/services/local_db.dart';

class RegisterformScreen extends StatefulWidget {

  final Users? users;

  const RegisterformScreen({super.key, this.users});

  @override
  State<RegisterformScreen> createState() => _RegisterformScreenState();
}

class _RegisterformScreenState extends State<RegisterformScreen> {

  final _formKey = GlobalKey<FormState>();

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();


  bool _isEmailValid(String email) {
    final emailRegex = RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$");
    return emailRegex.hasMatch(email);
  }

  void _submitForm () async {
  if (_formKey.currentState!.validate()) {
    final isExist = await LocalDB.instance.isEmailExist(_emailController.text);
    if (isExist) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Email sudah digunakan'))
      );
      return;
    }

    final users = Users(
      username: _usernameController.text, 
      email: _emailController.text, 
      password: _passwordController.text,
    );

    final newIdUser = await LocalDB.instance.insertUsers(users);
    print('Akun berhasil dibuat dengan ID: $newIdUser');

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Berhasil mendaftarkan akun'))
      );
   Navigator.pushReplacement(
  context,
  MaterialPageRoute(builder: (context) => LoginScreen()),
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
                alignment: Alignment.topLeft,
                child: TextButton(
                  onPressed: () => {Navigator.pop(context)},
                  child: Text('Batalkan',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.lightBlue)),
                ),
              ),
              Center(
                child: Text('Register',
                    style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          SizedBox(height: 20),
          TextFormField(
            controller: _usernameController,
            decoration: InputDecoration(
                hintText: 'Masukkan username',
                filled: true,
                fillColor: Colors.white,
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.grey)),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.grey),
                    ),
                prefixIcon: Icon(Icons.person)
                    ),
                validator: (value)  {
                  if (value == null || value.isEmpty) {
                    return 'Username tidak boleh kosong';
                  }
                  return null;
                },
          ),
          SizedBox(height: 20),
          TextFormField(
            controller: _emailController,
            decoration: InputDecoration(
              hintText: 'Masukkan email',
              filled: true,
              fillColor: Colors.white,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.grey)
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.grey)
              ),
              prefixIcon: Icon(Icons.email)
            ),
            validator: (value)  {
              if (value == null || value.isEmpty) {
                return 'masukkan email terlebih dahulu';
              } else if (!_isEmailValid(value)) {
                return 'masukkan email yang valid';
              }
              return null;
            },
          ),
          SizedBox(height: 20),
          TextFormField(
            controller: _passwordController,
            decoration: InputDecoration(
              hintText: 'Masukkan Password',
              filled: true,
              fillColor: Colors.white,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.grey)
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.grey)
              ),
              prefixIcon: Icon(Icons.key)
            ),
            validator: (value) => value == null || value.length < 6 ? 'Minimal masukkan password 6 karakter' : null,
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
                backgroundColor: Colors.blue
              ),
              onPressed: () => _submitForm(), 
              child: Text('Register', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.white))
              ),
          )
        ],
      ),
      )
    );
  }
}
