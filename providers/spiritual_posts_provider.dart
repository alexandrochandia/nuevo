
import 'package:flutter/material.dart';
import '../models/spiritual_post_model.dart';
import '../services/supabase_service.dart';

class SpiritualPostsProvider with ChangeNotifier {
  List<SpiritualPostModel> _posts = [];
  List<SpiritualPostModel> _userPosts = [];
  bool _isLoading = false;
  String? _error;

  List<SpiritualPostModel> get posts => _posts;
  List<SpiritualPostModel> get userPosts => _userPosts;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Cargar posts del feed principal
  Future<void> loadFeedPosts() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await SupabaseService.supabase
          .from('spiritual_posts')
          .select('''
            *,
            profiles:user_id (
              id,
              name,
              avatar_url,
              is_verified
            ),
            post_likes:spiritual_post_likes(count),
            post_comments:spiritual_post_comments(count)
          ''')
          .order('created_at', ascending: false)
          .limit(20);

      _posts = response.map((data) => SpiritualPostModel.fromJson(data)).toList();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Error al cargar posts: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  // Cargar posts por tipo
  Future<void> loadPostsByType(String postType) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await SupabaseService.supabase
          .from('spiritual_posts')
          .select('''
            *,
            profiles:user_id (
              id,
              name,
              avatar_url,
              is_verified
            )
          ''')
          .eq('post_type', postType)
          .order('created_at', ascending: false)
          .limit(20);

      _posts = response.map((data) => SpiritualPostModel.fromJson(data)).toList();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Error al cargar posts: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  // Crear nuevo post
  Future<bool> createPost(SpiritualPostModel post) async {
    try {
      final response = await SupabaseService.supabase
          .from('spiritual_posts')
          .insert(post.toJson())
          .select()
          .single();

      final newPost = SpiritualPostModel.fromJson(response);
      _posts.insert(0, newPost);
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Error al crear post: $e';
      notifyListeners();
      return false;
    }
  }

  // Dar like a un post
  Future<void> toggleLike(String postId) async {
    try {
      final userId = SupabaseService.getCurrentUserId();
      if (userId == null) return;

      final postIndex = _posts.indexWhere((p) => p.id == postId);
      if (postIndex == -1) return;

      final post = _posts[postIndex];
      
      if (post.isLiked) {
        // Quitar like
        await SupabaseService.supabase
            .from('spiritual_post_likes')
            .delete()
            .eq('post_id', postId)
            .eq('user_id', userId);

        _posts[postIndex] = post.copyWith(
          isLiked: false,
          likesCount: post.likesCount - 1,
        );
      } else {
        // Dar like
        await SupabaseService.supabase
            .from('spiritual_post_likes')
            .insert({
              'post_id': postId,
              'user_id': userId,
              'created_at': DateTime.now().toIso8601String(),
            });

        _posts[postIndex] = post.copyWith(
          isLiked: true,
          likesCount: post.likesCount + 1,
        );
      }

      notifyListeners();
    } catch (e) {
      _error = 'Error al dar like: $e';
      notifyListeners();
    }
  }

  // Guardar/quitar de favoritos
  Future<void> toggleBookmark(String postId) async {
    try {
      final userId = SupabaseService.getCurrentUserId();
      if (userId == null) return;

      final postIndex = _posts.indexWhere((p) => p.id == postId);
      if (postIndex == -1) return;

      final post = _posts[postIndex];
      
      if (post.isBookmarked) {
        // Quitar de favoritos
        await SupabaseService.supabase
            .from('spiritual_post_bookmarks')
            .delete()
            .eq('post_id', postId)
            .eq('user_id', userId);

        _posts[postIndex] = post.copyWith(isBookmarked: false);
      } else {
        // Agregar a favoritos
        await SupabaseService.supabase
            .from('spiritual_post_bookmarks')
            .insert({
              'post_id': postId,
              'user_id': userId,
              'created_at': DateTime.now().toIso8601String(),
            });

        _posts[postIndex] = post.copyWith(isBookmarked: true);
      }

      notifyListeners();
    } catch (e) {
      _error = 'Error al guardar favorito: $e';
      notifyListeners();
    }
  }

  // Compartir post
  Future<void> sharePost(String postId) async {
    try {
      final postIndex = _posts.indexWhere((p) => p.id == postId);
      if (postIndex == -1) return;

      final post = _posts[postIndex];

      // Incrementar contador de shares
      await SupabaseService.supabase
          .from('spiritual_posts')
          .update({'shares_count': post.sharesCount + 1})
          .eq('id', postId);

      _posts[postIndex] = post.copyWith(sharesCount: post.sharesCount + 1);
      notifyListeners();
    } catch (e) {
      _error = 'Error al compartir: $e';
      notifyListeners();
    }
  }

  // Buscar posts
  Future<void> searchPosts(String query) async {
    if (query.isEmpty) {
      await loadFeedPosts();
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await SupabaseService.supabase
          .from('spiritual_posts')
          .select('''
            *,
            profiles:user_id (
              id,
              name,
              avatar_url,
              is_verified
            )
          ''')
          .or('content.ilike.%$query%,bible_reference.ilike.%$query%,tags.cs.{$query}')
          .order('created_at', ascending: false)
          .limit(20);

      _posts = response.map((data) => SpiritualPostModel.fromJson(data)).toList();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Error en búsqueda: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  // Cargar posts guardados
  Future<void> loadBookmarkedPosts() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final userId = SupabaseService.getCurrentUserId();
      if (userId == null) return;

      final response = await SupabaseService.supabase
          .from('spiritual_post_bookmarks')
          .select('''
            spiritual_posts (
              *,
              profiles:user_id (
                id,
                name,
                avatar_url,
                is_verified
              )
            )
          ''')
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      _posts = response
          .map((data) => SpiritualPostModel.fromJson(data['spiritual_posts']))
          .toList();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Error al cargar favoritos: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
