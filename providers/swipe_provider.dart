import 'package:flutter/material.dart';
import '../models/swipe_action.dart';
import '../config/supabase_config.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SwipeProvider extends ChangeNotifier {
  // Removed SupabaseService dependency

  List<SwipeAction> _swipeHistory = [];
  bool _isLoading = false;
  String? _error;

  List<SwipeAction> get swipeHistory => _swipeHistory;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> performSwipe({
    required String userId,
    required String targetUserId,
    required SwipeDirection direction,
    String? comment,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final client = Supabase.instance.client;
      if (client != null) {
        final response = await client.from('swipe_actions').insert({
          'user_id': userId,
          'target_user_id': targetUserId,
          'direction': direction,
          'comment': comment,
          'created_at': DateTime.now().toIso8601String(),
        }).select().single();

        final swipeAction = SwipeAction.fromJson(response);
        _swipeHistory.insert(0, swipeAction);
      }
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadSwipeHistory(String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final client = Supabase.instance.client;
      if (client != null) {
        final response = await client
            .from('swipe_actions')
            .select('*')
            .eq('user_id', userId)
            .order('created_at', ascending: false);

        _swipeHistory = (response as List).map((action) => SwipeAction.fromJson(action)).toList();
      } else {
        _swipeHistory = [];
      }
      _error = null;
    } catch (e) {
      _error = e.toString();
      _swipeHistory = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  bool hasUserBeenSwiped(String userId, String targetUserId) {
    return _swipeHistory.any(
      (swipe) => swipe.userId == userId && swipe.targetUserId == targetUserId,
    );
  }

  SwipeAction? getLastSwipe() {
    return _swipeHistory.isNotEmpty ? _swipeHistory.first : null;
  }

  List<SwipeAction> getLikes(String userId) {
    return _swipeHistory.where((swipe) => 
      swipe.userId == userId && swipe.isLike
    ).toList();
  }

  List<SwipeAction> getPasses(String userId) {
    return _swipeHistory.where((swipe) => 
      swipe.userId == userId && swipe.isPass
    ).toList();
  }

  List<SwipeAction> getSuperLikes(String userId) {
    return _swipeHistory.where((swipe) => 
      swipe.userId == userId && swipe.isSuperLike
    ).toList();
  }

  int getLikesCount(String userId) => getLikes(userId).length;
  int getPassesCount(String userId) => getPasses(userId).length;
  int getSuperLikesCount(String userId) => getSuperLikes(userId).length;
}