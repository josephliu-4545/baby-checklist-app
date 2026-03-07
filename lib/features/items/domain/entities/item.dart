import 'item_image.dart';

enum ItemStatus {
  pending,
  delegated,
  purchased,
}

class ItemStatusFactory {
  const ItemStatusFactory._();

  static ItemStatus fromString(String value) {
    final normalized = value.toLowerCase();
    switch (normalized) {
      case 'pending':
        return ItemStatus.pending;
      case 'delegated':
        return ItemStatus.delegated;
      case 'purchased':
        return ItemStatus.purchased;
      default:
        throw ArgumentError('Unknown ItemStatus: $value');
    }
  }

  static String toStringValue(ItemStatus status) {
    return status.name;
  }
}

class Item {
  final String id;
  final String name;
  final String description;
  final double price;
  final int quantity;
  final ItemImage image;
  final ItemStatus status;
  final String? shopLocation;
  final String? delegatedTo;
  final DateTime createdAt;
  final DateTime? delegationDate;

  const Item({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.quantity,
    required this.image,
    required this.status,
    this.shopLocation,
    this.delegatedTo,
    required this.createdAt,
    this.delegationDate,
  });

  double get totalCost {
    return price * quantity;
  }

  Item copyWith({
    String? id,
    String? name,
    String? description,
    double? price,
    int? quantity,
    ItemImage? image,
    ItemStatus? status,
    String? shopLocation,
    String? delegatedTo,
    DateTime? createdAt,
    DateTime? delegationDate,
  }) {
    return Item(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      image: image ?? this.image,
      status: status ?? this.status,
      shopLocation: shopLocation ?? this.shopLocation,
      delegatedTo: delegatedTo ?? this.delegatedTo,
      createdAt: createdAt ?? this.createdAt,
      delegationDate: delegationDate ?? this.delegationDate,
    );
  }
}

