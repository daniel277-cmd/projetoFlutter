import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import '../services/event_api.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';

class EventosScreen extends StatefulWidget {
  const EventosScreen({super.key});

  @override
  State<EventosScreen> createState() => _EventosScreenState();
}

class _EventosScreenState extends State<EventosScreen> {
  late Future<List<Map<String, dynamic>>> _futureEvents;


@override
void initState() {
  super.initState();
  // Força locale antes de formatar datas
  Intl.defaultLocale = 'pt_BR';
  _futureEvents = EventAPI.fetchEvents();
}


  Future<void> _launchURL(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      throw 'Não foi possível abrir $url';
    }
  }

 String _formatDate(String? dateStr) {
  if (dateStr == null || dateStr.isEmpty) return "Data não informada";
  try {
    // Converte a string da API para DateTime
    final date = DateTime.parse(dateStr);

    // Garante que o locale está em pt_BR e formata a data
    return DateFormat("d 'de' MMMM 'de' yyyy", 'pt_BR').format(date);
  } catch (e) {
    return dateStr; // se falhar, mostra a string original
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
  backgroundColor: Colors.transparent,
  elevation: 0,
  flexibleSpace: Container(
    decoration: const BoxDecoration(
      gradient: LinearGradient(
        colors: [Color(0xFFE50914), Color(0xFFB0060F)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    ),
  ),
  title: Text.rich(
    TextSpan(
      text: '🎤 ',
      style: const TextStyle(fontSize: 22),
      children: [
        TextSpan(
          text: 'Shows ',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        TextSpan(
          text: 'ao Vivo',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ],
    ),
  ),
  centerTitle: true,
  actions: [
    IconButton(
      icon: const Icon(Icons.favorite_border, color: Colors.white),
      onPressed: () {
        Get.snackbar(
          'Favoritos',
          'Em breve você poderá salvar seus shows favoritos!',
          snackPosition: SnackPosition.BOTTOM,
        );
      },
    ),
    IconButton(
      icon: const Icon(Icons.search, color: Colors.white),
      onPressed: () {
        Get.snackbar(
          'Buscar eventos',
          'Em breve você poderá pesquisar por artista, cidade ou data!',
          snackPosition: SnackPosition.BOTTOM,
        );
      },
    ),
  ],
),

      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _futureEvents,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.redAccent),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                'Erro ao carregar eventos:\n${snapshot.error}',
                style: const TextStyle(color: Colors.white),
                textAlign: TextAlign.center,
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                'Nenhum evento encontrado no momento 😢',
                style: TextStyle(color: Colors.white70),
              ),
            );
          }

          final events = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: events.length,
            itemBuilder: (context, index) {
              final e = events[index];
              final date = _formatDate(e['date']);
              final location = e['location'] ?? 'Local não informado';

              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.redAccent.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (e['image'] != null && e['image']!.isNotEmpty)
                      ClipRRect(
                        borderRadius:
                            const BorderRadius.vertical(top: Radius.circular(16)),
                        child: Image.network(
                          e['image']!,
                          height: 180,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            e['title']!,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '$date • $location',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 10),
                          ElevatedButton(
                            onPressed: () => _launchURL(e['ticketUrl']),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.redAccent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            child: const Text(
                              'Comprar Ingresso 🎟️',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
