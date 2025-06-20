import 'package:flutter/material.dart';
import 'package:pokedex/services/auth_gate.dart';
import 'package:pokedex/services/auth_services.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/pokemons.png',
            height: 500,
            width: 500,
          ),
          Center(
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                elevation: 25,
                backgroundColor: Colors.grey.shade200,
                side: BorderSide(
                  color: Colors.grey.shade500,
                  width: 1,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
              onPressed: () async {
                AuthServices authServices = AuthServices();
                await authServices.signInWithGoogle();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AuthGate(),
                  ),
                );
              },
              icon: Icon(
                Icons.g_mobiledata,
                size: 45,
                color: Colors.black,
              ),
              label: Text(
                "Sign in with Google",
                style: TextStyle(color: Colors.black),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
