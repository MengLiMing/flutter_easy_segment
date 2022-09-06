import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_easy_segment/flutter_easy_segment.dart';

class MaskSegment extends StatefulWidget {
  const MaskSegment({Key? key}) : super(key: key);

  @override
  State<MaskSegment> createState() => _MaskSegmentState();
}

class _MaskSegmentState extends State<MaskSegment> {
  EasySegmentController segmentController = EasySegmentController();
  EasySegmentController maskSegmentController = EasySegmentController();
  PageController pageController = PageController();
  ScrollController scrollController = ScrollController();

  final ValueNotifier<Rect?> clipRect = ValueNotifier(null);

  List<String> get titles => [
        '全部商品',
        '个人护理',
        '饮料',
        '沐浴洗护',
        '厨房用具',
        '休闲食品',
        '生鲜水果',
        '酒水',
        '家庭清洁',
      ];

  @override
  void initState() {
    super.initState();
    pageController.addListener(() {
      segmentController.changeProgress(pageController.page ?? 0);
      maskSegmentController.changeProgress(pageController.page ?? 0);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _segment(),
        Expanded(
          child: _pageView(),
        ),
      ],
    );
  }

  Widget _pageView() {
    return PageView(
      controller: pageController,
      children: titles
          .map(
            (e) => Container(
              alignment: Alignment.center,
              child: Text(
                e,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _maskSegment() {
    return IgnorePointer(
      child: ValueListenableBuilder<Rect?>(
        valueListenable: clipRect,
        builder: (context, value, child) {
          if (value == null) return Container();
          return ClipRect(
            clipper: MaskClip(rect: value),
            child: child!,
          );
        },
        child: EasySegment(
          space: 0,
          controller: maskSegmentController,
          children: segmentItems(Colors.white),
        ),
      ),
    );
  }

  List<Widget> segmentItems(Color color) {
    return titles
        .map(
          (e) => CustomSegmentText(
            padding: const EdgeInsets.symmetric(horizontal: 5),
            height: 40,
            content: e,
            normalStyle: TextStyle(
              color: color,
            ),
          ),
        )
        .toList();
  }

  Widget _segment() {
    return EasySegment(
      space: 0,
      controller: segmentController,
      onTap: (index) {
        pageController.jumpToPage(index);
      },
      indicators: [
        CustomSegmentLineIndicator(
          color: Colors.blue,
          height: 25,
          layoutChanged: (rendObject) {
            final parentData = rendObject.parentData as StackParentData;
            final rect = parentData.offset &
                Size(parentData.width ?? 0, parentData.height ?? 0);
            clipRect.value = rect;
          },
        ),
      ],
      foreground: _maskSegment(),
      children: segmentItems(Colors.black),
    );
  }
}

class MaskClip extends CustomClipper<Rect> {
  final Rect rect;

  const MaskClip({required this.rect});

  @override
  Rect getClip(Size size) {
    return rect;
  }

  @override
  bool shouldReclip(covariant MaskClip oldClipper) {
    return oldClipper.rect != rect;
  }
}
