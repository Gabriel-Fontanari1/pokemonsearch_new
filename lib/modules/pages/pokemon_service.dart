import 'dart:convert';
import 'package:http/http.dart' as http;

class PokemonService {
  final String _baseUrl = 'https://pokeapi.co/api/v2/pokemon';

  //função para buscar o pokemon especificado
  Future<Map<String, dynamic>?> fetchPokemon(String query) async {
    //faz a requisição
    final response = await http.get(Uri.parse('$_baseUrl/$query'));
    //200 = resposta bem sucedida, 404 = recurso não encontrado, 500 = erro interno
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      return null; //se falhar
    }
  }

  //buscar a lista de pokemons, se a textbox estiver vazia
  Future<List<Map<String, dynamic>>> fetchPokemonList() async {
    final response = await http.get(Uri.parse('$_baseUrl?limit=20'));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List<Map<String, dynamic>> pokemonList = [];

      //em cada resultado, faz a requisição e pega os dados
      for (var result in data['results']) {
        final pokemonResponse = await http.get(Uri.parse(result['url']));
        //se for bem sucedido adiciona a pkelist
        if (pokemonResponse.statusCode == 200) {
          final pokemonData = jsonDecode(pokemonResponse.body);
          pokemonList.add({
            //formata os dados
            'name': pokemonData['name'],
            'id': pokemonData['id'],
            'image': pokemonData['sprites']?['versions']?['generation-v']
                    ?['black-white']?['animated']?['front_default'] ??
                pokemonData['sprites']?['other']?['official-artwork']
                    ?['front_default'] ??
                '',
            'type': pokemonData['types']
                ?.map((type) => type['type']['name'])
                .toList()
                .join(', '),
            'moves': pokemonData['moves']
                ?.take(3)
                .map((move) => move['move']['name'])
                .toList()
                .join(', '),
          });
        }
      }
      return pokemonList; //retorna a lista
    } else {
      return []; //se falhar, retorna a lista vazia.
    }
  }
}
