import 'dart:convert';
import 'dart:io' show HttpException;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class PokemonProvider extends ChangeNotifier {
  static const int totalPokemon = 1328;
  static const int pageSize = 50;

  List<Map<String, dynamic>> _pokemonList = [];
  int _offset = 0;
  bool _isLoading = false;
  bool _hasError = false;
  bool _hasMore = true;
  String? _error;

  List<Map<String, dynamic>> get pokemonList => _pokemonList;
  bool get isLoading => _isLoading;
  bool get hasError => _hasError;
  bool get hasMore => _hasMore;
  String? get error => _error;

  String get baseUrl =>
      'https://pokeapi.co/api/v2/pokemon?offset=$_offset&limit=$pageSize';

  PokemonProvider() {
    fetchPokemon();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? error) {
    _hasError = error != null;
    _error = error;
    notifyListeners();
  }

  Future<void> fetchPokemon() async {
    if (_isLoading || !_hasMore) return;
    
    _setLoading(true);
    _setError(null);

    try {
      final response = await http.get(Uri.parse(baseUrl));
      
      if (!response.statusCode.toString().startsWith('2')) {
        throw HttpException('Failed to load Pokémon: ${response.statusCode}');
      }

      final data = jsonDecode(response.body);
      final results = data['results'] as List;
      
      if (results.isEmpty) {
        _hasMore = false;
        _setLoading(false);
        return;
      }

      final newPokemon = results.map((pokemon) {
        final urlParts = pokemon['url'].split('/');
        final id = urlParts[urlParts.length - 2];
        return {
          'name': pokemon['name'],
          'id': id,
          'index': id,
          'url': pokemon['url'],
          'imageUrl': 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/$id.png',
        };
      }).toList();

      _pokemonList.addAll(newPokemon);
      _offset += pageSize;
      _hasMore = _offset < totalPokemon;
      
    } catch (e) {
      _setError('Error loading Pokémon: $e');
      debugPrint('Error fetching Pokémon: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> refreshPokemon() async {
    _pokemonList = [];
    _offset = 0;
    _hasMore = true;
    _setError(null);
    await fetchPokemon();
  }

  Future<void> loadAllPokemon() async {
    if (_isLoading) return;
    
    _setLoading(true);
    _setError(null);

    try {
      final response = await http.get(
        Uri.parse('https://pokeapi.co/api/v2/pokemon?limit=$totalPokemon')
      );
      
      if (!response.statusCode.toString().startsWith('2')) {
        throw HttpException('Failed to load Pokémon: ${response.statusCode}');
      }

      final data = jsonDecode(response.body);
      final results = data['results'] as List;

      _pokemonList = results.map((pokemon) {
        final urlParts = pokemon['url'].split('/');
        final id = urlParts[urlParts.length - 2];
        return {
          'name': pokemon['name'],
          'id': id,
          'index': id,
          'url': pokemon['url'],
          'imageUrl': 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/$id.png',
        };
      }).toList();

      _hasMore = false;
      notifyListeners();
      
    } catch (e) {
      _setError('Error loading all Pokémon: $e');
      debugPrint('Error fetching all Pokémon: $e');
    } finally {
      _setLoading(false);
    }
  }
}
