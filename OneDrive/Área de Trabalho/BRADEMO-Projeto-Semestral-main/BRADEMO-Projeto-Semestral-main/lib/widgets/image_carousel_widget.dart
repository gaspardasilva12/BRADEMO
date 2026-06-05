import 'dart:async';
import 'package:flutter/material.dart';

class ImageCarousel extends StatefulWidget {
  final List<String> images;
  final Duration interval;

  const ImageCarousel({
    super.key,
    required this.images,
    this.interval = const Duration(seconds: 3),
  });

  @override
  State<ImageCarousel> createState() => _ImageCarouselState();
}

class _ImageCarouselState extends State<ImageCarousel> {
  int currentIndex = 0;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(widget.interval, (timer) {
      setState(() {
        currentIndex = (currentIndex + 1) % widget.images.length;
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: double.infinity,
      child: Image.asset(
        widget.images[currentIndex],
        fit: BoxFit.cover,
      ),
    );
  }
}
