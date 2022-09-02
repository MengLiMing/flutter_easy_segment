import 'package:flutter/material.dart';
import 'package:flutter_easy_segment/flutter_easy_segment.dart';

class PageSegment extends StatefulWidget {
  const PageSegment({Key? key}) : super(key: key);

  @override
  State<PageSegment> createState() => _PageSegmentState();
}

class _PageSegmentState extends State<PageSegment> {
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
      space: 10,
      padding: const EdgeInsets.only(left: 15, right: 15),
      onTap: (index) {
        pageController.jumpToPage(index);
      },
      indicators: const [
        /// 固定宽度无动画
        CustomSegmentLineIndicator(
          color: Colors.blue,
          width: 50,
          bottom: 2,
          height: 3,
          animation: false,
        ),

        /// 固定宽度有动画
        CustomSegmentLineIndicator(
          color: Colors.red,
          width: 6,
          bottom: 7,
          height: 3,
          animation: true,
        ),

        /// 动态宽度(和item保持宽度一致) 有动画
        CustomSegmentLineIndicator(
          color: Colors.yellow,
          top: 0,
          height: 3,
          animation: true,
        ),

        /// 动态宽度(和item保持宽度一致) 无动画
        CustomSegmentLineIndicator(
          color: Colors.green,
          top: 5,
          height: 3,
          animation: false,
        ),
      ],
      children: titles
          .map((title) => CustomSegmentText(
                key: ValueKey(title),
                content: title,
                height: 50,
                normalStyle: const TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.normal),
                selectedStyle: const TextStyle(
                  color: Colors.red,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ))
          .toList(),
    );
  }
}
