part of flutter_easy_segment;

/// 只提供文字样式 - 可以参照 自定义其他效果
class CustomSegmentText extends StatefulWidget {
  final TextStyle normalStyle;
  final TextStyle selectedStyle;

  final String content;

  final double height;

  const CustomSegmentText({
    Key? key,
    required this.content,
    required this.normalStyle,
    required this.selectedStyle,
    this.height = 50,
  }) : super(key: key);

  @override
  State<CustomSegmentText> createState() => _CustomSegmentTextState();
}

class _CustomSegmentTextState extends State<CustomSegmentText>
    with
        SingleTickerProviderStateMixin,
        EasySegmentControllerConfig,
        EasySegmentItem {
  late final ValueNotifier<TextStyle> textStyle;

  late final TextStyleTween styleTween;

  @override
  void initState() {
    super.initState();

    textStyle = ValueNotifier(widget.normalStyle);
    styleTween = TextStyleTween(begin: textStyle.value, end: textStyle.value);
  }

  @override
  void animationHandler() {
    textStyle.value = styleTween
        .chain(CurveTween(curve: Curves.easeInOut))
        .evaluate(animationController);
  }

  @override
  Duration get duration => const Duration(milliseconds: 300);

  @override
  void tapChanged() {
    final controller = this.controller;
    if (controller == null) return;

    final oldIndex = controller.oldSelectedIndex;

    if (controller.currentIndex == itemIndex) {
      styleTween.begin = textStyle.value;
      styleTween.end = widget.selectedStyle;
      animationController.forward(from: 0);
    } else if (oldIndex != null && oldIndex == itemIndex) {
      styleTween.begin = textStyle.value;
      styleTween.end = widget.normalStyle;
      animationController.forward(from: 0);
    } else {
      textStyle.value = widget.normalStyle;
    }
  }

  @override
  void scrollChanged() {
    final controller = this.controller;
    if (controller == null) return;

    final startIndex = controller.preIndex;
    final endIndex = controller.nextIndex;

    if (itemIndex == startIndex) {
      final leftProgress = controller.progress - startIndex;
      textStyle.value = TextStyle.lerp(
          widget.selectedStyle, widget.normalStyle, leftProgress)!;
    } else if (itemIndex == endIndex) {
      final rightProgress = controller.progress + 1 - endIndex;
      textStyle.value = TextStyle.lerp(
          widget.normalStyle, widget.selectedStyle, rightProgress)!;
    } else {
      textStyle.value = widget.normalStyle;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      height: widget.height,
      child: ValueListenableBuilder<TextStyle>(
        valueListenable: textStyle,
        builder: (context, style, _) {
          return SizedBox(
            child: Text(
              widget.content,
              style: style,
            ),
          );
        },
      ),
    );
  }
}
