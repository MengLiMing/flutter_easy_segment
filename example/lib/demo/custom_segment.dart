import 'package:flutter/material.dart';
import 'package:flutter_easy_segment/flutter_easy_segment.dart';

class CustomSegment extends StatefulWidget {
  const CustomSegment({Key? key}) : super(key: key);

  @override
  State<CustomSegment> createState() => _CustomSegmentState();
}

class _CustomSegmentState extends State<CustomSegment> {
  EasySegmentController segmentController1 = EasySegmentController();
  EasySegmentController segmentController2 = EasySegmentController();

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
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: SizedBox(
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            segment1(),
            segment2(),
          ],
        ),
      ),
    );
  }

  Widget segment1() {
    return Container(
      height: 40,
      decoration: const BoxDecoration(
          color: Color(0xFFEEEEEE),
          borderRadius: BorderRadius.all(Radius.circular(20))),
      child: EasySegment(
        controller: segmentController1,
        space: 10,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        onTap: (index) {},
        indicators: [
          /// 固定宽度无动画
          CustomSegmentLineIndicator(
            color: Colors.grey.withOpacity(0.4),
            height: 30,
            animation: true,
          ),
        ],
        children: titles
            .sublist(0, 3)
            .map((title) => CustomSegmentText(
                  key: ValueKey(title),
                  content: title,
                  width: 100,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  normalStyle: const TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                  ),
                  selectedStyle: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ))
            .toList(),
      ),
    );
  }

  Widget segment2() {
    return Container(
      width: 300,
      height: 40,
      decoration: const BoxDecoration(
          color: Color(0xFFEEEEEE),
          borderRadius: BorderRadius.all(Radius.circular(20))),
      child: EasySegment(
        controller: segmentController2,
        space: 10,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        onTap: (index) {},
        indicators: [
          /// 固定宽度无动画
          CustomSegmentLineIndicator(
            color: Colors.blue.withOpacity(0.4),
            height: 30,
            animation: true,
          ),
        ],
        children: titles
            .map((title) => CustomSegmentText(
                  key: ValueKey(title),
                  content: title,
                  width: 100,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  normalStyle: const TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                  ),
                  selectedStyle: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ))
            .toList(),
      ),
    );
  }
}
