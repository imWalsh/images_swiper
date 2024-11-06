// import 'package:dismissible_page/dismissible_page.dart';
import 'package:flutter/material.dart';

class GalleryPage extends StatelessWidget {

  final List<String> items;
  final int current;

  const GalleryPage({super.key,
    required this.items,
    required this.current});

  List<String> get _list => items.reversed.toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        // actions: [
        //   TextButton(onPressed: () {}, child: const Text("选择"))
        // ],
      ),
      body: GridView.builder(
          itemCount: _list.length,
          padding: const EdgeInsets.all(15),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              childAspectRatio: 1.0,
              crossAxisCount: 2,
              mainAxisSpacing: 15.0,
              crossAxisSpacing: 20.0),
          itemBuilder: (context, index) {
            return HeroMode(
              enabled: current == index,
              child: Hero(
                  tag: _list[index],
                  child: GestureDetector(
                    // onTap: () => context.pushTransparentRoute(PreviewPage(index: index)),
                    child: Center(
                      child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.asset(_list[index])
                      ),
                    ),
                  )
              ),
            );
          }),
    );
  }
}