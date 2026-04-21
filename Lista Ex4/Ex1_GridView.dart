import 'package:flutter/material.dart';

void main() {
  runApp(const MeuApp());
}

class MeuApp extends StatelessWidget {
  const MeuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Grade de Locais',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
        useMaterial3: true,
      ),
      home: const PaginaGradeLocais(),
    );
  }
}

class ItemLocal {
  final String titulo;
  final String subtitulo;
  final String imageUrl;

  const ItemLocal({
    required this.titulo,
    required this.subtitulo,
    required this.imageUrl,
  });
}

class PaginaGradeLocais extends StatelessWidget {
  const PaginaGradeLocais({super.key});

  static const List<ItemLocal> locais = [
    ItemLocal(
      titulo: 'Comida',
      subtitulo: 'Molho ao Peixe',
      imageUrl:
          'https://images.unsplash.com/photo-1596797038530-2c107229654b?w=600&q=80',
    ),
    ItemLocal(
      titulo: 'Turquia',
      subtitulo: 'Artesanato em Bronze',
      imageUrl:
          'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=600&q=80',
    ),
    ItemLocal(
      titulo: 'Mercado',
      subtitulo: 'Legumes',
      imageUrl:
          'https://images.unsplash.com/photo-1542838132-92c53300491e?w=600&q=80',
    ),
    ItemLocal(
      titulo: 'India',
      subtitulo: 'Templo de Thanjavur',
      imageUrl:
          'https://images.unsplash.com/photo-1582510003544-4d00b7f74220?w=600&q=80',
    ),
    ItemLocal(
      titulo: 'India',
      subtitulo: 'Templo de Thanjavur',
      imageUrl:
          'https://images.unsplash.com/photo-1544735716-392fe2489ffa?w=600&q=80',
    ),
    ItemLocal(
      titulo: 'Irlanda',
      subtitulo: 'Neve',
      imageUrl:
          'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=600&q=80',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Explorar Lugares',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
        child: GridView.builder(
          itemCount: locais.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 0.9,
          ),
          itemBuilder: (context, index) {
            return CartaoLocal(item: locais[index]);
          },
        ),
      ),
    );
  }
}

class CartaoLocal extends StatelessWidget {
  final ItemLocal item;

  const CartaoLocal({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.network(
            item.imageUrl,
            fit: BoxFit.cover,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Container(
                color: Colors.grey[200],
                child: const Center(
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              );
            },
            errorBuilder: (context, error, stackTrace) {
              return Container(
                color: Colors.grey[300],
                child: const Icon(
                  Icons.broken_image,
                  size: 40,
                  color: Colors.grey,
                ),
              );
            },
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 80,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [Color(0xCC000000), Colors.transparent],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 10,
            left: 10,
            right: 10,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  item.titulo,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    height: 1.2,
                  ),
                ),
                Text(
                  item.subtitulo,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
