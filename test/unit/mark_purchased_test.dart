import 'package:apdp_app/features/items/domain/entities/item.dart';
import 'package:apdp_app/features/items/domain/entities/item_image.dart';
import 'package:apdp_app/features/items/domain/repositories/item_repository.dart';
import 'package:apdp_app/features/items/domain/usecases/mark_purchased.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockItemRepository extends Mock implements ItemRepository {}

class _FakeItem extends Fake implements Item {
  @override
  String get id => '';

  @override
  String get name => '';

  @override
  String get description => '';

  @override
  double get price => 0;

  @override
  int get quantity => 0;

  @override
  ItemImage get image => const ItemImage(path: '', base64: null);

  @override
  ItemStatus get status => ItemStatus.pending;

  @override
  String? get shopLocation => null;

  @override
  String? get delegatedTo => null;

  @override
  DateTime get createdAt => DateTime(1970);

  @override
  DateTime? get delegationDate => null;

  @override
  double get totalCost => 0;

  @override
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
      createdAt: createdAt ?? this.createdAt,
      shopLocation: shopLocation ?? this.shopLocation,
      delegatedTo: delegatedTo ?? this.delegatedTo,
      delegationDate: delegationDate ?? this.delegationDate,
    );
  }
}

void main() {
  late MockItemRepository repo;
  late MarkPurchased usecase;

  setUpAll(() {
    registerFallbackValue(_FakeItem());
  });

  setUp(() {
    repo = MockItemRepository();
    usecase = MarkPurchased(repo);
  });

  test('When getItemById() returns null, updateItem() is never called', () async {
    when(() => repo.getItemById(any())).thenAnswer((_) async => null);

    await usecase('id-1');

    verify(() => repo.getItemById('id-1')).called(1);
    verifyNever(() => repo.updateItem(any()));
  });

  test('When item exists, updateItem() is called once with purchased status',
      () async {
    final item = Item(
      id: 'id-2',
      name: 'Bottle',
      description: '',
      price: 10.0,
      quantity: 1,
      image: const ItemImage(path: '', base64: null),
      status: ItemStatus.pending,
      createdAt: DateTime(2026, 1, 1),
    );

    when(() => repo.getItemById(any())).thenAnswer((_) async => item);
    when(() => repo.updateItem(any())).thenAnswer((_) async {});

    await usecase('id-2');

    verify(() => repo.getItemById('id-2')).called(1);
    verify(
      () => repo.updateItem(
        any(
          that: isA<Item>()
              .having((i) => i.id, 'id', 'id-2')
              .having((i) => i.status, 'status', ItemStatus.purchased),
        ),
      ),
    ).called(1);
  });
}
