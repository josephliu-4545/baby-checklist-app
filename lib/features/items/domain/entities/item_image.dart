class ItemImage {
  final String path;
  final String? base64;

  const ItemImage({
    required this.path,
    this.base64,
  });

  bool get isPlaceholder {
    return path.trim().isEmpty && (base64 == null || base64!.trim().isEmpty);
  }

  bool get hasBase64 {
    return base64 != null && base64!.trim().isNotEmpty;
  }

  ItemImage copyWith({
    String? path,
    String? base64,
  }) {
    return ItemImage(
      path: path ?? this.path,
      base64: base64 ?? this.base64,
    );
  }
}

