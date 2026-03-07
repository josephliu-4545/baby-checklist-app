import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/usecases/login_user.dart';
import '../../features/auth/domain/usecases/register_user.dart';
import '../../features/auth/presentation/controllers/auth_controller.dart';
import '../../features/items/data/datasources/item_firestore_datasource.dart';
import '../../features/items/data/repositories/item_repository_impl.dart';
import '../../features/items/domain/usecases/add_item.dart';
import '../../features/items/domain/usecases/delegate_item.dart';
import '../../features/items/domain/usecases/delete_item.dart';
import '../../features/items/domain/usecases/get_items.dart';
import '../../features/items/domain/usecases/mark_purchased.dart';
import '../../features/items/domain/usecases/update_item.dart';
import '../../features/items/presentation/controllers/item_controller.dart';
import '../notification/notification_service.dart';
import '../notification/sms_mock_adapter.dart';

import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:cloud_firestore/cloud_firestore.dart';

class ServiceLocator {
  ServiceLocator._();

  static final ServiceLocator I = ServiceLocator._();

  late final AuthRepositoryImpl _authRepository;
  late final LoginUser _loginUser;
  late final RegisterUser _registerUser;
  late final AuthController _authController;

  late final fb.FirebaseAuth _firebaseAuth;

  late final FirebaseFirestore _firestore;

  late final ItemFirestoreDataSource _itemFirestoreDataSource;
  late final ItemRepositoryImpl _itemRepository;
  late final GetItems _getItems;
  late final AddItem _addItem;
  late final UpdateItem _updateItem;
  late final DeleteItem _deleteItem;
  late final MarkPurchased _markPurchased;
  late final DelegateItem _delegateItem;
  late final ItemController _itemController;

  late final SmsMockAdapter _smsMockAdapter;
  late final NotificationService _notificationService;

  LoginUser get loginUser => _loginUser;

  RegisterUser get registerUser => _registerUser;

  AuthController get authController => _authController;

  GetItems get getItems => _getItems;

  AddItem get addItem => _addItem;

  UpdateItem get updateItem => _updateItem;

  DeleteItem get deleteItem => _deleteItem;

  MarkPurchased get markPurchased => _markPurchased;

  DelegateItem get delegateItem => _delegateItem;

  ItemController get itemController => _itemController;

  NotificationService get notificationService => _notificationService;

  void init() {
    _initAuthLayer();
    _initNotificationLayer();
    _initItemLayer();
  }

  void _initAuthLayer() {
    _firebaseAuth = fb.FirebaseAuth.instance;
    _authRepository = AuthRepositoryImpl(_firebaseAuth);
    _loginUser = LoginUser(_authRepository);
    _registerUser = RegisterUser(_authRepository);
    _authController = AuthController(
      _loginUser,
      _registerUser,
      _authRepository.getCurrentUser,
      _authRepository.logout,
    );
  }

  void _initItemLayer() {
    _firestore = FirebaseFirestore.instance;
    _itemFirestoreDataSource = ItemFirestoreDataSource(_firestore);
    _itemRepository = ItemRepositoryImpl(
      _itemFirestoreDataSource,
      _firebaseAuth,
    );
    _getItems = GetItems(_itemRepository);
    _addItem = AddItem(_itemRepository);
    _updateItem = UpdateItem(_itemRepository);
    _deleteItem = DeleteItem(_itemRepository);
    _markPurchased = MarkPurchased(_itemRepository);
    _delegateItem = DelegateItem(
      _itemRepository,
      _notificationService,
    );
    _itemController = ItemController(
      _getItems,
      _addItem,
      _updateItem,
      _deleteItem,
      _markPurchased,
      _delegateItem,
    );
  }

  void _initNotificationLayer() {
    _smsMockAdapter = const SmsMockAdapter();
    _notificationService = NotificationService(_smsMockAdapter);
  }
}

