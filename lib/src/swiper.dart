import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:indexed/indexed.dart';
import 'package:dismissible_page/dismissible_page.dart';

import 'gallery_page.dart';


typedef ImagesSwiperBuilder = String Function(
    BuildContext context, int index);

class ImagesSwiper extends StatefulWidget {
  const ImagesSwiper(
      {super.key,
        required this.images,
        this.pageController,
        this.alignment = Alignment.center})
      : imageBuilder = null,
        imageCount = images?.length ?? 0;

  const ImagesSwiper.builder(
      {super.key,
        required this.imageCount,
        required this.imageBuilder,
        this.alignment = Alignment.center,
        this.pageController})
      : images = null;

  final List<String>? images;
  final int? imageCount;
  final PageController? pageController;
  final ImagesSwiperBuilder? imageBuilder;
  final Alignment alignment;

  @override
  State<ImagesSwiper> createState() => _ChatImagesSwiperState();
}

class _ChatImagesSwiperState extends State<ImagesSwiper> with TickerProviderStateMixin {
  late final _defaultPageController = PageController();

  PageController get _pageController =>
      widget.pageController ?? _defaultPageController;

  List<String> get _items =>
      widget.images ??
          List.generate(widget.imageCount!, (i) => widget.imageBuilder!(context, i));

  bool get _end => widget.alignment.x == 1.0;
  int get _itemsLength => widget.imageCount ?? widget.images!.length;

  late List<_IndexedModel> _models;

  final _showCount = 5;
  double _offsetX = 0.0;
  int _currentPage = 0;
  bool _isLeft = true;

  @override
  void dispose() {
    _models.clear();
    _pageController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _models = _items
        .asMap()
        .entries
        .map((e) => _IndexedModel(
          zIndex: _itemsLength - e.key,
          image: e.value))
        .toList();
    _offsetX = _pageController.initialPage.toDouble();
    _currentPage = _pageController.initialPage;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: _end
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        TextButton(
            onPressed: () {
              context.pushTransparentRoute(GalleryPage(
                  items: _items.reversed.toList(),
                  current: _currentPage));
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.grid_view_rounded, size: 20),
                const SizedBox(width: 5),
                Text('${_items.length}张图片',
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.black87)
                )
              ],
            )
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 300,
          child: _ThroughStack(
            children: <Widget>[
              RepaintBoundary(child: _stackedCards(context)),
              NotificationListener<ScrollNotification>(
                onNotification: _scrollUpdated,
                child: PageView.builder(
                  scrollDirection: Axis.horizontal,
                  controller: _pageController,
                  itemCount: _itemsLength,
                  onPageChanged: (index) {

                  },
                  itemBuilder: (_, __) => const SizedBox.shrink(),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _stackedCards(BuildContext context) {
    return Indexer(
        alignment: Alignment.center,
        fit: StackFit.passthrough,
        children: _buildItems(_models));
  }

  List<Widget> _buildItems(List<_IndexedModel> items) {
    return items.asMap().entries.map(
          (MapEntry<int, _IndexedModel> item) {
        double fraction = _offsetX - item.key;

        final rotation = _calcRotation(item.key, fraction, fraction > 0);

        final scale = _calcScale(item.key, fraction);
        // <------  0.9 ～ 0.1     ｜     -0.1 ～ -0.9  ------>
        const double m = 220.0;
        const double k = 20.0;
        double calcOffset() {
          // 最顶部的卡片
          if (_currentPage == item.key) {
            if (fraction.abs() < .5) {
              item.value.zIndex = _itemsLength + 1;
              if (fraction > 0) {
                final next = items[item.key + 1];
                next.zIndex = _itemsLength - 1;

                if (item.key > 0 && item.key < _itemsLength - 1) {
                  final pre = items[item.key - 1];
                  pre.zIndex = _itemsLength - 2;
                  next.zIndex = _itemsLength - 1;
                }
              }
              if (fraction < 0) {
                final next = items[item.key - 1];
                next.zIndex = _itemsLength - 1;

                if (item.key > 0 && item.key < _itemsLength - 1) {
                  final pre = items[item.key + 1];
                  pre.zIndex = _itemsLength - 2;
                  next.zIndex = _itemsLength - 1;
                }
              }

              return fraction * m;
            } else {
              if (fraction > 0) {
                item.value.zIndex = _itemsLength - 1;
                _decreasing(item.key, true);

                final next = items[item.key + 1];
                next.zIndex = _itemsLength + 1;
                final end = max((m - fraction * m), k);
                return end;
              } else {
                item.value.zIndex = 1;
                _decreasing(item.key, false);

                final next = items[item.key - 1];
                next.zIndex = _itemsLength + 1;
                final end = min(-(m + fraction * m), -k);
                return end;
              }
            }
          } else {
            return (item.key <= _currentPage - _showCount ||
                item.key >= _currentPage + _showCount)
                ? 0.0
                : fraction * k;
          }
        }

        final offset = calcOffset();

        return Indexed(
          index: item.value.zIndex,
          child: Align(
            alignment: widget.alignment,
            child: GestureDetector(
              // onTap: () => context.pushTransparentRoute(PreviewPage()),
              child: HeroMode(
                enabled: _currentPage == item.key,
                child: Hero(
                  tag: item.value.image,
                  child: Container(
                    transformAlignment: Alignment.center,
                    transform: Matrix4.identity()
                      ..translate(-offset)
                      ..scale(scale)
                      ..rotateZ(-rotation),
                    child: AspectRatio(
                      aspectRatio: .8,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.asset(
                            item.value.image,
                            fit: BoxFit.cover),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    ).toList();
  }

  double _calcRotation(int index, double fraction, bool left) {
    const double k = .05;
    final lerp = lerpDouble(1.3, k, fraction.abs()) ?? 0.0;
    double spread = (_currentPage == index) ? lerp : k;
    double rotation = fraction * spread;

    return rotation;
  }

  double _calcScale(int index, double fraction) {
    const double k = .1;
    final lerp = lerpDouble(.7, k, fraction.abs()) ?? k;
    final spread = _currentPage == index ? lerp : k;
    double scale = max(1 - spread * fraction.abs(), 0.0);

    return scale;
  }

  _decreasing(int current, bool left) {
    final list = left
        ? _models.sublist(0, current).reversed.toList()
        : _models.sublist(current, _models.length);

    var z = _itemsLength - current;
    for (int i = 0; i < list.length; i++) {
      list[i].zIndex = z--;
    }
  }

  bool _scrollUpdated(ScrollNotification notification) {
    if (notification.depth == 0 && notification is ScrollUpdateNotification) {
      _offsetX = _pageController.page!;

      if (_isLeft) {
        if (_offsetX.ceil() == 0) {
          _currentPage = 0;
        } else if (_offsetX.truncate() >= _currentPage) {
          _currentPage = _offsetX.truncate();
        }
      } else {
        if (_offsetX <= _currentPage - 1) {
          _currentPage = _offsetX.ceil();
        }
      }

      // 判断滚动方向
      if (notification.scrollDelta != null) {
        _isLeft = notification.scrollDelta! > 0;
      }
    }

    setState(() {});
    return true;
  }
}

class _ThroughStack extends Stack {
  const _ThroughStack({required super.children});

  @override
  _ThroughRenderStack createRenderObject(BuildContext context) {
    return _ThroughRenderStack(
      alignment: alignment,
      textDirection: textDirection ?? Directionality.of(context),
      fit: fit,
    );
  }
}

class _ThroughRenderStack extends RenderStack {
  _ThroughRenderStack({
    required super.alignment,
    super.textDirection,
    required super.fit,
  });

  @override
  bool hitTestChildren(BoxHitTestResult result, {Offset? position}) {
    bool stackHit = false;

    final List<RenderBox> children = getChildrenAsList();

    for (final RenderBox child in children) {
      final StackParentData childParentData =
      child.parentData as StackParentData;

      final bool childHit = result.addWithPaintOffset(
        offset: childParentData.offset,
        position: position!,
        hitTest: (BoxHitTestResult result, Offset transformed) {
          assert(transformed == position - childParentData.offset);
          return child.hitTest(result, position: transformed);
        },
      );

      if (childHit) {
        stackHit = true;
      }
    }

    return stackHit;
  }
}


class _IndexedModel {
  int zIndex;
  final String image;

  _IndexedModel({
    this.zIndex = 0,
    required this.image,
  });
}
