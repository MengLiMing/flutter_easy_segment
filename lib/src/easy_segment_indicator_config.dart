part of flutter_easy_segment;

class EasyIndicatorConfig {
  final double left;
  final double width;

  final double? bottom;
  final double? height;
  final double? top;

  const EasyIndicatorConfig({
    required this.left,
    required this.width,
    this.height,
    this.bottom,
    this.top,
  });

  @override
  bool operator ==(covariant EasyIndicatorConfig other) {
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

class EasySegmentItemData {
  final Size size;
  final int index;
  final Offset offset;

  const EasySegmentItemData({
    required this.size,
    required this.index,
    required this.offset,
  });

  Offset get center =>
      Offset(offset.dx + size.width / 2, offset.dy + size.height / 2);

  @override
  bool operator ==(covariant EasySegmentItemData other) {
    if (identical(this, other)) return true;

    return other.size == size && other.index == index && other.offset == offset;
  }

  @override
  int get hashCode => size.hashCode ^ index.hashCode ^ offset.hashCode;
}
