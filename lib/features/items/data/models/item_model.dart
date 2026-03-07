import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/item.dart';
import '../../domain/entities/item_image.dart';

class ItemModel {
  final String id;
  final String name;
  final String description;
  final double price;
  final int quantity;
  final String imagePath;
  final String? imageBase64;
  final String status;
  final String? shopLocation;
  final String? delegatedTo;
  final DateTime createdAt;
  final DateTime? delegationDate;

  const ItemModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.quantity,
    required this.imagePath,
    required this.imageBase64,
    required this.status,
    required this.shopLocation,
    required this.delegatedTo,
    required this.createdAt,
    required this.delegationDate,
  });

  factory ItemModel.fromEntity(Item item) {
    return ItemModel(
      id: item.id,
      name: item.name,
      description: item.description,
      price: item.price,
      quantity: item.quantity,
      imagePath: item.image.path,
      imageBase64: item.image.base64,
      status: ItemStatusFactory.toStringValue(item.status),
      shopLocation: item.shopLocation,
      delegatedTo: item.delegatedTo,
      createdAt: item.createdAt,
      delegationDate: item.delegationDate,
    );
  }

  Item toEntity() {
    return Item(
      id: id,
      name: name,
      description: description,
      price: price,
      quantity: quantity,
      image: ItemImage(
        path: imagePath,
        base64: imageBase64,
      ),
      status: ItemStatusFactory.fromString(status),
      shopLocation: shopLocation,
      delegatedTo: delegatedTo,
      createdAt: createdAt,
      delegationDate: delegationDate,
    );
  }

  factory ItemModel.fromFirestore(
    String id,
    Map<String, dynamic> data,
  ) {
    final createdAt = data['createdAt'];
    final delegationDate = data['delegationDate'];

    return ItemModel(
      id: id,
      name: (data['name'] as String?) ?? '',
      description: (data['description'] as String?) ?? '',
      price: (data['price'] as num?)?.toDouble() ?? 0,
      quantity: (data['quantity'] as num?)?.toInt() ?? 0,
      imagePath: (data['imagePath'] as String?) ?? '',
      imageBase64: data['imageBase64'] as String?,
      status: (data['status'] as String?) ?? ItemStatus.pending.name,
      shopLocation: data['shopLocation'] as String?,
      delegatedTo: data['delegatedTo'] as String?,
      createdAt: createdAt is Timestamp ? createdAt.toDate() : DateTime.now(),
      delegationDate: delegationDate is Timestamp ? delegationDate.toDate() : null,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'description': description,
      'price': price,
      'quantity': quantity,
      'imagePath': imagePath,
      'imageBase64': imageBase64,
      'status': status,
      'shopLocation': shopLocation,
      'delegatedTo': delegatedTo,
      'createdAt': Timestamp.fromDate(createdAt),
      'delegationDate': delegationDate == null ? null : Timestamp.fromDate(delegationDate!),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }
}
