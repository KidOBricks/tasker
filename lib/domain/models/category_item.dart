import 'dart:convert';

class CategoryItem {
  final String id;
  final String name;
  final int colorValue;
  final String iconName;
  final int sortOrder;

  const CategoryItem({
    required this.id,
    required this.name,
    required this.colorValue,
    this.iconName = 'folder',
    this.sortOrder = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'colorValue': colorValue,
      'iconName': iconName,
      'sortOrder': sortOrder,
    };
  }

  factory CategoryItem.fromMap(Map<String, dynamic> map) {
    return CategoryItem(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      colorValue: map['colorValue'] is int ? map['colorValue'] : 0xFF3B82F6,
      iconName: map['iconName'] ?? 'folder',
      sortOrder: map['sortOrder'] ?? 0,
    );
  }

  String toJson() => json.encode(toMap());

  factory CategoryItem.fromJson(String source) =>
      CategoryItem.fromMap(json.decode(source));

  static List<CategoryItem> defaultCategories() {
    return const [
      CategoryItem(
        id: 'all',
        name: 'All',
        colorValue: 0xFF6366F1, // Indigo
        iconName: 'layers',
        sortOrder: 0,
      ),
      CategoryItem(
        id: 'personal',
        name: 'Personal',
        colorValue: 0xFF10B981, // Emerald
        iconName: 'user',
        sortOrder: 1,
      ),
      CategoryItem(
        id: 'work',
        name: 'Work',
        colorValue: 0xFF3B82F6, // Blue
        iconName: 'briefcase',
        sortOrder: 2,
      ),
      CategoryItem(
        id: 'study',
        name: 'Study',
        colorValue: 0xFFF59E0B, // Amber
        iconName: 'book-open',
        sortOrder: 3,
      ),
    ];
  }
}
