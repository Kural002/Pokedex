import 'package:flutter/material.dart';
import 'package:pokedex/provider/favorites_provider.dart';
import 'package:provider/provider.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final favoritesProvider = Provider.of<FavoritesProvider>(context);

    final favorites = favoritesProvider.favorites;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Favorites'),
      ),
      body: favorites.isEmpty
          ? const Center(child: Text('No favorites yet.'))
          : ListView.builder(
              itemCount: favorites.length,
              itemBuilder: (context, index) {
                final pokemon = favorites[index];

                return ListTile(
                  leading: Image.network(
                    pokemon['imageUrl'],
                    height: 50,
                    width: 50,
                  ),
                  title: Text(pokemon['name'].toString().toUpperCase()),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    onPressed: () {
                      favoritesProvider.toggleFavorite(
                        pokemon['id'],
                        pokemon['name'],
                        pokemon['imageUrl'],
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}
