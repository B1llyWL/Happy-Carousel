
import 'dart:math';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Счастливая карусель',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const MyHomePage(title: 'Счастливая карусель'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  
  final String title;

  @override
  State<MyHomePage> createState() => MyHomePageState();
}

class MyHomePageState extends State<MyHomePage> {
  List<String> imagePaths = [
    'assets/001.jpg',
    'assets/124.jpg',
    'assets/222.jpg',
    'assets/230.jpg',
    'assets/258.jpg',
    'assets/380.jpg',
    'assets/388.jpg',
    'assets/456.jpg',
  ];

  bool isRotating = false;
  AudioPlayer audioPlayer = AudioPlayer();
  bool isPlaying = false;

  Future<void> playMusic() async {
    await audioPlayer.setSource(AssetSource('sound1.mp3')); // Для Flutter Web можно заменить на UrlSource('assets/sound1.mp3')
    await audioPlayer.resume();
    isPlaying = true;
  }

  Future<void> pauseMusic() async {
    await audioPlayer.pause();
    isPlaying = false;
  }

  Future<void> rotateCarousel() async {
    if (isRotating || imagePaths.length <= 1) return;

    setState(() {
      isRotating = true;
    });

    if (!isPlaying) {
      await playMusic();
    }

    final rotations = Random().nextInt(5) + 5;
    final duration = const Duration(milliseconds: 100);

    for (int i = 0; i < rotations * imagePaths.length; i++) {
      await Future.delayed(duration);
      setState(() {
        final first = imagePaths.removeAt(0);
        imagePaths.add(first);
      });
    }

    if (imagePaths.length > 1) {
      setState(() {
        int removeIndex = Random().nextInt(imagePaths.length - 1) + 1; 
        imagePaths.removeAt(removeIndex);
      });
    }

    if (imagePaths.length == 1) {
      if (!isPlaying) {
        await playMusic();
      }
    } else {
      await pauseMusic();
    }

    setState(() {
      isRotating = false;
    });
  }

  @override
  void dispose() {
    audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16), 
        child: Column(
          children: [
            Flexible(
              child: GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: imagePaths.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,       // 4 столбца, ширина = (доступная ширина - отступы)/4
                  mainAxisSpacing: 12,     // вертикальный отступ между ячейками
                  crossAxisSpacing: 8,    // горизонтальный отступ между ячейками
                  childAspectRatio: 0.7,   // отношение ширины к высоте (ш/в)
                  mainAxisExtent: 280,     // фиксированная высота каждой ячейки
                ),
                itemBuilder: (context, index) {
                  return Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade400),
                    ),
                    clipBehavior: Clip.hardEdge,
                    child: Image.asset(
                      imagePaths[index],
                      fit: BoxFit.contain,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: isRotating ? null : rotateCarousel,
              child: const Text('Запустить карусель'),
            ),
          ],
        ),
      ),
    );
  }
}
