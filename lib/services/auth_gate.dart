import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pokedex/view/home_screen/home_page.dart';
import 'package:pokedex/view/login_screen/login_page.dart';
import 'package:provider/provider.dart';
import 'package:pokedex/provider/favorites_provider.dart';


class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasData && snapshot.data != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            final favoritesProvider =
                Provider.of<FavoritesProvider>(context, listen: false);
            favoritesProvider.loadFavorites();
          });

          return  HomePage();
        }

        return LoginPage();
      },
    );
  }
}
