enum SortField { name, modified }

enum SortOrder { asc, desc }

class SortOption {
  final SortField field;
  final SortOrder order;

  const SortOption(this.field, this.order);

  static const SortOption defaultOption =
      SortOption(SortField.name, SortOrder.asc);

  String get label {
    final f = field == SortField.name ? '名称' : '修改时间';
    final o = order == SortOrder.asc ? '升序' : '降序';
    return '$f · $o';
  }

  String encode() => '${field.name}:${order.name}';

  static SortOption decode(String? raw) {
    if (raw == null || !raw.contains(':')) return defaultOption;
    final parts = raw.split(':');
    final field = SortField.values.firstWhere(
      (e) => e.name == parts[0],
      orElse: () => SortField.name,
    );
    final order = SortOrder.values.firstWhere(
      (e) => e.name == parts[1],
      orElse: () => SortOrder.asc,
    );
    return SortOption(field, order);
  }

  @override
  bool operator ==(Object other) =>
      other is SortOption && other.field == field && other.order == order;

  @override
  int get hashCode => Object.hash(field, order);
}
