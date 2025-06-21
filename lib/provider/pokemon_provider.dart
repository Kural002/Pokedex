import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class PokemonProvider extends ChangeNotifier {
  List<Map<String, dynamic>> _pokemonList = [];
  int _offset = 0;
  bool _isLoading = false;

  List<Map<String, dynamic>> get pokemonList => _pokemonList;
  bool get isLoading => _isLoading;

  String get baseUrl =>
      'https://pokeapi.co/api/v2/pokemon?offset=$_offset&limit=20';

  PokemonProvider() {
    fetchPokemon();
  }

  Future<void> fetchPokemon() async {
    if (_isLoading) return;
    _isLoading = true;
    notifyListeners();

    try {
      final response = await http.get(Uri.parse(baseUrl));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final newPokemon = (data['results'] as List).map((pokemon) {
          return {
            'name': pokemon['name'],
            'index': pokemon['url'].split('/')[6],
            'url': pokemon['url'],
          };
        }).toList();

        _pokemonList.addAll(newPokemon);
        _offset += 20;
      } else {
        throw Exception('Failed to load Pokémon');
      }
    } catch (e) {
      print('Error fetching Pokémon: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> refreshPokemon() async {
    _pokemonList.clear();
    _offset = 0;
    await fetchPokemon();
  }
}
