import 'package:shared_preferences/shared_preferences.dart';

class FavouritesService {
  static const _key = 'favourite_tools';

  static Future<Set<String>> getFavourites() async {
    final prefs = await SharedPreferences.getInstance();
    return (prefs.getStringList(_key) ?? []).toSet();
  }

  static Future<void> toggle(String toolId) async {
    final prefs = await SharedPreferences.getInstance();
    final current = (prefs.getStringList(_key) ?? []).toSet();
    if (current.contains(toolId)) {
      current.remove(toolId);
    } else {
      current.add(toolId);
    }
    await prefs.setStringList(_key, current.toList());
  }

  static Future<bool> isFavourite(String toolId) async {
    final favs = await getFavourites();
    return favs.contains(toolId);
  }
}
