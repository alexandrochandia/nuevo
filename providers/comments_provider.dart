
import 'package:flutter/material.dart';
import '../models/comment_model.dart';
import '../services/supabase_service.dart';

class CommentsProvider with ChangeNotifier {
  final SupabaseService _supabaseService = SupabaseService();
  
  List<Comment> _comments = [];
  bool _isLoading = false;
  String? _error;

  List<Comment> get comments => _comments;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadComments(String postId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _supabaseService.client
          .from('comments')
          .select('''
            *,
            user_profiles!comments_user_id_fkey(
              display_name,
              avatar_url,
              is_verified
            ),
            replies:comments!comments_parent_comment_id_fkey(
              *,
              user_profiles!comments_user_id_fkey(
                display_name,
                avatar_url,
                is_verified
              )
            )
          ''')
          .eq('post_id', postId)
          .is_('parent_comment_id', null)
          .order('created_at', ascending: false);

      _comments = (response as List)
          .map((commentData) => Comment.fromJson({
                ...commentData,
                'user_name': commentData['user_profiles']['display_name'],
                'user_avatar': commentData['user_profiles']['avatar_url'],
                'is_verified': commentData['user_profiles']['is_verified'],
              }))
          .toList();
    } catch (e) {
      _error = 'Error loading comments: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addComment(String postId, String content, {String? parentCommentId}) async {
    try {
      final userId = _supabaseService.client.auth.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      final commentData = {
        'post_id': postId,
        'user_id': userId,
        'content': content,
        'parent_comment_id': parentCommentId,
        'created_at': DateTime.now().toIso8601String(),
      };

      await _supabaseService.client
          .from('comments')
          .insert(commentData);

      // Reload comments to get the updated list
      await loadComments(postId);
    } catch (e) {
      _error = 'Error adding comment: $e';
      notifyListeners();
    }
  }

  Future<void> likeComment(String commentId) async {
    try {
      final userId = _supabaseService.client.auth.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      // Check if already liked
      final existingLike = await _supabaseService.client
          .from('comment_likes')
          .select('id')
          .eq('comment_id', commentId)
          .eq('user_id', userId)
          .maybeSingle();

      if (existingLike == null) {
        // Add like
        await _supabaseService.client
            .from('comment_likes')
            .insert({
              'comment_id': commentId,
              'user_id': userId,
            });
      } else {
        // Remove like
        await _supabaseService.client
            .from('comment_likes')
            .delete()
            .eq('comment_id', commentId)
            .eq('user_id', userId);
      }

      // Update local state
      _updateCommentLikeStatus(commentId);
      notifyListeners();
    } catch (e) {
      _error = 'Error liking comment: $e';
      notifyListeners();
    }
  }

  void _updateCommentLikeStatus(String commentId) {
    for (int i = 0; i < _comments.length; i++) {
      if (_comments[i].id == commentId) {
        _comments[i] = Comment.fromJson({
          ..._comments[i].toJson(),
          'is_liked': !_comments[i].isLiked,
          'likes_count': _comments[i].isLiked 
              ? _comments[i].likesCount - 1 
              : _comments[i].likesCount + 1,
        });
        break;
      }
      // Check replies
      if (_comments[i].replies != null) {
        for (int j = 0; j < _comments[i].replies!.length; j++) {
          if (_comments[i].replies![j].id == commentId) {
            _comments[i].replies![j] = Comment.fromJson({
              ..._comments[i].replies![j].toJson(),
              'is_liked': !_comments[i].replies![j].isLiked,
              'likes_count': _comments[i].replies![j].isLiked 
                  ? _comments[i].replies![j].likesCount - 1 
                  : _comments[i].replies![j].likesCount + 1,
            });
            break;
          }
        }
      }
    }
  }
}
