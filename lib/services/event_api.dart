import 'dart:convert';
import 'package:http/http.dart' as http;

class EventAPI {
  static const String _baseUrl = 'https://app.ticketmaster.com/discovery/v2/events.json';
  static const String _apiKey = 'PU6Pvo815Z5wIDNmBiRChX8EXyEVyZV4'; // sua chave aqui

  static Future<List<Map<String, dynamic>>> fetchEvents() async {
    final uri = Uri.parse('$_baseUrl?countryCode=BR&apikey=$_apiKey');
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      if (data['_embedded'] != null && data['_embedded']['events'] != null) {
        final List events = data['_embedded']['events'];

        return events.map<Map<String, dynamic>>((e) {
          return {
            'title': e['name'] ?? 'Evento sem nome',
            'date': e['dates']?['start']?['localDate'] ?? 'Data não disponível',
            'location': e['_embedded']?['venues']?[0]?['city']?['name'] ?? 'Local desconhecido',
            'image': e['images'] != null && e['images'].isNotEmpty
                ? e['images'][0]['url']
                : 'https://via.placeholder.com/800x400.png?text=Sem+imagem',
            'url': e['url'] ?? '',
          };
        }).toList();
      } else {
        return [];
      }
    } else {
      throw Exception('Erro ao buscar eventos (${response.statusCode})');
    }
  }
}
