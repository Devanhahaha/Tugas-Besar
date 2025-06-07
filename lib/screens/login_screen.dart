import 'package:flutter/material.dart';
import 'package:tugas_besar_mobile2/components/clip_path.dart';
import 'package:tugas_besar_mobile2/components/square_tile.dart';
import 'package:tugas_besar_mobile2/screens/home_screen.dart';
import 'package:tugas_besar_mobile2/screens/loginForm_screen.dart';
import 'package:tugas_besar_mobile2/screens/registerForm_screen.dart';
import 'package:tugas_besar_mobile2/services/auth_services.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    void _showModalFormRegister() {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        builder: (context) {
          double heighFactor = 0.5;
          if (MediaQuery.of(context).viewInsets.bottom > 0) {
            heighFactor = 0.8;
          }
          return FractionallySizedBox(
            heightFactor: heighFactor,
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                ),
                child: RegisterformScreen(),
              ),
            ),
          );
        },
      );
    }

    void _showModalFormLogin() {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        builder: (context) {
          double heighFactor = 0.5;
          if (MediaQuery.of(context).viewInsets.bottom > 0) {
            heighFactor = 0.7;
          }
          return FractionallySizedBox(
            heightFactor: heighFactor,
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                ),
                child: LoginformScreen(),
              ),
            ),
          );
        },
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Login',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.blue,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Stack(
            children: [
              Column(
                children: [
                  ClipPath(
                    clipper: ClipPathClass(),
                    child: Container(
                      height: 360,
                      width: MediaQuery.of(context).size.width,
                      color: Colors.blue,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 200),
                    child: Card(
                      color: Colors.blue,
                      elevation: 4,
                      margin: EdgeInsets.symmetric(horizontal: 20),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Container(
                        margin: EdgeInsets.symmetric(horizontal: 20),
                        padding: EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            ElevatedButton(
                              onPressed: () => _showModalFormLogin(),
                              style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: Icon(Icons.person,
                                        color: Colors.lightBlue),
                                  ),
                                  Center(
                                    child: Text(
                                      'Login',
                                      style: TextStyle(color: Colors.lightBlue),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 10),
                            ElevatedButton(
                              onPressed: () => _showModalFormRegister(),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: Icon(
                                      Icons.app_registration,
                                      color: Colors.lightBlue,
                                    ),
                                  ),
                                  Center(
                                    child: Text(
                                      'Register',
                                      style: TextStyle(color: Colors.lightBlue),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 10),
                            ElevatedButton(
                              onPressed: () =>
                                  AuthServices().signInWithGoogle(context),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: Image.asset(
                                      'assets/images/google.jpg',
                                      width: 24,
                                      height: 24,
                                    ),
                                  ),
                                  Center(
                                    child: Text(
                                      'Sign in with Google',
                                      style: TextStyle(color: Colors.lightBlue),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Center(
                  child: Image.asset(
                    'assets/images/mahasiswa.png',
                    width: MediaQuery.of(context).size.width,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
