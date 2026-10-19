import 'package:flutter/material.dart';

const categoryIcons = <String, IconData>{
  'category': Icons.category,
  'payments': Icons.payments,
  'home': Icons.home,
  'grocery': Icons.local_grocery_store,
  'directions_car': Icons.directions_car,
  'restaurant': Icons.restaurant,
  'movie': Icons.movie,
  'health_and_safety': Icons.health_and_safety,
  'school': Icons.school,
  'shopping_bag': Icons.shopping_bag,
  'pets': Icons.pets,
  'flight': Icons.flight,
  'bolt': Icons.bolt,
  'subscriptions': Icons.subscriptions,
  'fitness_center': Icons.fitness_center,
  'work': Icons.work,
};

class CategoryAvatar extends StatelessWidget {
  const CategoryAvatar({
    required this.iconKey,
    required this.colorArgb,
    this.radius = 20,
    super.key,
  });

  final String iconKey;
  final int colorArgb;
  final double radius;

  @override
  Widget build(BuildContext context) => CircleAvatar(
    radius: radius,
    backgroundColor: Color(colorArgb),
    child: Icon(
      categoryIcons[iconKey] ?? Icons.category,
      color: Colors.white,
      size: radius * 1.2,
    ),
  );
}
