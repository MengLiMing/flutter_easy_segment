part of flutter_easy_segment;

/// 只提供文字样式 - 可以参照 自定义其他效果
class CustomSegmentText extends StatefulWidget {
  final TextStyle normalStyle;

  /// null时取normalStyle
  final TextStyle? selectedStyle;

  final String content;

  final double? height;
  final double? width;

  final EdgeInsetsGeometry? padding;

  final Duration duration;

  final Curve curve;

  const CustomSegmentText({
    Key? key,
    required this.content,
    required this.normalStyle,
    this.selectedStyle,
    this.height,
    this.width,
    this.padding,
    this.duration = const Duration(milliseconds: 300),
    this.curve = Curves.easeInOut,
  }) : super(key: key);

  @override
  State<CustomSegmentText> createState() => _CustomSegmentTextState();
}

class _CustomSegmentTextState extends State<CustomSegmentText>
    with EasySegmentControllerProviderStateMixin {
  @override
  void didUpdateWidget(covariant CustomSegmentText oldWidget) {
    if (oldWidget.content != widget.content ||
        oldWidget.height != widget.height ||
        oldWidget.width != widget.width ||
        oldWidget.padding != widget.padding) {
      controller?.markNeedUpdateAfterLayout();
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: widget.padding,
      alignment: Alignment.center,
      height: widget.height,
      width: widget.width,
      child: EasySegmentGeneralItem(
        tween: TextStyleTween(
          begin: widget.normalStyle,
          end: widget.selectedStyle,
        ),
        duration: widget.duration,
        curve: widget.curve,
        builder: (context, value, _) {
          return Text(
            widget.content,
            style: value,
          );
        },
      ),
    );
  }
}
