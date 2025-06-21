import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class FavoritesProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<Map<String, dynamic>> _favorites = [];

  List<Map<String, dynamic>> get favorites => _favorites;

  /// Load favorites from Firestore
  Future<void> loadFavorites() async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('favorites')
          .get();

      _favorites = snapshot.docs.map((doc) {
        return {
          'id': doc.id,
          'name': doc['name'],
          'imageUrl': doc['imageUrl'],
        };
      }).toList();

      notifyListeners();
    } catch (e) {
      debugPrint('Failed to load favorites: $e');
    }
  }

  /// Toggle favorite (add or remove)
  Future<void> toggleFavorite(String id, String name, String imageUrl) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final docRef = _firestore
        .collection('users')
        .doc(user.uid)
        .collection('favorites')
        .doc(id);

    final docSnapshot = await docRef.get();

    if (docSnapshot.exists) {
      // Remove from Firestore
      await docRef.delete();
      _favorites.removeWhere((item) => item['id'] == id);
    } else {
      // Add to Firestore
      await docRef.set({
        'name': name,
        'imageUrl': imageUrl,
      });
      _favorites.add({'id': id, 'name': name, 'imageUrl': imageUrl});
    }

    notifyListeners();
  }

  /// Check if a Pokémon is a favorite
  bool isFavorite(String id) {
    return _favorites.any((pokemon) => pokemon['id'] == id);
  }
}
