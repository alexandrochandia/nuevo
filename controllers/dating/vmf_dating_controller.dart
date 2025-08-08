import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../models/user_model.dart';
import '../../services/supabase_service.dart';

class VmfDatingController extends GetxController {

  var users = <UserModel>[].obs;
  var currentIndex = 0.obs;
  var isLoading = false.obs;
  var likedUsers = <String>[].obs;
  var matchedUsers = <UserModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadUsers();
  }

  Future<void> loadUsers() async {
    try {
      isLoading.value = true;
      final fetchedUsers = await SupabaseService.getUsers();
      users.assignAll(fetchedUsers.map((userData) => UserModel.fromJson(userData)).toList());
    } catch (e) {
      print('Error loading users: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> likeUser(UserModel user) async {
    try {
      await SupabaseService.createSwipeAction(
        userId: 'current_user_id', // Replace with actual current user ID
        targetUserId: user.id,
        action: 'like',
      );

      likedUsers.add(user.id);

      // Check if it's a match
      bool isMatch = await SupabaseService.checkMatch('current_user_id', user.id);
      
      if (isMatch) {
        matchedUsers.add(user);
        _showMatchDialog(user);
      }
      
      _nextUser();
    } catch (e) {
      print('Error liking user: $e');
    }
  }

  Future<void> passUser(UserModel user) async {
    try {
      await SupabaseService.createSwipeAction(
        userId: 'current_user_id', // Replace with actual current user ID
        targetUserId: user.id,
        action: 'pass',
      );
      
      _nextUser();
    } catch (e) {
      print('Error passing user: $e');
    }
  }

  void _nextUser() {
    if (currentIndex.value < users.length - 1) {
      currentIndex.value++;
    } else {
      // Load more users or show message
      loadUsers();
      currentIndex.value = 0;
    }
  }

  void _showMatchDialog(UserModel user) {
    Get.dialog(
      AlertDialog(
        title: const Text('¡Es un Match! 💕'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 40,
              backgroundImage: NetworkImage(user.profilePicture ?? ''),
            ),
            const SizedBox(height: 16),
            Text('Tienes un match con ${user.name}'),
            const Text('¡Ahora pueden chatear!'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Continuar'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              // Navigate to chat
            },
            child: const Text('Chatear'),
          ),
        ],
      ),
    );
  }

  // Alias methods for compatibility with vmf_dating_card.dart
  Future<void> swipeRight(UserModel user) async {
    await likeUser(user);
  }

  Future<void> swipeLeft(UserModel user) async {
    await passUser(user);
  }
}
