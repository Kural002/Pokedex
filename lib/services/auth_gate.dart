import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pokedex/view/home_screen/home_page.dart';
import 'package:pokedex/view/login_screen/login_page.dart';

class AuthGate extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          return snapshot.hasData ? HomePage() : LoginPage();
        }
        return Center(child: CircularProgressIndicator());
      },
    );
  }
}
