part of flutter_easy_segment;

/// 自定义指示器
mixin EasySegmentIndicatorMixin<T extends StatefulWidget>
    on
        EasySegmentIndicatorStateMixin<T>,
        EasySegmentControllerProviderStateMixin<T> {
  void update(EasyIndicatorLayoutConfig config) {
    final position = this.position;
    if (position == null) return;
    switch (position) {
      case _EasySegmentIndicatorPosition.background:
        controller?._indicatorConfig(itemIndex).value = config;

        break;
      case _EasySegmentIndicatorPosition.foreground:
        controller?._foregroundIndicatorConfig(itemIndex).value = config;
        break;
    }
  }

  EasySegmentItemLayoutData? itemLayoutData(int index) {
    return controller?._itemDatas[index];
  }

  EasySegmentItemLayoutData? currentItemLayoutData() {
    final currentIndex = controller?.currentIndex;
    if (currentIndex == null) return null;
    return itemLayoutData(currentIndex);
  }

  EasySegmentItemLayoutData? leadingItemLayoutData() {
    final leadingIndex = controller?.progress.truncate();
    if (leadingIndex == null) return null;
    return itemLayoutData(leadingIndex);
  }

  EasySegmentItemLayoutData? trailingItemLayoutData() {
    final trailingIndex = controller?.progress.ceil();
    if (trailingIndex == null) return null;
    return itemLayoutData(trailingIndex);
  }

  double? progress() {
    final controller = this.controller;
    if (controller == null) return null;
    return controller.progress - controller.progress.truncate();
  }
}

enum _EasySegmentIndicatorPosition {
  background,
  foreground,
}

class _EasySegmentIndicatorConfig extends InheritedWidget {
  final _EasySegmentIndicatorPosition position;
  final int index;

  const _EasySegmentIndicatorConfig({
    Key? key,
    required Widget child,
    required this.index,
    required this.position,
  }) : super(
          key: key,
          child: child,
        );

  static int? indicatorIndex(BuildContext context) {
    final controlerProvider = context
        .dependOnInheritedWidgetOfExactType<_EasySegmentIndicatorConfig>();
    return controlerProvider?.index;
  }

  static _EasySegmentIndicatorPosition? indicatorPosition(
      BuildContext context) {
    final controlerProvider = context
        .dependOnInheritedWidgetOfExactType<_EasySegmentIndicatorConfig>();
    return controlerProvider?.position;
  }

  @override
  bool updateShouldNotify(covariant _EasySegmentIndicatorConfig oldWidget) {
    return oldWidget.position != position || oldWidget.index != index;
  }
}

mixin EasySegmentIndicatorStateMixin<T extends StatefulWidget> on State<T> {
  int get itemIndex => mounted
      ? (_EasySegmentIndicatorConfig.indicatorIndex(context) ?? -1)
      : -1;

  _EasySegmentIndicatorPosition? get position =>
      mounted ? _EasySegmentIndicatorConfig.indicatorPosition(context) : null;
}
