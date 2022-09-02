part of flutter_easy_segment;

/// 自定义item
mixin EasySegmentItemMixin<T extends StatefulWidget>
    on
        EasySegmentControllerProviderStateMixin<T>,
        EasySegmentItemStateMixin<T> {}

class _EasySegmentItemInfoConfig extends InheritedWidget {
  final int itemIndex;

  const _EasySegmentItemInfoConfig({
    Key? key,
    required Widget child,
    required this.itemIndex,
  }) : super(key: key, child: child);

  static int? index(BuildContext context) {
    final controlerProvider = context
        .dependOnInheritedWidgetOfExactType<_EasySegmentItemInfoConfig>();
    return controlerProvider?.itemIndex;
  }

  @override
  bool updateShouldNotify(covariant _EasySegmentItemInfoConfig oldWidget) {
    return oldWidget.itemIndex != itemIndex;
  }
}

mixin EasySegmentItemStateMixin<T extends StatefulWidget> on State<T> {
  int get itemIndex =>
      mounted ? (_EasySegmentItemInfoConfig.index(context) ?? -1) : -1;
}
