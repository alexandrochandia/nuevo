import 'package:flutter/material.dart';
import 'dart:async';
import '../models/vmf_story_model.dart';
import '../config/supabase_config.dart';

class VMFStoriesProvider extends ChangeNotifier {
  List<VMFStoryModel> _stories = [];
  List<VMFStoryModel> _filteredStories = [];
  VMFStoryCategory? _selectedCategory;
  bool _isLoading = false;
  String _error = '';
  Timer? _refreshTimer;
  
  List<VMFStoryModel> get stories => _filteredStories.isEmpty ? _stories : _filteredStories;
  VMFStoryCategory? get selectedCategory => _selectedCategory;
  bool get isLoading => _isLoading;
  String get error => _error;
  
  // Get stories by category
  List<VMFStoryModel> getStoriesByCategory(VMFStoryCategory category) {
    return _stories.where((story) => story.category == category).toList();
  }
  
  // Get trending stories (most viewed)
  List<VMFStoryModel> get trendingStories {
    final sorted = List<VMFStoryModel>.from(_stories);
    sorted.sort((a, b) => b.views.compareTo(a.views));
    return sorted.take(10).toList();
  }
  
  // Get recent stories (last 24 hours)
  List<VMFStoryModel> get recentStories {
    final yesterday = DateTime.now().subtract(const Duration(hours: 24));
    return _stories.where((story) => story.createdAt.isAfter(yesterday)).toList();
  }
  
  // Get stories from verified users
  List<VMFStoryModel> get verifiedStories {
    return _stories.where((story) => story.isVerified).toList();
  }

  VMFStoriesProvider() {
    _initializeStories();
    _startPeriodicRefresh();
  }

  Future<void> _initializeStories() async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      // Try to fetch from Supabase first, fallback to mock data
      await _fetchStoriesFromSupabase();
    } catch (e) {
      print('Error fetching from Supabase, using mock data: $e');
      _stories = VMFStoryModel.mockVMFStories();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> _fetchStoriesFromSupabase() async {
    try {
      final response = await SupabaseConfig.client
          ?.from('vmf_stories')
          .select()
          .order('created_at', ascending: false);

      if (response.isNotEmpty) {
        _stories = response.map<VMFStoryModel>((json) => VMFStoryModel.fromJson(json)).toList();
      } else {
        // If no data in Supabase, use mock data
        _stories = VMFStoryModel.mockVMFStories();
      }
    } catch (e) {
      // Fallback to mock data
      _stories = VMFStoryModel.mockVMFStories();
      throw e;
    }
  }

  // Filter stories by category
  void filterByCategory(VMFStoryCategory? category) {
    _selectedCategory = category;
    
    if (category == null) {
      _filteredStories = [];
    } else {
      _filteredStories = _stories.where((story) => story.category == category).toList();
    }
    
    notifyListeners();
  }

  // Clear filters
  void clearFilters() {
    _selectedCategory = null;
    _filteredStories = [];
    notifyListeners();
  }

  // Like/Unlike story
  Future<void> toggleLike(String storyId) async {
    final storyIndex = _stories.indexWhere((story) => story.id == storyId);
    if (storyIndex != -1) {
      final story = _stories[storyIndex];
      final newLiked = !story.isLiked;
      final newLikes = newLiked ? story.likes + 1 : story.likes - 1;
      
      _stories[storyIndex] = story.copyWith(
        isLiked: newLiked,
        likes: newLikes,
      );
      
      // Update filtered stories if they exist
      if (_filteredStories.isNotEmpty) {
        final filteredIndex = _filteredStories.indexWhere((story) => story.id == storyId);
        if (filteredIndex != -1) {
          _filteredStories[filteredIndex] = _stories[storyIndex];
        }
      }
      
      notifyListeners();

      // Try to update in Supabase
      try {
        await SupabaseConfig.client
            ?.from('vmf_stories')
            .update({
              'likes': newLikes,
              'is_liked': newLiked,
            })
            .eq('id', storyId);
      } catch (e) {
        print('Error updating like in Supabase: $e');
      }
    }
  }

  // Add view to story
  Future<void> addView(String storyId, String userId) async {
    final storyIndex = _stories.indexWhere((story) => story.id == storyId);
    if (storyIndex != -1) {
      final story = _stories[storyIndex];
      
      // Only add view if user hasn't viewed before
      if (!story.viewByUserIds.contains(userId)) {
        final newViewByUserIds = List<String>.from(story.viewByUserIds)..add(userId);
        
        _stories[storyIndex] = story.copyWith(
          viewByUserIds: newViewByUserIds,
          views: story.views + 1,
        );
        
        // Update filtered stories if they exist
        if (_filteredStories.isNotEmpty) {
          final filteredIndex = _filteredStories.indexWhere((story) => story.id == storyId);
          if (filteredIndex != -1) {
            _filteredStories[filteredIndex] = _stories[storyIndex];
          }
        }
        
        notifyListeners();

        // Try to update in Supabase
        try {
          await SupabaseConfig.client
              ?.from('vmf_stories')
              .update({
                'views': story.views + 1,
                'view_by_user_ids': newViewByUserIds,
              })
              .eq('id', storyId);
        } catch (e) {
          print('Error updating view in Supabase: $e');
        }
      }
    }
  }

  // Refresh stories
  Future<void> refreshStories() async {
    await _initializeStories();
  }

  // Add new story
  Future<bool> addStory(VMFStoryModel story) async {
    try {
      // Try to add to Supabase first
      await SupabaseConfig.client
          ?.from('vmf_stories')
          .insert(story.toJson());
      
      // Add to local list
      _stories.insert(0, story);
      notifyListeners();
      
      return true;
    } catch (e) {
      print('Error adding story: $e');
      _error = 'Error al publicar la historia';
      notifyListeners();
      return false;
    }
  }

  // Delete story
  Future<bool> deleteStory(String storyId) async {
    try {
      // Try to delete from Supabase
      await SupabaseConfig.client
          ?.from('vmf_stories')
          .delete()
          .eq('id', storyId);
      
      // Remove from local lists
      _stories.removeWhere((story) => story.id == storyId);
      _filteredStories.removeWhere((story) => story.id == storyId);
      notifyListeners();
      
      return true;
    } catch (e) {
      print('Error deleting story: $e');
      _error = 'Error al eliminar la historia';
      notifyListeners();
      return false;
    }
  }

  // Get stories for user
  List<VMFStoryModel> getStoriesForUser(String userId) {
    return _stories.where((story) => story.userId == userId).toList();
  }

  // Start periodic refresh (every 5 minutes)
  void _startPeriodicRefresh() {
    _refreshTimer = Timer.periodic(const Duration(minutes: 5), (timer) {
      refreshStories();
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }
}