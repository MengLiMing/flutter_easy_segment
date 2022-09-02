import 'package:flutter/material.dart';
import 'package:flutter_easy_segment/flutter_easy_segment.dart';

class ForegroundBackground extends StatefulWidget {
  const ForegroundBackground({Key? key}) : super(key: key);

  @override
  State<ForegroundBackground> createState() => _ForegroundBackgroundState();
}

class _ForegroundBackgroundState extends State<ForegroundBackground> {
  EasySegmentController segmentController =
      EasySegmentController(initialIndex: 1);

  PageController pageController = PageController(initialPage: 1);

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
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        segment(),
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

  Widget segment() {
    return EasySegment(
      controller: segmentController,
      space: 15,
      padding: const EdgeInsets.only(left: 15, right: 15),
      onTap: (index) {
        pageController.jumpToPage(index);
      },
      indicators: const [
        CustomSegmentLineIndicator(
          color: Colors.yellow,
          bottom: 10,
          height: 6,
          width: 30,
          animation: false,
        ),
      ],
      foregroundIndicators: const [
        CustomSegmentLineIndicator(
          color: Colors.blue,
          top: 10,
          height: 6,
          width: 30,
          animation: false,
          child: Center(
            child: SizedBox(
              width: 3,
              height: 3,
              child: ColoredBox(color: Colors.red),
            ),
          ),
        ),
      ],
      children: titles
          .map((title) => CustomSegmentText(
                key: ValueKey(title),
                content: title,
                height: 40,
                normalStyle: const TextStyle(
                    color: Colors.grey,
                    fontSize: 16,
                    fontWeight: FontWeight.normal),
                selectedStyle: const TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ))
          .toList(),
    );
  }
}
