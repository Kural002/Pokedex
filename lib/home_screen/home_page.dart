import 'package:flutter/material.dart';
import 'package:pokedex/home_screen/components/pokemon_card.dart';
import 'package:pokedex/login_screen/login_page.dart';
import 'package:pokedex/provider/pokemon_provider.dart';
import 'package:pokedex/services/auth_services.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  final TextEditingController _searchController = TextEditingController();
  String _searchText = "";
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    final pokemonProvider =
        Provider.of<PokemonProvider>(context, listen: false);
    pokemonProvider.fetchPokemon(); 

    _searchController.addListener(() {
      setState(() {
        _searchText = _searchController.text.toLowerCase();
        _isFocused = _focusNode.hasFocus;
      });
    });
  }
   void _searchPokemon() {
    String query = _searchController.text;
    if (query.isNotEmpty) {
      print("Searching for: $query"); 
      FocusScope.of(context).unfocus(); 
      _searchController.clear(); 
    }
  }

  @override
  Widget build(BuildContext context) {
    final pokemonProvider = Provider.of<PokemonProvider>(context);

    
    final filteredPokemonList = pokemonProvider.pokemonList
        .where((pokemon) => pokemon['name'].toLowerCase().contains(_searchText))
        .toList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('PokéDex'),
        backgroundColor: Colors.white,
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () async {
              await AuthServices().signOut();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => LoginPage(),
                ),
              );
            },
            icon: Icon(Icons.logout),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: EdgeInsets.all(10),
            child: GestureDetector(
              onTap: () => _searchPokemon(),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: "Search Pokémon...",
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.grey, width: 2),
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    color: Colors.grey,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: SmartRefresher(
              controller: _refreshController,
              enablePullDown: true,
              enablePullUp: true,
              onRefresh: () async {
                await pokemonProvider.refreshPokemon();
                _refreshController.refreshCompleted();
              },
              onLoading: () async {
                await pokemonProvider.fetchPokemon();
                _refreshController.loadComplete();
              },
              child: filteredPokemonList.isEmpty
                  ? Center(child: Text("No Pokémon Found!"))
                  : GridView.builder(
                      padding: EdgeInsets.all(8),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3, 
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        childAspectRatio: 0.8,
                      ),
                      itemCount: filteredPokemonList.length,
                      itemBuilder: (context, index) {
                        final pokemon = filteredPokemonList[index];
                        final id =
                            pokemon['url'].split('/')[6]; 

                        return PokemonCard(
                          name: pokemon['name'],
                          imageUrl:
                              "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/$id.png",
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
