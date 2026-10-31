import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/models/service_slot.dart';

class CartManager extends ChangeNotifier {
  static const String _keyCartItems = 'horizon_cart_items';

  static CartManager? _instance;
  static CartManager get instance => _instance ??= CartManager._();

  CartManager._();

  final List<ServiceSlot> _items = [];
  SharedPreferences? _prefs;

  List<ServiceSlot> get items => List.unmodifiable(_items);
  int get count => _items.length;

  double get totalPrice {
    double total = 0.0;
    for (final slot in _items) {
      total += (slot.price ?? 0.0);
    }
    return total;
  }

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    final jsonStr = _prefs?.getString(_keyCartItems);
    if (jsonStr != null && jsonStr.isNotEmpty) {
      try {
        final decoded = jsonDecode(jsonStr);
        if (decoded is List) {
          _items.clear();
          for (final item in decoded) {
            if (item is Map<String, dynamic>) {
              _items.add(ServiceSlot.fromJson(item));
            }
          }
        }
      } catch (_) {}
    }
    notifyListeners();
  }

  bool isInCart(int? slotId) {
    if (slotId == null) return false;
    return _items.any((item) => item.id == slotId);
  }

  Future<bool> addItem(ServiceSlot slot) async {
    if (slot.id == null) return false;
    if (isInCart(slot.id)) return false;

    _items.add(slot);
    await _save();
    notifyListeners();
    return true;
  }

  Future<void> removeItem(int slotId) async {
    final beforeCount = _items.length;
    _items.removeWhere((item) => item.id == slotId);
    if (_items.length != beforeCount) {
      await _save();
      notifyListeners();
    }
  }

  Future<void> clear() async {
    _items.clear();
    await _save();
    notifyListeners();
  }

  Future<void> _save() async {
    _prefs ??= await SharedPreferences.getInstance();
    final listMap = _items.map((e) => e.toJson()).toList();
    await _prefs!.setString(_keyCartItems, jsonEncode(listMap));
  }
}
