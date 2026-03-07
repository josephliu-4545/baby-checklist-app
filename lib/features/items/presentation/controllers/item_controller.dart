import 'package:flutter/foundation.dart';

import '../../domain/entities/item.dart';
import '../../domain/usecases/get_items.dart';
import '../../domain/usecases/add_item.dart';
import '../../domain/usecases/update_item.dart';
import '../../domain/usecases/delete_item.dart';
import '../../domain/usecases/mark_purchased.dart';
import '../../domain/usecases/delegate_item.dart';

class ItemController extends ChangeNotifier {
  final GetItems _getItems;
  final AddItem _addItem;
  final UpdateItem _updateItem;
  final DeleteItem _deleteItem;
  final MarkPurchased _markPurchased;
  final DelegateItem _delegateItem;

  List<Item> _items = [];
  String _searchQuery = '';
  ItemStatus? _statusFilter;
  bool _isLoading = false;
  String? _errorMessage;

  ItemController(
    this._getItems,
    this._addItem,
    this._updateItem,
    this._deleteItem,
    this._markPurchased,
    this._delegateItem,
  );

  List<Item> get items => _items;

  String get searchQuery => _searchQuery;

  ItemStatus? get statusFilter => _statusFilter;

  List<Item> get displayedItems {
    final query = _searchQuery.trim().toLowerCase();

    Iterable<Item> result = _items;

    if (_statusFilter != null) {
      result = result.where((e) => e.status == _statusFilter);
    }

    if (query.isNotEmpty) {
      result = result.where(
        (e) => e.name.toLowerCase().contains(query),
      );
    }

    return result.toList();
  }

  bool get isLoading => _isLoading;

  String? get errorMessage => _errorMessage;

  void setSearchQuery(String value) {
    _searchQuery = value;
    notifyListeners();
  }

  void setStatusFilter(ItemStatus? value) {
    _statusFilter = value;
    notifyListeners();
  }

  void clearFilters() {
    _searchQuery = '';
    _statusFilter = null;
    notifyListeners();
  }

  Future<void> loadItems() async {
    _setError(null);
    _setLoading(true);

    try {
      final result = await _getItems();
      _items = result;
    } catch (e) {
      _setError(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      _setLoading(false);
      notifyListeners();
    }
  }

  Future<void> addItem(Item item) async {
    try {
      await _addItem(item);
      await loadItems();
    } catch (e) {
      _setError(e.toString().replaceFirst('Exception: ', ''));
      notifyListeners();
    }
  }

  Future<void> updateItem(Item item) async {
    try {
      await _updateItem(item);
      await loadItems();
    } catch (e) {
      _setError(e.toString().replaceFirst('Exception: ', ''));
      notifyListeners();
    }
  }

  Future<void> deleteItem(String id) async {
    try {
      await _deleteItem(id);
      await loadItems();
    } catch (e) {
      _setError(e.toString().replaceFirst('Exception: ', ''));
      notifyListeners();
    }
  }

  Future<void> markPurchased(String id) async {
    try {
      await _markPurchased(id);
      await loadItems();
    } catch (e) {
      _setError(e.toString().replaceFirst('Exception: ', ''));
      notifyListeners();
    }
  }

  Future<void> delegateItem({
    required String itemId,
    required String delegatedTo,
  }) async {
    try {
      await _delegateItem(
        itemId: itemId,
        delegatedTo: delegatedTo,
      );
      await loadItems();
    } catch (e) {
      _setError(e.toString().replaceFirst('Exception: ', ''));
      notifyListeners();
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
  }

  void _setError(String? message) {
    _errorMessage = message;
  }
}
