import 'package:flutter/material.dart';
import 'package:images_swiper/images_swiper.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter iMessage Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final maxCount = 5;
  late final _pageController = PageController(initialPage: 1);

  @override
  void initState() {
    super.initState();
    _pageController.addListener(() {
      //
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('iMessage')),
      body: Column(
        children: [
          // ImagesSwiper(
          //   images: [
          //     "assets/1.jpg",
          //     "assets/2.jpg",
          //     "assets/3.jpg",
          //     "assets/4.jpg",
          //     "assets/5.jpg",
          //   ],
          // ),
          ImagesSwiper.builder(
            imageCount: maxCount,
            alignment: Alignment.center,
            pageController: _pageController,
            imageBuilder: (context, index) => "assets/${index + 1}.jpg",
          ),
          const SizedBox(height: 50),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(onPressed: _onPrevious,
                  child: const Text('⬅️',
                      style: TextStyle(fontSize: 30))),
              const SizedBox(width: 50),
              TextButton(onPressed: _onNext,
                  child: const Text('➡️',
                      style: TextStyle(fontSize: 30))),
            ],
          )
        ],
      )
    );
  }

  _onPrevious() {
    _pageController.previousPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOutQuad);
  }

  _onNext() {
    _pageController.nextPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOutQuad);
  }
}
