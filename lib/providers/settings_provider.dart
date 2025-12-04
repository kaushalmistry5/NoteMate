import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider extends ChangeNotifier{
  bool _isGridView = false;
  String _sortOrder = 'date_modified';

  bool get isGridView => _isGridView;
  String get sortOrder => _sortOrder;

  SettingsProvider() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _isGridView = prefs.getBool('grid_view') ?? false;
    _sortOrder = prefs.getString('sort_order') ?? 'date_modified';
    notifyListeners();
  }

  Future<void> setViewMode(bool isGrid) async {
    _isGridView = isGrid;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('grid_view', isGrid);
  }

  Future<void> setSortOrder(String order) async {
    _sortOrder = order;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('sort_order', order);
  }
}