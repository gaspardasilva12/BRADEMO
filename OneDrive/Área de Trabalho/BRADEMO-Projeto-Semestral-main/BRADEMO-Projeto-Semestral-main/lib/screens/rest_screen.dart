import 'package:flutter/material.dart';
import '../widgets/image_carousel_widget.dart';
import 'home_screen.dart';

class RestScreen extends StatelessWidget {
  const RestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 700;
          final cardPadding = isWide ? 30.0 : 20.0;
          final cardMargin = isWide ? 30.0 : 20.0;
          final titleSize = isWide ? 28.0 : 22.0;
          final bodySize = isWide ? 18.0 : 16.0;
          return Stack(
            children: [
              ImageCarousel(
                images: [
                  'assets/images/ifsp_1.jpg',
                  'assets/images/ifsp_2.jpeg',
                  'assets/images/ifsp_3.jpeg',
                ],
                interval: const Duration(seconds: 3),
              ),
              Container(color: Colors.black.withValues(alpha: 0.3)),

              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(
                    bottom: 20,
                    left: 20,
                    right: 20,
                  ),
                  child: Container(
                    margin: EdgeInsets.all(cardMargin),
                    padding: EdgeInsets.all(cardPadding),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Sistema de Gestão de Equipamentos',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: titleSize,
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onPrimary,
                          ),
                        ),

                        SizedBox(height: isWide ? 16 : 10),

                        Text(
                          'Gerencie e monitore os equipamentos das salas do IFSP Bragança Paulista.\n\nSolicite chamados de reparos e acompanhe em tempo real.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: bodySize,
                          ),
                        ),

                        SizedBox(height: isWide ? 24 : 20),
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: theme.colorScheme.primary,
                          ),
                          child: IconButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const HomeScreen(),
                                ),
                              );
                            },
                            icon: const Icon(Icons.arrow_forward),
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
