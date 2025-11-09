import 'package:cloud_firestore/cloud_firestore.dart' hide Query;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

class FavoritesProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<Map<String, dynamic>> _favorites = [];
  bool _isLoading = false;

  List<Map<String, dynamic>> get favorites => _favorites;
  bool get isLoading => _isLoading;

  Future<void> loadFavorites() async {
    try {
      final user = _auth.currentUser;

      if (user == null) {
        debugPrint('loadFavorites: No user logged in');
        _favorites = [];
        notifyListeners();
        return;
      }

      if (Firebase.apps.isEmpty) {
        debugPrint('loadFavorites: Firebase not initialized yet');
        return;
      }

      if (kIsWeb) {
        await FirebaseFirestore.instance.waitForPendingWrites();
      }

      final snapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('favorites')
          .get();

      _favorites = snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          'name': data['name'] ?? '',
          'imageUrl': data['imageUrl'] ?? '',
        };
      }).toList();

      notifyListeners();
    } catch (e) {
      debugPrint('🔥 Firestore load error: $e');
    }
  }

  Future<void> toggleFavorite(String id, String name, String imageUrl) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        debugPrint('Cannot toggle favorite: User not logged in');
        return;
      }

      final docRef = _firestore
          .collection('users')
          .doc(user.uid)
          .collection('favorites')
          .doc(id);

      final isCurrentlyFavorite = _favorites.any((item) => item['id'] == id);
      final previousFavorites = List<Map<String, dynamic>>.from(_favorites);

      if (isCurrentlyFavorite) {
        _favorites.removeWhere((item) => item['id'] == id);
        notifyListeners();
        await docRef.delete();
      } else {
        _favorites.add({'id': id, 'name': name, 'imageUrl': imageUrl});
        notifyListeners();
        await docRef.set({
          'name': name,
          'imageUrl': imageUrl,
          'timestamp': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      debugPrint('🔥 Error toggling favorite: $e');
      await loadFavorites();
    }
  }

  bool isFavorite(String id) =>
      _favorites.any((pokemon) => pokemon['id'] == id);
}
