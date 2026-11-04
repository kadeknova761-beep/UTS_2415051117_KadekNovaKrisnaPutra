import '../models/meal.dart';
import '../models/meal_category.dart';

// Data contoh untuk FakeMealRepository (pengujian dan pengembangan offline).
// Aplikasi sungguhan memakai MealRepositoryImpl (REST API TheMealDB).

const List<MealCategory> dummyCategories = [
  MealCategory(id: '1', name: 'Beef', thumbnailUrl: '', description: ''),
  MealCategory(id: '2', name: 'Chicken', thumbnailUrl: '', description: ''),
  MealCategory(id: '3', name: 'Seafood', thumbnailUrl: '', description: ''),
  MealCategory(id: '4', name: 'Vegetarian', thumbnailUrl: '', description: ''),
  MealCategory(id: '5', name: 'Dessert', thumbnailUrl: '', description: ''),
];

const List<Meal> dummyMeals = [
  Meal(
    id: '1',
    name: 'Nasi Goreng Kampung',
    thumbnailUrl: '',
    category: 'Chicken',
    area: 'Indonesian',
    instructions:
        'Panaskan minyak di wajan.\n'
        'Tumis bawang hingga harum.\n'
        'Masukkan nasi dan bumbu, aduk rata.\n'
        'Sajikan selagi hangat.',
    ingredients: [
      MealIngredient(name: 'Nasi putih', measure: '2 piring'),
      MealIngredient(name: 'Bawang merah', measure: '3 siung'),
      MealIngredient(name: 'Kecap manis', measure: '2 sdm'),
    ],
  ),
  Meal(
    id: '2',
    name: 'Beef Rendang',
    thumbnailUrl: '',
    category: 'Beef',
    area: 'Malaysian',
    instructions:
        'Haluskan semua bumbu.\n'
        'Masak daging bersama bumbu dan santan.\n'
        'Aduk perlahan hingga kuah mengering.',
    ingredients: [
      MealIngredient(name: 'Daging sapi', measure: '500 g'),
      MealIngredient(name: 'Santan', measure: '400 ml'),
      MealIngredient(name: 'Serai', measure: '2 batang'),
    ],
  ),
  Meal(
    id: '3',
    name: 'Grilled Fish with Lemon and Herbs',
    thumbnailUrl: '',
    category: 'Seafood',
    area: 'Mediterranean',
  ),
  Meal(
    id: '4',
    name: 'Vegetable Curry',
    thumbnailUrl: '',
    category: 'Vegetarian',
    area: 'Indian',
  ),
  Meal(
    id: '5',
    name: 'Chocolate Lava Cake',
    thumbnailUrl: '',
    category: 'Dessert',
    area: 'French',
  ),
  Meal(
    id: '6',
    name: 'Chicken Satay',
    thumbnailUrl: '',
    category: 'Chicken',
    area: 'Indonesian',
  ),
];
