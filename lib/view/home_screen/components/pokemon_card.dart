import 'package:flutter/material.dart';

class PokemonCard extends StatelessWidget {
  final String name;
  final String imageUrl;

  const PokemonCard({super.key, required this.name, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.grey[100],
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
            child: Image.network(
              imageUrl,
              width: 80,
              height: 80,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 120,
                  color: Colors.grey[300],
                  child: Icon(Icons.image_not_supported,
                      size: 50, color: Colors.grey),
                );
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.all(10),
            child: Text(
              name.toUpperCase(),
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
