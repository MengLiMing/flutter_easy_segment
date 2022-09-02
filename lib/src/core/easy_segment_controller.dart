part of flutter_easy_segment;

enum EasySegmentChangeType {
  /// 未改动
  none,

  /// 通过外部滑动切换 - 调用 changeProgress
  scroll,

  /// 通过点击切换 - 调用 scrollToIndex
  tap,

  /// 停止时
  stoped
}

class EasySegmentController extends ChangeNotifier {
  EasySegmentController({int initialIndex = 0}) : _initialIndex = initialIndex;

  final Map<int, EasySegmentItemLayoutData> _itemDatas = {};

  int _initialIndex;

  int _maxNumber = 0;

  double _progress = -1;

  final Map<int, ValueNotifier<EasyIndicatorLayoutConfig>> _indicatorConfigs =
      {};

  ValueNotifier<EasyIndicatorLayoutConfig> _indicatorConfig(int index) {
    _indicatorConfigs[index] ??= ValueNotifier(
      const EasyIndicatorLayoutConfig(left: 0, bottom: 0, width: 0, height: 0),
    );
    return _indicatorConfigs[index]!;
  }

  final Map<int, ValueNotifier<EasyIndicatorLayoutConfig>>
      _foregroundIndicatorConfigs = {};
  ValueNotifier<EasyIndicatorLayoutConfig> _foregroundIndicatorConfig(
      int index) {
    _foregroundIndicatorConfigs[index] ??= ValueNotifier(
      const EasyIndicatorLayoutConfig(left: 0, bottom: 0, width: 0, height: 0),
    );
    return _foregroundIndicatorConfigs[index]!;
  }

  EasySegmentChangeType _changeType = EasySegmentChangeType.none;

  int? _oldSelectedIndex;

  void _setMaxNumber(int maxNumber) {
    _itemDatas.clear();
    _needUpdateAtStop = false;
    _maxNumber = maxNumber;
  }

  bool _needUpdateAfterLayout = false;

  void markNeedUpdateAfterLayout() {
    _needUpdateAfterLayout = true;
  }

  /// 标记是否滚动到初始位置
  var _hadScrollToInitialIndex = false;

  var _needUpdateAtStop = false;

  void _configData(int index, EasySegmentItemLayoutData data) {
    final oldData = _itemDatas[index];

    _itemDatas[index] = data;

    if (!_needUpdateAtStop && oldData != data) {
      _needUpdateAtStop = true;
    }

    if (_itemDatas.length == _maxNumber) {
      if (_hadScrollToInitialIndex == false) {
        _hadScrollToInitialIndex = true;
        resetInitialIndex(_initialIndex);
      }
      if (_needUpdateAfterLayout) {
        _needUpdateAfterLayout = false;
        _changeType = EasySegmentChangeType.scroll;
        notifyListeners();
      }
      if (_needUpdateAtStop && progress.toInt() == progress) {
        _needUpdateAtStop = false;

        /// 需要矫正，比如item动画时间长，而指示器时间短的话可能指示器动画结束了 但是item的大小还在变化
        _changeType = EasySegmentChangeType.stoped;
        notifyListeners();
      }
    }
  }

  double get progress => _progress;

  /// 当前下标
  int get currentIndex => _progress.round();

  /// 切换类型
  EasySegmentChangeType get changeType => _changeType;

  /// 点击切换时的上一个坐标 用来外部对其做动画
  int? get oldSelectedIndex => _oldSelectedIndex;

  /// 重置
  void resetInitialIndex(int index) {
    _initialIndex = index;
    _changeType = EasySegmentChangeType.tap;

    if (currentIndex < _maxNumber && currentIndex >= 0) {
      _oldSelectedIndex = currentIndex;
    } else {
      _oldSelectedIndex = null;
    }
    _progress = index.toDouble();
    notifyListeners();
  }

  /// 滚动到当前下标
  void scrollToIndex(int index) {
    if (_progress == index.toDouble()) return;
    _changeType = EasySegmentChangeType.tap;

    _oldSelectedIndex = currentIndex;
    _progress = index.toDouble();
    notifyListeners();
  }

  void changeProgress(double progress, {bool force = false}) {
    if (force == false && _progress == progress) return;
    _progress = progress;
    _changeType = EasySegmentChangeType.scroll;
    notifyListeners();
  }
}

class _EasySegmentControllerProvider extends InheritedWidget {
  final EasySegmentController controller;

  const _EasySegmentControllerProvider({
    Key? key,
    required Widget child,
    required this.controller,
  }) : super(key: key, child: child);

  static EasySegmentController? of(BuildContext context) {
    final controlerProvider = context
        .dependOnInheritedWidgetOfExactType<_EasySegmentControllerProvider>();
    return controlerProvider?.controller;
  }

  @override
  bool updateShouldNotify(covariant _EasySegmentControllerProvider oldWidget) {
    return oldWidget.controller != controller;
  }
}

// mixin EasySegmentController

mixin EasySegmentControllerProviderStateMixin<T extends StatefulWidget>
    on State<T> {
  EasySegmentController? _controller;

  EasySegmentController? get controller =>
      mounted ? _EasySegmentControllerProvider.of(context) : null;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    if (_controller != controller) {
      _controller?.removeListener(_segControllerListener);
      _controller = controller;
      _controller?.addListener(_segControllerListener);
      SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
        tapChanged();
      });
    }

    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _controller?.removeListener(_segControllerListener);
    super.dispose();
  }

  void _segControllerListener() {
    final controller = this.controller;
    if (controller == null) return;
    switch (controller.changeType) {
      case EasySegmentChangeType.scroll:
        scrollChanged();
        break;
      case EasySegmentChangeType.tap:
        tapChanged();
        break;
      case EasySegmentChangeType.stoped:
        stopChanged();
        break;
      default:
        return;
    }
  }

  /// 滑动百分比回调
  void scrollChanged() {}

  /// 点击回调
  void tapChanged() {}

  /// 停止且有数据改动时
  void stopChanged() {}
}

/// 指示器的布局配置信息
class EasyIndicatorLayoutConfig {
  final double left;
  final double width;

  final double? bottom;
  final double? height;
  final double? top;

  const EasyIndicatorLayoutConfig({
    required this.left,
    required this.width,
    this.height,
    this.bottom,
    this.top,
  });

  @override
  bool operator ==(covariant EasyIndicatorLayoutConfig other) {
    if (identical(this, other)) return true;

    return other.left == left &&
        other.width == width &&
        other.bottom == bottom &&
        other.height == height &&
        other.top == top;
  }

  @override
  int get hashCode {
    return left.hashCode ^
        width.hashCode ^
        bottom.hashCode ^
        height.hashCode ^
        top.hashCode;
  }
}

/// item布局信息
class EasySegmentItemLayoutData {
  final Size size;
  final int index;
  final Offset offset;

  const EasySegmentItemLayoutData({
    required this.size,
    required this.index,
    required this.offset,
  });

  Offset get center =>
      Offset(offset.dx + size.width / 2, offset.dy + size.height / 2);

  @override
  bool operator ==(covariant EasySegmentItemLayoutData other) {
    if (identical(this, other)) return true;

    return other.size == size && other.index == index && other.offset == offset;
  }

  @override
  int get hashCode => size.hashCode ^ index.hashCode ^ offset.hashCode;
}
