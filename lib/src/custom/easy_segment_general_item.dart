part of flutter_easy_segment;

typedef CustomSegmentTweenItemBuilder<T> = Widget Function(
    BuildContext context, T? value, Widget? child);

class EasySegmentGeneralItem<R, T extends Tween<R>> extends StatefulWidget {
  // beigin: normal end: selected
  final T tween;

  final CustomSegmentTweenItemBuilder builder;

  final Widget? child;

  /// 点击切换时的动画时长
  final Duration duration;

  final Curve curve;

  const EasySegmentGeneralItem({
    Key? key,
    required this.tween,
    required this.builder,
    this.child,
    this.duration = const Duration(milliseconds: 300),
    this.curve = Curves.linear,
  }) : super(key: key);

  @override
  State<EasySegmentGeneralItem<R, T>> createState() =>
      _EasySegmentGeneralItemState<R, T>();
}

class _EasySegmentGeneralItemState<R, T extends Tween<R>>
    extends State<EasySegmentGeneralItem<R, T>>
    with
        EasySegmentControllerProviderStateMixin,
        EasySegmentItemStateMixin,
        TickerProviderStateMixin {
  late final AnimationController animationController;

  late final ValueNotifier<R?> valueChanged;

  @override
  void initState() {
    super.initState();

    _configAnimation();
    valueChanged = ValueNotifier(widget.tween.begin);
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  void _configAnimation() {
    animationController =
        AnimationController(vsync: this, duration: widget.duration)
          ..addListener(animationHandler);
  }

  @override
  void didUpdateWidget(covariant EasySegmentGeneralItem<R, T> oldWidget) {
    if (oldWidget.tween != widget.tween) {
      controller?.markNeedUpdateAfterLayout();
    }
    if (oldWidget.duration != widget.duration) {
      animationController.dispose();
      _configAnimation();
    }
    super.didUpdateWidget(oldWidget);
  }

  void animationHandler() {
    valueChanged.value = widget.tween
        .chain(CurveTween(curve: widget.curve))
        .evaluate(animationController);
  }

  @override
  void stopChanged() {}

  @override
  void tapChanged() {
    if (widget.tween.end == null || widget.tween.begin == widget.tween.end) {
      valueChanged.value = widget.tween.begin;
      return;
    }
    final controller = this.controller;
    if (controller == null) return;

    final oldIndex = controller.oldSelectedIndex;

    if (controller.currentIndex == itemIndex) {
      animationController.forward(from: 0);
    } else if (oldIndex != null && oldIndex == itemIndex) {
      animationController.reverse(from: 1);
    } else {
      valueChanged.value = widget.tween.begin;
    }
  }

  @override
  void scrollChanged() {
    if (widget.tween.end == null || widget.tween.begin == widget.tween.end) {
      valueChanged.value = widget.tween.begin;

      return;
    }
    final controller = this.controller;
    if (controller == null) return;

    final startIndex = controller.progress.truncate();
    final endIndex = controller.progress.ceil();

    if (itemIndex == startIndex) {
      final leftProgress = controller.progress - startIndex;
      valueChanged.value = widget.tween.transform(1 - leftProgress);
    } else if (itemIndex == endIndex) {
      final rightProgress = endIndex - controller.progress;
      valueChanged.value = widget.tween.transform(1 - rightProgress);
    } else {
      valueChanged.value = widget.tween.begin;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<R?>(
      valueListenable: valueChanged,
      builder: (context, value, child) {
        return widget.builder(context, value, child);
      },
      child: widget.child,
    );
  }
}
