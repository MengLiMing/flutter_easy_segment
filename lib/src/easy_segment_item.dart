part of flutter_easy_segment;

/// 提供下标
class EasySegmentItemIndexProvider extends InheritedWidget {
  final int itemIndex;

  const EasySegmentItemIndexProvider({
    Key? key,
    required Widget child,
    required this.itemIndex,
  }) : super(key: key, child: child);

  static int? of(BuildContext context) {
    final controlerProvider = context
        .dependOnInheritedWidgetOfExactType<EasySegmentItemIndexProvider>();
    return controlerProvider?.itemIndex;
  }

  @override
  bool updateShouldNotify(covariant EasySegmentItemIndexProvider oldWidget) {
    return oldWidget.itemIndex != itemIndex;
  }
}

mixin EasySegmentItem<T extends StatefulWidget> on State<T> {
  int get itemIndex =>
      mounted ? (EasySegmentItemIndexProvider.of(context) ?? -1) : -1;
}
