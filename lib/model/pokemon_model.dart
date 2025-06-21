class PokemonModel {
  final String name;
  final String url;
  final String index;

  PokemonModel({
    required this.name,
    required this.url,
    this.index = '',
  });

  factory PokemonModel.fromJson(Map<String, dynamic> json) {
    return PokemonModel(
      name: json['name'],
      url: json['url'],
      index: json['url'].split('/')[6], 
    );
  }

  String get id {
    final uri = Uri.parse(url);
    final segments = uri.pathSegments;
    return segments[segments.length - 2];
  }

  String get imageUrl {
    return 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/$id.png';
  }
}
