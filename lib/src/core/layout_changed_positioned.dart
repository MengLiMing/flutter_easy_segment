part of flutter_easy_segment;

class LayoutChangedPositioned extends Positioned {
  final ValueSetter<RenderObject> handler;

  const LayoutChangedPositioned({
    super.key,
    double? left,
    double? top,
    double? right,
    double? bottom,
    double? width,
    double? height,
    required super.child,
    required this.handler,
  }) : super(
          left: left,
          top: top,
          right: right,
          bottom: bottom,
          width: width,
          height: height,
        );

  @override
  void applyParentData(RenderObject renderObject) {
    super.applyParentData(renderObject);
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      handler(renderObject);
    });
  }
}
