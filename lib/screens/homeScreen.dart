import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../services/event_api.dart';
import 'eventosScreen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  List<Map<String, dynamic>> _events = [];
  bool _isLoading = true;
  int _currentIndex = 0;
  bool _animate = false;

  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    try {
      final events = await EventAPI.fetchEvents();
      setState(() {
        _events = events;
        _isLoading = false;
      });

      // Pequeno delay para a animação iniciar suave
      Future.delayed(const Duration(milliseconds: 200), () {
        setState(() => _animate = true);
        _controller.forward();
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao carregar eventos: $e')),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final proximos = _events.take(3).toList();

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
      text: '🎵 ',
      style: const TextStyle(fontSize: 22),
      children: [
        TextSpan(
          text: 'Descubra ',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        TextSpan(
          text: 'Eventos',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ],
    ),
  ),
  centerTitle: true,
  actions: [
    IconButton(
      icon: const Icon(Icons.search, color: Colors.white),
      onPressed: () {
        Get.snackbar('Pesquisar', 'Em breve você poderá buscar eventos!',
            snackPosition: SnackPosition.BOTTOM);
      },
    ),
    IconButton(
      icon: const Icon(Icons.notifications_none, color: Colors.white),
      onPressed: () {
        Get.snackbar('Notificações', 'Nenhuma nova notificação por enquanto!',
            snackPosition: SnackPosition.BOTTOM);
      },
    ),
  ],
),

      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.redAccent))
          : _events.isEmpty
              ? const Center(
                  child: Text(
                    'Nenhum evento encontrado 😕',
                    style: TextStyle(color: Colors.white),
                  ),
                )
              : SingleChildScrollView(
                  child: AnimatedOpacity(
                    opacity: _animate ? 1 : 0,
                    duration: const Duration(milliseconds: 700),
                    child: AnimatedSlide(
                      offset: _animate ? Offset.zero : const Offset(0, 0.1),
                      duration: const Duration(milliseconds: 700),
                      curve: Curves.easeOut,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 🎠 Carrossel de destaques
                            CarouselSlider.builder(
                              itemCount: _events.length < 5 ? _events.length : 5,
                              itemBuilder: (context, index, realIndex) {
                                final event = _events[index];
                                return GestureDetector(
                                  onTap: () => Get.to(() => const EventosScreen()),
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(horizontal: 4),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(16),
                                      image: DecorationImage(
                                        image: NetworkImage(event['image']),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(16),
                                        gradient: LinearGradient(
                                          colors: [
                                            Colors.black.withOpacity(0.7),
                                            Colors.transparent
                                          ],
                                          begin: Alignment.bottomCenter,
                                          end: Alignment.topCenter,
                                        ),
                                      ),
                                      padding: const EdgeInsets.all(16),
                                      alignment: Alignment.bottomLeft,
                                      child: Text(
                                        event['title'],
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                              options: CarouselOptions(
                                height: 200,
                                autoPlay: true,
                                enlargeCenterPage: true,
                                viewportFraction: 0.9,
                                aspectRatio: 16 / 9,
                                autoPlayInterval: const Duration(seconds: 4),
                                autoPlayAnimationDuration:
                                    const Duration(milliseconds: 800),
                                onPageChanged: (index, reason) {
                                  setState(() => _currentIndex = index);
                                },
                              ),
                            ),

                            const SizedBox(height: 10),
                            // Pontinhos do carrossel
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(
                                _events.length < 5 ? _events.length : 5,
                                (index) => Container(
                                  width: 8,
                                  height: 8,
                                  margin: const EdgeInsets.symmetric(horizontal: 4),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: _currentIndex == index
                                        ? Colors.redAccent
                                        : Colors.white24,
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 25),
                            const Text(
                              '🎤 Shows em destaque',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 10),

                            // Lista horizontal de shows
                            AnimatedOpacity(
                              opacity: _animate ? 1 : 0,
                              duration: const Duration(milliseconds: 700),
                              child: AnimatedSlide(
                                offset: _animate ? Offset.zero : const Offset(0, 0.1),
                                duration: const Duration(milliseconds: 700),
                                curve: Curves.easeOut,
                                child: SizedBox(
                                  height: 180,
                                  child: ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    itemCount:
                                        _events.length < 5 ? _events.length : 5,
                                    itemBuilder: (context, index) {
                                      final event = _events[index];
                                      return GestureDetector(
                                        onTap: () =>
                                            Get.to(() => const EventosScreen()),
                                        child: Container(
                                          width: 160,
                                          margin:
                                              const EdgeInsets.only(right: 12),
                                          decoration: BoxDecoration(
                                            color: Colors.grey[900],
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            image: DecorationImage(
                                              image:
                                                  NetworkImage(event['image']),
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                          alignment: Alignment.bottomLeft,
                                          padding: const EdgeInsets.all(8),
                                          child: Text(
                                            event['title'],
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 25),
                            const Text(
                              '🗓️ Próximos eventos',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 10),

                            // Lista vertical de próximos eventos
                            Column(
                              children: proximos.map((e) {
                                return Card(
                                  color: Colors.grey[900],
                                  margin:
                                      const EdgeInsets.symmetric(vertical: 8),
                                  child: ListTile(
                                    leading: ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.network(
                                        e['image'],
                                        width: 50,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    title: Text(
                                      e['title'],
                                      style: const TextStyle(color: Colors.white),
                                    ),
                                    subtitle: Text(
                                      '${e['date']} • ${e['location']}',
                                      style:
                                          const TextStyle(color: Colors.white70),
                                    ),
                                    trailing: const Icon(Icons.chevron_right,
                                        color: Colors.white),
                                    onTap: () =>
                                        Get.to(() => const EventosScreen()),
                                  ),
                                );
                              }).toList(),
                            ),

                            const SizedBox(height: 20),
                            Center(
                              child: ElevatedButton.icon(
                                onPressed: () => Get.to(() => const EventosScreen()),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.redAccent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 24,
                                    vertical: 12,
                                  ),
                                ),
                                icon: const Icon(Icons.event),
                                label: const Text(
                                  'Ver todos os eventos',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
    );
  }
}
