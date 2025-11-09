import 'package:flutter/material.dart';
import 'package:pokedex/widget/pokemon_card.dart';
import 'package:pokedex/view/login_screen/login_page.dart';
import 'package:pokedex/view/favorites_screen/favorites_screen.dart';
import 'package:pokedex/provider/favorites_provider.dart';
import 'package:pokedex/provider/pokemon_provider.dart';
import 'package:pokedex/services/auth_services.dart';
import 'package:pokedex/utils/responsive_helper.dart';
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

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchText = _searchController.text.toLowerCase();
      });
    });
  }

  void _searchPokemon() {
    String query = _searchController.text;
    if (query.isNotEmpty) {
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
      drawer: Drawer(
        backgroundColor: Colors.transparent,
        width: ResponsiveHelper.isMobile(context)
            ? MediaQuery.of(context).size.width * 0.7
            : ResponsiveHelper.isTablet(context)
                ? 350
                : 400,
        child: Container(
          color: Colors.white.withOpacity(0.9),
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              Consumer<AuthServices>(
                builder: (context, auth, _) {
                  final user = auth.currentUser;
                  return UserAccountsDrawerHeader(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                    ),
                    currentAccountPicture: CircleAvatar(
                      radius: 28,
                      backgroundColor: Colors.white,
                      child: ClipOval(
                        child: user?.photoURL != null
                            ? Image.network(
                                user!.photoURL!,
                                width: 56,
                                height: 56,
                                fit: BoxFit.cover,
                                loadingBuilder:
                                    (context, child, loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return const SizedBox(
                                    width: 56,
                                    height: 56,
                                    child: Center(
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2),
                                    ),
                                  );
                                },
                                errorBuilder: (context, error, stackTrace) {
                                  // If the avatar request fails (429 or other), show a fallback icon
                                  return const SizedBox(
                                    width: 56,
                                    height: 56,
                                    child: Center(
                                      child: Icon(Icons.person,
                                          size: 36, color: Colors.blue),
                                    ),
                                  );
                                },
                              )
                            : const Icon(Icons.person,
                                size: 40, color: Colors.blue),
                      ),
                    ),
                    accountName: Text(
                      user?.displayName ?? 'Pokemon Trainer',
                      style: const TextStyle(
                        color: Colors.black87,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    accountEmail: Text(
                      user?.email ?? '',
                      style: const TextStyle(
                        color: Colors.black54,
                      ),
                    ),
                  );
                },
              ),
              Consumer<FavoritesProvider>(
                builder: (context, favProvider, _) => ListTile(
                    leading: const Icon(Icons.favorite, color: Colors.red),
                    title: const Text('Favorites'),
                    trailing: Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${favProvider.favorites.length}',
                        style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    onTap: () async {
                      try {
                        await favProvider.loadFavorites();
                        if (!context.mounted) return;

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const FavoritesScreen(),
                          ),
                        );
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Failed to open Favorites: $e'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    }),
              ),
              Consumer<PokemonProvider>(
                builder: (context, pokemonProvider, _) => ListTile(
                  leading:
                      const Icon(Icons.catching_pokemon, color: Colors.blue),
                  title: const Text('Pokémon Collection'),
                  trailing: Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${pokemonProvider.pokemonList.length}/${PokemonProvider.totalPokemon}',
                      style: TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.logout),
                title: const Text('Logout'),
                onTap: () async {
                  final navigator = Navigator.of(context);
                  final auth =
                      Provider.of<AuthServices>(context, listen: false);

                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Confirm logout'),
                      content: const Text('Are you sure you want to log out?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(true),
                          child: const Text('Logout'),
                        ),
                      ],
                    ),
                  );

                  if (confirm == true) {
                    navigator.pop();
                    await auth.signOut();
                    if (!mounted) return;
                    navigator.pushReplacement(
                      MaterialPageRoute(builder: (context) => LoginPage()),
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('PokéDex'),
        backgroundColor: Colors.white,
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.restart_alt_sharp),
            tooltip: 'Load All Pokémon',
            onPressed: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text('Load All Pokémon?'),
                  content: Text(
                      'This will load all ${PokemonProvider.totalPokemon} Pokémon at once. Continue?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: Text('Continue'),
                    ),
                  ],
                ),
              );

              if (confirmed == true) {
                final pokemonProvider =
                    Provider.of<PokemonProvider>(context, listen: false);
                await pokemonProvider.loadAllPokemon();
              }
            },
          ),
        ],
      ),
      body: Center(
        child: Container(
          constraints: BoxConstraints(
            maxWidth: ResponsiveHelper.getMaxContentWidth(context),
          ),
          child: Column(
            children: [
              Padding(
                padding: ResponsiveHelper.getScreenPadding(context),
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
                    if (pokemonProvider.hasMore) {
                      await pokemonProvider.fetchPokemon();
                    }
                    _refreshController.loadComplete();
                  },
                  footer: ClassicFooter(
                    loadStyle: LoadStyle.ShowWhenLoading,
                    completeDuration: const Duration(milliseconds: 500),
                  ),
                  child: filteredPokemonList.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.search_off,
                                  size: 64, color: Colors.grey),
                              const SizedBox(height: 16),
                              Text(
                                pokemonProvider.hasError
                                    ? pokemonProvider.error ??
                                        "Error loading Pokémon"
                                    : "No Pokémon Found!",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: pokemonProvider.hasError
                                      ? Colors.red
                                      : Colors.grey[600],
                                ),
                              ),
                              if (pokemonProvider.hasError)
                                Padding(
                                  padding: const EdgeInsets.only(top: 16),
                                  child: ElevatedButton(
                                    onPressed: () =>
                                        pokemonProvider.refreshPokemon(),
                                    child: Text('Try Again'),
                                  ),
                                ),
                            ],
                          ),
                        )
                      : GridView.builder(
                          padding: ResponsiveHelper.getScreenPadding(context),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount:
                                ResponsiveHelper.getGridCrossAxisCount(context)
                                    .toInt(),
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                            childAspectRatio:
                                ResponsiveHelper.getGridAspectRatio(context),
                          ),
                          itemCount: filteredPokemonList.length,
                          itemBuilder: (context, index) {
                            final pokemon = filteredPokemonList[index];
                            final id = pokemon['url'].split('/')[6];

                            return PokemonCard(
                              name: pokemon['name'],
                              index: id,
                              imageUrl:
                                  "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/$id.png",
                              description: '',
                            );
                          },
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
