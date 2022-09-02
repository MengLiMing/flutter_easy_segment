part of flutter_easy_segment;

class EasySegment extends StatefulWidget {
  /// 间距
  final double space;

  final EdgeInsets padding;

  final List<Widget> children;

  /// 指示器 - 放置在后方
  final List<Widget> indicators;

  /// 指示器 - 放置在前方
  final List<Widget> foregroundIndicators;

  final EasySegmentController controller;

  final ValueChanged<int>? onTap;

  const EasySegment({
    Key? key,
    this.space = 10,
    this.padding = const EdgeInsets.only(left: 10, right: 10),
    required this.controller,
    required this.children,
    this.indicators = const [],
    this.foregroundIndicators = const [],
    this.onTap,
  }) : super(key: key);

  @override
  State<EasySegment> createState() => _EasySegmentState();
}

class _EasySegmentState extends State<EasySegment>
    with SingleTickerProviderStateMixin {
  final ScrollController scrollController = ScrollController();

  EasySegmentController get segController => widget.controller;

  Map<int, EasySegmentItemLayoutData> get itemDatas =>
      widget.controller._itemDatas;

  late final AnimationController animationController;

  final Tween<double> offsetTween = Tween(begin: 0, end: 0);

  double? animationStartOffset;

  @override
  void initState() {
    super.initState();

    animationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 300))
      ..addListener(animationHandler);

    /// 测试发现PageView在树形结构发生改变即重新生成state时，会再次设置为初始index，但是没有回调，easy_segment_view和其保持一致吧
    segController._hadScrollToInitialIndex = false;
    configController();
  }

  @override
  void dispose() {
    scrollController.dispose();
    segController.removeListener(_segListener);
    animationController.dispose();
    super.dispose();
  }

  void _segListener() {
    switch (segController.changeType) {
      case EasySegmentChangeType.scroll:
        toMiddle();
        break;
      case EasySegmentChangeType.tap:
        animatedToMiddle();
        break;
      default:
        break;
    }
  }

  void configController() {
    segController.addListener(_segListener);
  }

  @override
  void didUpdateWidget(covariant EasySegment oldWidget) {
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.dispose();
      configController();
    }
    if (oldWidget.space != widget.space ||
        oldWidget.padding != widget.padding) {
      segController.markNeedUpdateAfterLayout();
    }
    super.didUpdateWidget(oldWidget);
  }

  /// 相对于起点 停止时的偏移
  double? targetX() {
    final leftIndex = segController.progress.truncate();
    final rightIndex = segController.progress.ceil();

    final leftData = itemDatas[leftIndex];
    final rightData = itemDatas[rightIndex];

    if (leftData == null || rightData == null) return null;

    final progress = segController.progress - leftIndex;

    final startOffset = leftData.center;
    final endOffset = rightData.center;

    final currentOffset = Offset(
        lerpDouble(startOffset.dx, endOffset.dx, progress)!,
        lerpDouble(startOffset.dy, endOffset.dy, progress)!);

    return currentOffset.dx + widget.padding.left;
  }

  /// 取相对起点的偏移 置中 - 后续可以通过不同的枚举添加滑动停止的位置
  double? toMiddleOffsetX() {
    final offsetX = targetX();
    if (scrollController.positions.isEmpty || offsetX == null) return null;

    final position = scrollController.position;
    final centerOffsetX = offsetX - position.viewportDimension / 2;

    return max(min(centerOffsetX, position.maxScrollExtent), 0);
  }

  /// 根据进度置中
  void toMiddle() {
    final result = toMiddleOffsetX();
    if (result != null) {
      scrollController.jumpTo(result);
    }
  }

  /// 点击动画置中
  void animatedToMiddle() {
    animationStartOffset = scrollController.offset;
    animationController.forward(from: 0);
  }

  void animationHandler() {
    final result = toMiddleOffsetX();
    if (result != null) {
      offsetTween.begin = scrollController.offset;
      offsetTween.end = result;
    }

    final offset = offsetTween
        .chain(CurveTween(curve: Curves.easeInOut))
        .evaluate(animationController);
    scrollController.jumpTo(offset);
  }

  @override
  Widget build(BuildContext context) {
    widget.controller._setMaxNumber(widget.children.length);
    return _EasySegmentControllerProvider(
      controller: widget.controller,
      child: SingleChildScrollView(
        controller: scrollController,
        physics: const ClampingScrollPhysics(),
        scrollDirection: Axis.horizontal,
        child: Stack(
          alignment: Alignment.center,
          children: [
            for (int i = 0; i < widget.indicators.length; i++)
              ValueListenableBuilder<EasyIndicatorLayoutConfig>(
                valueListenable: segController._indicatorConfig(i),
                builder: (context, config, child) {
                  return Positioned(
                    left: config.left,
                    width: config.width,
                    height: config.height,
                    bottom: config.bottom,
                    top: config.top,
                    child: child!,
                  );
                },
                child: _EasySegmentIndicatorConfig(
                  index: i,
                  position: _EasySegmentIndicatorPosition.background,
                  child: widget.indicators[i],
                ),
              ),
            Padding(
              padding: widget.padding,
              child: Row(
                children: [
                  for (int i = 0; i < widget.children.length; i++) ...[
                    if (i != 0)
                      SizedBox(
                        width: widget.space,
                      ),
                    LayoutAfter(
                      child: GestureDetector(
                        onTap: () {
                          segController.scrollToIndex(i);
                          widget.onTap?.call(i);
                        },
                        behavior: HitTestBehavior.translucent,
                        child: _EasySegmentItemInfoConfig(
                          itemIndex: i,
                          child: widget.children[i],
                        ),
                      ),
                      handler: (renderBox) {
                        final parentData =
                            renderBox.parentData as BoxParentData;
                        final parentDataOffset = parentData.offset;
                        final offset = Offset(
                          parentDataOffset.dx + widget.padding.left,
                          parentDataOffset.dy + widget.padding.top,
                        );
                        final size = renderBox.size;
                        widget.controller._configData(
                          i,
                          EasySegmentItemLayoutData(
                            size: size,
                            index: i,
                            offset: offset,
                          ),
                        );
                      },
                    ),
                  ],
                ],
              ),
            ),
            for (int i = 0; i < widget.foregroundIndicators.length; i++)
              ValueListenableBuilder<EasyIndicatorLayoutConfig>(
                valueListenable: segController._foregroundIndicatorConfig(i),
                builder: (context, config, child) {
                  return Positioned(
                    left: config.left,
                    width: config.width,
                    height: config.height,
                    bottom: config.bottom,
                    top: config.top,
                    child: child!,
                  );
                },
                child: _EasySegmentIndicatorConfig(
                  index: i,
                  position: _EasySegmentIndicatorPosition.foreground,
                  child: widget.foregroundIndicators[i],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
