# Images Swiper

[![pub package](https://img.shields.io/pub/v/proximity_screen_lock.svg)](https://pub.dartlang.org/packages/images_swiper)

A simple Flutter Package to Mimic iMessage Image Picker for Flutter

## Features

![](https://github.com/imWalsh/images_swiper/blob/main/images_swiper.gif)

## Getting started

In the `pubspec.yaml` of your flutter project, add the following dependency:

```yaml
dependencies:
  ...
  images_swiper:
```

```dart
import 'package:images_swiper/images_swiper.dart';
```

## Usage

* ImagesSwiper(images: [])
* ImagesSwiper.builder(imageCount: 5, imageBuilder: (context, index) => "")

```dart
ImagesSwiper.builder(
    imageCount: maxCount,
    alignment: Alignment.center,
    pageController: _pageController,
    imageBuilder: (context, index) => "assets/${index + 1}.jpg",
)
```

## License
[MIT](https://choosealicense.com/licenses/mit/)
