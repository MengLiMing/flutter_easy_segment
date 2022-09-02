part of flutter_easy_segment;

/// 本来是想提供多种动画，但是~ 起名字太难了，还好自定义很简单-,-，所以我就只实现一种抱砖引玉吧。
class CustomSegmentLineIndicator extends StatefulWidget {
  final double? bottom;
  final double? height;
  final double? top;

  /// 提供宽度 则使用固定宽度计算
  final double? width;

  final bool animation;

  /// 圆角 默认 height/2
  final double? borderRadius;
  final Color? color;

  /// 设置decoration 则borderRadius和color无效
  final BoxDecoration? decoration;

  final Widget? child;

  /// 动画最好大于 item的动画时长，这样指示器切换动画就会更和谐
  final Duration duration;

  final Curve curve;

  const CustomSegmentLineIndicator({
    Key? key,
    this.color,
    this.bottom,
    this.height,
    this.width,
    this.top,
    this.animation = true,
    this.decoration,
    this.borderRadius,
    this.child,
    this.duration = const Duration(milliseconds: 300),
    this.curve = Curves.easeInOut,
  })  : assert(top == null || bottom == null || height == null),
        assert(decoration == null || (borderRadius == null && color == null)),
        super(key: key);

  @override
  State<CustomSegmentLineIndicator> createState() =>
      _CustomSegmentLineIndicatorState();
}

class _CustomSegmentLineIndicatorState extends State<CustomSegmentLineIndicator>
    with
        EasySegmentControllerProviderStateMixin,
        EasySegmentIndicatorStateMixin,
        EasySegmentIndicatorMixin,
        SingleTickerProviderStateMixin {
  late AnimationController animationController;

  final Tween<double> leftTween = Tween(begin: 0, end: 0);
  final Tween<double> widthTween = Tween(begin: 0, end: 0);

  int? oldSelectedIndex;

  @override
  void initState() {
    _configAnimation();

    super.initState();
  }

  @override
  void dispose() {
    animationController.dispose();

    super.dispose();
  }

  void _configAnimation() {
    animationController = AnimationController(
      vsync: this,
      duration: widget.duration,
    )..addListener(animationHandler);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: widget.decoration ??
          BoxDecoration(
            color: widget.color,
            borderRadius: BorderRadius.all(
              Radius.circular(
                  max(0, widget.borderRadius ?? (widget.height ?? 0) / 2)),
            ),
          ),
      child: widget.child,
    );
  }

  @override
  void didUpdateWidget(covariant CustomSegmentLineIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.duration != widget.duration) {
      animationController.dispose();
      _configAnimation();
    }
    if (oldWidget.bottom != widget.bottom ||
        oldWidget.height != widget.height ||
        oldWidget.top != widget.top ||
        oldWidget.width != widget.width) {
      ServicesBinding.instance.addPostFrameCallback((timeStamp) {
        oldSelectedIndex = controller?.currentIndex;
        animationController.value = 1;
      });
    }
  }

  void animationHandler() {
    final oldIndex = oldSelectedIndex;
    final currentData = currentItemLayoutData();
    if (currentData == null) return;

    EasySegmentItemLayoutData? oldData;

    if (oldIndex != null) {
      oldData = itemLayoutData(oldIndex);
    }

    final fixedWidth = widget.width;

    if (oldData == null) {
      EasyIndicatorLayoutConfig config;
      if (fixedWidth != null) {
        config = EasyIndicatorLayoutConfig(
          left: currentData.center.dx - fixedWidth / 2,
          width: fixedWidth,
          bottom: widget.bottom,
          height: widget.height,
          top: widget.top,
        );
      } else {
        config = EasyIndicatorLayoutConfig(
          left: currentData.offset.dx,
          bottom: widget.bottom,
          width: currentData.size.width,
          height: widget.height,
          top: widget.top,
        );
      }
      update(config);
    } else {
      if (fixedWidth != null) {
        leftTween.begin = oldData.center.dx - fixedWidth / 2;
        leftTween.end = currentData.center.dx - fixedWidth / 2;

        widthTween.begin = fixedWidth;
        widthTween.end = fixedWidth;
      } else {
        leftTween.begin = oldData.offset.dx;
        leftTween.end = currentData.offset.dx;

        widthTween.begin = oldData.size.width;
        widthTween.end = currentData.size.width;
      }

      final left = leftTween
          .chain(CurveTween(curve: widget.curve))
          .evaluate(animationController);
      final width = widthTween
          .chain(CurveTween(curve: widget.curve))
          .evaluate(animationController);

      update(EasyIndicatorLayoutConfig(
        left: left,
        width: width,
        bottom: widget.bottom,
        height: widget.height,
        top: widget.top,
      ));
    }
  }

  @override
  void stopChanged() {
    if (animationController.value == 1) {
      animationController.value = 1;
    }
  }

  @override
  void scrollChanged() {
    final leadingData = leadingItemLayoutData();
    final trailingData = trailingItemLayoutData();
    final progress = this.progress();

    if (leadingData == null || trailingData == null || progress == null) return;

    if (widget.width != null) {
      if (widget.animation) {
        fixedWidthAnimation(
          lineWidth: widget.width!,
          leadingData: leadingData,
          trailingData: trailingData,
          progress: progress,
        );
      } else {
        fixedWidth(
          lineWidth: widget.width!,
          leadingData: leadingData,
          trailingData: trailingData,
          progress: progress,
        );
      }
    } else {
      if (widget.animation) {
        dynamicWidthAnimation(
          leadingData: leadingData,
          trailingData: trailingData,
          progress: progress,
        );
      } else {
        dynamicWidth(
          leadingData: leadingData,
          trailingData: trailingData,
          progress: progress,
        );
      }
    }
  }

  @override
  void tapChanged() {
    oldSelectedIndex = controller?.oldSelectedIndex;
    animationController.forward(from: 0);
  }
}

extension on _CustomSegmentLineIndicatorState {
  void fixedWidth({
    required double lineWidth,
    required EasySegmentItemLayoutData leadingData,
    required EasySegmentItemLayoutData trailingData,
    required double progress,
  }) {
    final startLeft = leadingData.center.dx - lineWidth / 2;
    final endLeft = trailingData.center.dx - lineWidth / 2;
    final left = lerpDouble(startLeft, endLeft, progress) ?? 0;
    update(EasyIndicatorLayoutConfig(
      left: left,
      width: lineWidth,
      bottom: widget.bottom,
      height: widget.height,
      top: widget.top,
    ));
  }

  void fixedWidthAnimation({
    required double lineWidth,
    required EasySegmentItemLayoutData leadingData,
    required EasySegmentItemLayoutData trailingData,
    required double progress,
  }) {
    EasyIndicatorLayoutConfig config;
    if (progress < 0.5) {
      final startLeft = leadingData.center.dx - lineWidth / 2;
      final endLeft = leadingData.center.dx;
      final left = lerpDouble(startLeft, endLeft, progress * 2) ?? 0;

      final startWidth = lineWidth;
      final endWidth = trailingData.center.dx - leadingData.center.dx;

      final width = lerpDouble(startWidth, endWidth, progress * 2) ?? 0;

      config = EasyIndicatorLayoutConfig(
        left: left,
        width: width,
        bottom: widget.bottom,
        height: widget.height,
        top: widget.top,
      );
    } else {
      final startLeft = leadingData.center.dx;
      final endLeft = trailingData.center.dx - lineWidth / 2;
      final left = lerpDouble(startLeft, endLeft, (progress - 0.5) * 2) ?? 0;

      final startWidth = trailingData.center.dx - leadingData.center.dx;
      final endWidth = lineWidth;

      final width = lerpDouble(startWidth, endWidth, (progress - 0.5) * 2) ?? 0;

      config = EasyIndicatorLayoutConfig(
        left: left,
        width: width,
        bottom: widget.bottom,
        height: widget.height,
        top: widget.top,
      );
    }
    update(config);
  }

  void dynamicWidth({
    required EasySegmentItemLayoutData leadingData,
    required EasySegmentItemLayoutData trailingData,
    required double progress,
  }) {
    final startLeft = leadingData.offset.dx;
    final endLeft = trailingData.offset.dx;
    final left = lerpDouble(startLeft, endLeft, progress) ?? 0;

    final startWidth = leadingData.size.width;
    final endWidth = trailingData.size.width;

    final width = lerpDouble(startWidth, endWidth, progress) ?? 0;

    update(EasyIndicatorLayoutConfig(
      left: left,
      width: width,
      bottom: widget.bottom,
      height: widget.height,
      top: widget.top,
    ));
  }

  void dynamicWidthAnimation({
    required EasySegmentItemLayoutData leadingData,
    required EasySegmentItemLayoutData trailingData,
    required double progress,
  }) {
    EasyIndicatorLayoutConfig config;
    if (progress < 0.5) {
      final startLeft = leadingData.offset.dx;
      final endLeft = leadingData.center.dx;
      final left = lerpDouble(startLeft, endLeft, progress * 2) ?? 0;

      final startWidth = leadingData.size.width;
      final endWidth = trailingData.center.dx - leadingData.center.dx;
      final width = lerpDouble(startWidth, endWidth, progress * 2) ?? 0;

      config = EasyIndicatorLayoutConfig(
        left: left,
        width: width,
        bottom: widget.bottom,
        height: widget.height,
        top: widget.top,
      );
    } else {
      final startLeft = leadingData.center.dx;
      final endLeft = trailingData.offset.dx;
      final left = lerpDouble(startLeft, endLeft, (progress - 0.5) * 2) ?? 0;

      final startWidth = trailingData.center.dx - leadingData.center.dx;
      final endWidth = trailingData.size.width;
      final width = lerpDouble(startWidth, endWidth, (progress - 0.5) * 2) ?? 0;

      config = EasyIndicatorLayoutConfig(
        left: left,
        width: width,
        bottom: widget.bottom,
        height: widget.height,
        top: widget.top,
      );
    }
    update(config);
  }
}
