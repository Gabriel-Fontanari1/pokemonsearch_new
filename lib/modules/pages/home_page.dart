import 'package:flutter/material.dart';
import 'pokemon_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _searchController = TextEditingController();
  final PokemonService _pokemonService = PokemonService();
  List<Map<String, dynamic>> _pokemonList = [];
  Map<String, dynamic>? _pokemonData;

  Future<void> _searchPokemon() async {
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) {
      final list = await _pokemonService.fetchPokemonList();
      setState(() {
        _pokemonList = list;
        _pokemonData = null;
      });
    } else {
      final data = await _pokemonService.fetchPokemon(query);
      if (data == null) {
        _showErrorDialog(
            'Pokémon não encontrado. Verifique o nome ou ID e tente novamente.');
      } else {
        setState(() {
          _pokemonData = {
            'name': data['name'],
            'id': data['id'],
            'image': data['sprites']?['versions']?['generation-v']
                    ?['black-white']?['animated']?['front_default'] ??
                data['sprites']?['other']?['official-artwork']
                    ?['front_default'],
            'type': data['types']
                ?.map((type) => type['type']['name'])
                .toList()
                .join(', '),
            'moves': data['moves']
                ?.take(3)
                .map((move) => move['move']['name'])
                .toList()
                .join(', '),
          };
          _pokemonList = [];
        });
      }
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Erro'),
          content: Text(message),
          actions: [
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pokemon Search'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: 'Digite o nome ou ID do Pokemon',
              ),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _searchPokemon,
              child: const Text('Pesquisar'),
            ),
            const SizedBox(height: 16.0),
            _pokemonData != null
                ? Card(
                    margin: const EdgeInsets.symmetric(vertical: 10.0),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.network(
                            _pokemonData!['image'].toString(),
                            width: 120,
                            height: 120,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            _pokemonData!['name'].toString().toUpperCase(),
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text('ID: ${_pokemonData!['id']}'),
                          const SizedBox(height: 5),
                          Text('Type: ${_pokemonData!['type']}'),
                          const SizedBox(height: 5),
                          Text(
                            'Moves: ${_pokemonData!['moves']}',
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  )
                : _pokemonList.isEmpty
                    ? const Center()
                    : Expanded(
                        child: GridView.builder(
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 16.0,
                            crossAxisSpacing: 16.0,
                            childAspectRatio: 0.6,
                          ),
                          itemCount: _pokemonList.length,
                          itemBuilder: (context, index) {
                            final pokemon = _pokemonList[index];
                            return Card(
                              margin: const EdgeInsets.symmetric(vertical: 8.0),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Image.network(
                                      pokemon['image'],
                                      width: 120,
                                      height: 120,
                                    ),
                                    const SizedBox(height: 8.0),
                                    Text(
                                      pokemon['name'].toUpperCase(),
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 4.0),
                                    Text('ID: ${pokemon['id']}'),
                                    const SizedBox(height: 4.0),
                                    Text('Type: ${pokemon['type']}'),
                                    const SizedBox(height: 4.0),
                                    Expanded(
                                      child: Text(
                                        'Moves: ${pokemon['moves']}',
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(fontSize: 12),
                                        overflow: TextOverflow.visible,
                                        maxLines: 2,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
          ],
        ),
      ),
    );
  }
}
