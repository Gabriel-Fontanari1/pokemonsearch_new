import 'package:flutter/material.dart';
import 'pokemon_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  //controlador para o campo de busca
  final TextEditingController _searchController = TextEditingController();
  //sistema de busca
  final PokemonService _pokemonService = PokemonService();
  //lista para armazenar os dados dos pokemons
  List<Map<String, dynamic>> _pokemonList = [];
  Map<String, dynamic>? _pokemonData;

  Future<void> _searchPokemon() async {
    final query = _searchController.text.trim().toLowerCase();
    //se a textbox estiver vazia, busca a lista dos 20 primeiros pokemons
    if (query.isEmpty) {
      final list = await _pokemonService.fetchPokemonList();
      setState(() {
        _pokemonList = list;
        _pokemonData = null; //não vai ser exibido um poke especifico
      });
    } else {
      final data = await _pokemonService.fetchPokemon(query);
      if (data == null) {
        _showErrorDialog(
            'Pokémon não encontrado. Verifique o nome ou ID e tente novamente.');
      } else {
        setState(() {
          //busca especifica
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
          _pokemonList = []; //limpa a lista para exibir o pokemon especifico
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
            //campo para a entrada do id ou nome
            TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: 'Digite o nome ou ID do Pokemon',
              ),
            ),
            const SizedBox(height: 16.0),
            //botão para pesquisar
            ElevatedButton(
              onPressed: _searchPokemon,
              child: const Text('Pesquisar'),
            ),
            const SizedBox(height: 16.0),
            //card para mostrar os dados do pokemon encontrado
            _pokemonData != null
                ? Card(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.network(
                          _pokemonData!['image'].toString(),
                          width: 100,
                          height: 100,
                        ),
                        Text(
                          _pokemonData!['name'].toString().toUpperCase(),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text('ID: ${_pokemonData!['id']}'),
                        Text('Type: ${_pokemonData!['type']}'),
                        Text('Moves: ${_pokemonData!['moves']}'),
                      ],
                    ),
                  )
                //se não for encontrado um especifoc, exibe a lista de pokemons
                : _pokemonList.isEmpty
                    ? const Center()
                    : Expanded(
                        child: GridView.builder(
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 5,
                            mainAxisSpacing: 8.0,
                            crossAxisSpacing: 8.0,
                          ),
                          itemCount: _pokemonList.length,
                          itemBuilder: (context, index) {
                            //recebe o pokemon e retorna um card
                            final pokemon = _pokemonList[index];
                            return Card(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image.network(
                                    pokemon['image'],
                                    width: 100,
                                    height: 100,
                                  ),
                                  Text(
                                    pokemon['name'].toUpperCase(),
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text('ID: ${pokemon['id']}'),
                                  Text('Type: ${pokemon['type']}'),
                                  Text('Moves: ${pokemon['moves']}'),
                                ],
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
