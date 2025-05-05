import 'package:flutter/material.dart';
import 'package:tugas_besar_mobile2/screens/home_screen.dart';

class LoginformScreen extends StatefulWidget {
  const LoginformScreen({super.key});

  @override
  State<LoginformScreen> createState() => _LoginformScreenState();
}

class _LoginformScreenState extends State<LoginformScreen> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
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
          TextField(
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
          ),
          SizedBox(height: 20),
          TextField(
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
                onPressed: () => {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => HomeScreen()))
                }, 
                child: Text('Login', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 17)))
            ),
          SizedBox(height: 20),
          TextButton(onPressed: () => {}, 
          child: Text('Lupa password?')
          )
        ],
      )
      );
  }
}