import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class PokemonProvider extends ChangeNotifier {
  List<Map<String, dynamic>> _pokemonList = [];
  int _offset = 0;
  bool _isLoading = false;

  List<Map<String, dynamic>> get pokemonList => _pokemonList;
  bool get isLoading => _isLoading;

  PokemonProvider() {
    fetchPokemon();
  }

  Future<void> fetchPokemon() async {
    if (_isLoading) return;
    _isLoading = true;
    notifyListeners();

    try {
      final response = await Dio().get('https://pokeapi.co/api/v2/pokemon?offset=$_offset&limit=20');
      final newPokemon = (response.data['results'] as List).map((pokemon) {
        return {
          'name': pokemon['name'],
          'url': pokemon['url'], 
        };
      }).toList();

      _pokemonList.addAll(newPokemon);
      _offset += 20;
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
