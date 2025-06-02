import 'package:firebase_database/firebase_database.dart';
import 'package:project_sicerdas/data/models/user_model.dart';

class FirebaseDbProvider {
  final FirebaseDatabase _database = FirebaseDatabase.instance;

  // --- User Profile ---
  Future<void> createUserProfile(UserModel user) async {
    try {
      DatabaseReference userRef = _database.ref('users/${user.uid}');
      await userRef.set(user.toJson());
      print('User profile created for ${user.uid}');
    } catch (e) {
      print('Error creating user profile: $e');
      throw Exception('Failed to create user profile: $e');
    }
  }

  Future<UserModel?> getUserProfile(String uid) async {
    try {
      DatabaseReference userRef = _database.ref('users/$uid');
      final snapshot = await userRef.get();
      if (snapshot.exists && snapshot.value != null) {
        final Map<String, dynamic> userData = Map<String, dynamic>.from(snapshot.value as Map);
        return UserModel.fromJson(userData);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get user profile: $e');
    }
  }

  Future<void> updateUserProfile(String uid, Map<String, dynamic> data) async {
    try {
      DatabaseReference userRef = _database.ref('users/$uid');
      await userRef.update(data);
      print('User profile updated for $uid');
    } catch (e) {
      print('Error updating user profile: $e');
      throw Exception('Failed to update user profile: $e');
    }
  }

  // --- Bookmarks ---
  Future<void> addBookmark(String uid, String articleId, Map<String, dynamic> articleData) async {
    try {
      DatabaseReference bookmarkRef = _database.ref('users/$uid/bookmarks/$articleId');
      await bookmarkRef.set(articleData);
      print('Article $articleId bookmarked for user $uid');
    } catch (e) {
      print('Error adding bookmark: $e');
      throw Exception('Failed to add bookmark: $e');
    }
  }

  Future<void> removeBookmark(String uid, String articleId) async {
    try {
      DatabaseReference bookmarkRef = _database.ref('users/$uid/bookmarks/$articleId');
      await bookmarkRef.remove();
      print('Article $articleId removed from bookmarks for user $uid');
    } catch (e) {
      print('Error removing bookmark: $e');
      throw Exception('Failed to remove bookmark: $e');
    }
  }

  Stream<Map<String, dynamic>> getBookmarksStream(String uid) {
    DatabaseReference bookmarksRef = _database.ref('users/$uid/bookmarks');
    return bookmarksRef.onValue.map((event) {
      final Map<String, dynamic> bookmarks = {};
      if (event.snapshot.exists && event.snapshot.value != null) {
        final Map<dynamic, dynamic> rawData = event.snapshot.value as Map<dynamic, dynamic>;
        rawData.forEach((key, value) {
          if (value is Map) {
            // Pastikan value adalah Map
            bookmarks[key as String] = Map<String, dynamic>.from(value);
          }
        });
      }
      return bookmarks;
    });
  }

  // Mendapatkan daftar bookmark sebagai list
  Future<List<Map<String, dynamic>>> getBookmarksList(String uid) async {
    try {
      DatabaseReference bookmarksRef = _database.ref('users/$uid/bookmarks');
      final snapshot = await bookmarksRef.get();
      final List<Map<String, dynamic>> bookmarksList = [];
      if (snapshot.exists && snapshot.value != null) {
        final Map<dynamic, dynamic> rawData = snapshot.value as Map<dynamic, dynamic>;
        rawData.forEach((key, value) {
          if (value is Map) {
            bookmarksList.add({'id': key, ...Map<String, dynamic>.from(value)});
          }
        });
      }
      return bookmarksList;
    } catch (e) {
      print('Error getting bookmarks list: $e');
      return [];
    }
  }
}
