import 'package:flutter/material.dart';

class RegisterformScreen extends StatefulWidget {
  const RegisterformScreen({super.key});

  @override
  State<RegisterformScreen> createState() => _RegisterformScreenState();
}

class _RegisterformScreenState extends State<RegisterformScreen> {
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
          TextField(
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
          ),
          SizedBox(height: 20),
          TextField(
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
          ),
          SizedBox(height: 20),
          TextField(
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
              onPressed: () => {}, 
              child: Text('Register', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.white))
              ),
          )
        ],
      ),
    );
  }
}
